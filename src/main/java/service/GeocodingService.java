package service;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GeocodingService {
    private static final String NOMINATIM_SEARCH_URL = "https://nominatim.openstreetmap.org/search";
    private static final Pattern FIRST_COORDINATE = Pattern.compile(
            "\\{[^{}]*?\"lat\"\\s*:\\s*\"([-0-9.]+)\"[^{}]*?\"lon\"\\s*:\\s*\"([-0-9.]+)\"",
            Pattern.DOTALL);

    private final HttpClient httpClient;

    public GeocodingService() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(5))
                .build();
    }

    public Optional<Coordinates> geocode(String address, String city, String postalCode, String country)
            throws IOException, InterruptedException {
        String query = joinAddress(address, postalCode, city, country);
        if (query.isBlank()) {
            return Optional.empty();
        }

        String encoded = URLEncoder.encode(query, StandardCharsets.UTF_8);
        URI uri = URI.create(NOMINATIM_SEARCH_URL + "?format=jsonv2&limit=1&addressdetails=0&q=" + encoded);
        HttpRequest request = HttpRequest.newBuilder(uri)
                .timeout(Duration.ofSeconds(8))
                .header("Accept", "application/json")
                .header("User-Agent", "AutoHUB-University-Project/1.0 (dealer-geocoding)")
                .GET()
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            return Optional.empty();
        }

        Matcher matcher = FIRST_COORDINATE.matcher(response.body());
        if (!matcher.find()) {
            return Optional.empty();
        }

        return Optional.of(new Coordinates(new BigDecimal(matcher.group(1)), new BigDecimal(matcher.group(2))));
    }

    private String joinAddress(String address, String postalCode, String city, String country) {
        StringBuilder query = new StringBuilder();
        append(query, address);
        append(query, postalCode);
        append(query, city);
        append(query, country == null || country.isBlank() ? "Italia" : country);
        return query.toString();
    }

    private void append(StringBuilder query, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }
        if (query.length() > 0) {
            query.append(", ");
        }
        query.append(value.trim());
    }

    public static class Coordinates {
        private final BigDecimal latitude;
        private final BigDecimal longitude;

        public Coordinates(BigDecimal latitude, BigDecimal longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }

        public BigDecimal getLatitude() {
            return latitude;
        }

        public BigDecimal getLongitude() {
            return longitude;
        }
    }
}
