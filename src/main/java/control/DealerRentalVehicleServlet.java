package control;

import dao.RentalDAO;
import model.RentalVehicle;
import model.User;
import service.GeocodingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

@WebServlet("/dealer/rental-vehicles")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 25 * 1024 * 1024
)
public class DealerRentalVehicleServlet extends HttpServlet {
    private static final int MIN_VEHICLE_IMAGES = 3;
    private static final int MAX_VEHICLE_IMAGES = 5;
    private static final String PRODUCT_IMAGE_DIR = "/images/products/";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User dealer = DealerDashboardServlet.requireDealer(req, resp);
        if (dealer == null) return;

        String action = req.getParameter("action");
        try {
            RentalDAO dao = new RentalDAO();
            if ("new".equals(action)) {
                req.setAttribute("mode", "rental");
                req.getRequestDispatcher("/WEB-INF/view/dealer/vehicle-form.jsp").forward(req, resp);
                return;
            }
            if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                RentalVehicle vehicle = dao.findVehicleById(id).orElse(null);
                if (vehicle == null || vehicle.getDealerId() == null || vehicle.getDealerId() != dealer.getId()) {
                    resp.sendRedirect(req.getContextPath() + "/dealer/rental-vehicles?success=not-owned");
                    return;
                }
                req.setAttribute("mode", "rental");
                req.setAttribute("rentalVehicle", vehicle);
                req.getRequestDispatcher("/WEB-INF/view/dealer/vehicle-form.jsp").forward(req, resp);
                return;
            }
            req.setAttribute("rentalVehicles", dao.findVehiclesByDealerId(dealer.getId()));
        } catch (Exception e) {
            req.setAttribute("error", "Errore caricamento veicoli a noleggio: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/view/dealer/rental-vehicles.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User dealer = DealerDashboardServlet.requireDealer(req, resp);
        if (dealer == null) return;

        String action = req.getParameter("action");
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean deleted = new RentalDAO().softDeleteVehicleForDealer(id, dealer.getId());
                resp.sendRedirect(req.getContextPath() + "/dealer/rental-vehicles?success=" + (deleted ? "deleted" : "not-owned"));
                return;
            }

            RentalVehicle existingVehicle = null;
            if ("update".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                existingVehicle = new RentalDAO().findVehicleById(id).orElse(null);
                if (existingVehicle == null || existingVehicle.getDealerId() == null || existingVehicle.getDealerId() != dealer.getId()) {
                    resp.sendRedirect(req.getContextPath() + "/dealer/rental-vehicles?success=not-owned");
                    return;
                }
            }

            RentalVehicle vehicle = new RentalVehicle();
            if (existingVehicle != null) {
                vehicle.setId(existingVehicle.getId());
            }
            vehicle.setName(trim(req.getParameter("name")));
            vehicle.setBrand(trim(req.getParameter("brand")));
            vehicle.setDescription(trim(req.getParameter("description")));
            vehicle.setCategory(defaultIfBlank(req.getParameter("category"), "Noleggio Concessionario"));
            List<String> imagePaths = buildImagePathList(req, vehicle.getName(), existingVehicle);
            vehicle.setImageUrl(imagePaths.get(0));
            vehicle.setImageUrls(imagePaths);
            vehicle.setCity(defaultIfBlank(req.getParameter("city"), defaultIfBlank(dealer.getCity(), "Roma")));
            vehicle.setAvailable(true);
            vehicle.setDealerId(dealer.getId());
            try { vehicle.setPricePerDay(new BigDecimal(req.getParameter("pricePerDay"))); } catch (Exception e) { vehicle.setPricePerDay(BigDecimal.ZERO); }
            try { vehicle.setLatitude(new BigDecimal(req.getParameter("latitude"))); } catch (Exception e) { vehicle.setLatitude(null); }
            try { vehicle.setLongitude(new BigDecimal(req.getParameter("longitude"))); } catch (Exception e) { vehicle.setLongitude(null); }
            setDealerCoordinates(vehicle, dealer);

            if (existingVehicle == null) {
                new RentalDAO().createVehicle(vehicle);
                resp.sendRedirect(req.getContextPath() + "/dealer/rental-vehicles?success=created");
            } else {
                new RentalDAO().updateVehicleForDealer(vehicle, dealer.getId());
                resp.sendRedirect(req.getContextPath() + "/dealer/rental-vehicles?success=updated");
            }
        } catch (Exception e) {
            req.setAttribute("mode", "rental");
            req.setAttribute("error", "Inserimento non riuscito: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/view/dealer/vehicle-form.jsp").forward(req, resp);
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String defaultIfBlank(String value, String fallback) {
        String trimmed = trim(value);
        return trimmed.isBlank() ? fallback : trimmed;
    }

    private void setDealerCoordinates(RentalVehicle vehicle, User dealer) {
        if (dealer.getLatitude() != null && dealer.getLongitude() != null) {
            vehicle.setLatitude(dealer.getLatitude());
            vehicle.setLongitude(dealer.getLongitude());
            return;
        }

        geocodeDealer(dealer);
        if (dealer.getLatitude() != null && dealer.getLongitude() != null) {
            vehicle.setLatitude(dealer.getLatitude());
            vehicle.setLongitude(dealer.getLongitude());
            return;
        }

        BigDecimal[] coordinates = coordinatesForCity(vehicle.getCity());
        vehicle.setLatitude(coordinates[0]);
        vehicle.setLongitude(coordinates[1]);
    }

    private void geocodeDealer(User dealer) {
        try {
            new GeocodingService()
                    .geocode(dealer.getAddress(), dealer.getCity(), dealer.getPostalCode(), dealer.getCountry())
                    .ifPresent(coordinates -> {
                        dealer.setLatitude(coordinates.getLatitude());
                        dealer.setLongitude(coordinates.getLongitude());
                    });
        } catch (Exception ignored) {
        }
    }

    private BigDecimal[] coordinatesForCity(String city) {
        String normalized = city == null ? "" : city.trim().toLowerCase();
        switch (normalized) {
            case "milano": return coords("45.4642", "9.1900");
            case "torino": return coords("45.0703", "7.6869");
            case "bologna": return coords("44.4949", "11.3426");
            case "firenze": return coords("43.7696", "11.2558");
            case "napoli": return coords("40.8518", "14.2681");
            case "bari": return coords("41.1171", "16.8719");
            case "verona": return coords("45.4384", "10.9916");
            case "palermo": return coords("38.1157", "13.3615");
            default: return coords("41.9028", "12.4964");
        }
    }

    private BigDecimal[] coords(String latitude, String longitude) {
        return new BigDecimal[] { new BigDecimal(latitude), new BigDecimal(longitude) };
    }

    private List<String> buildImagePathList(HttpServletRequest req, String vehicleName, RentalVehicle existingVehicle) throws IOException, ServletException {
        List<String> imagePaths = new ArrayList<>();
        Collection<Part> parts = req.getParts();
        int uploadedImageCount = 0;

        for (Part part : parts) {
            if ("vehicleImages".equals(part.getName()) && part.getSize() > 0) {
                uploadedImageCount++;
            }
        }

        if (uploadedImageCount == 0 && existingVehicle != null) {
            addLocalImagePaths(imagePaths, existingVehicle.getImageUrls());
            addLocalImagePath(imagePaths, existingVehicle.getImageUrl());
            if (imagePaths.size() < MIN_VEHICLE_IMAGES) {
                throw new ServletException("Carica almeno 3 immagini del veicolo salvate sul server.");
            }
            return imagePaths;
        }

        if (uploadedImageCount < MIN_VEHICLE_IMAGES) {
            throw new ServletException("Carica almeno 3 immagini del veicolo.");
        }
        if (uploadedImageCount > MAX_VEHICLE_IMAGES) {
            throw new ServletException("Puoi caricare al massimo 5 immagini del veicolo.");
        }

        for (Part part : parts) {
            if (!"vehicleImages".equals(part.getName()) || part.getSize() == 0) {
                continue;
            }
            String contentType = part.getContentType();
            if (contentType == null || !contentType.toLowerCase().startsWith("image/")) {
                continue;
            }
            imagePaths.add(saveVehicleImage(part));
        }

        if (imagePaths.size() < MIN_VEHICLE_IMAGES) {
            throw new ServletException("Carica almeno 3 immagini valide del veicolo.");
        }
        return imagePaths;
    }

    private void addLocalImagePaths(List<String> imagePaths, List<String> rawValues) {
        if (rawValues == null) {
            return;
        }
        for (String value : rawValues) {
            addLocalImagePath(imagePaths, value);
        }
    }

    private void addLocalImagePath(List<String> imagePaths, String path) {
        if (path == null || path.isBlank()) {
            return;
        }
        String normalizedPath = path.trim().replace("\\", "/");
        if (normalizedPath.startsWith("images/products/")) {
            normalizedPath = "/" + normalizedPath;
        }
        if (normalizedPath.startsWith(PRODUCT_IMAGE_DIR) && !imagePaths.contains(normalizedPath) && imagePaths.size() < MAX_VEHICLE_IMAGES) {
            imagePaths.add(normalizedPath);
        }
    }

    private String saveVehicleImage(Part part) throws IOException {
        String submittedName = getSubmittedFileName(part);
        String extension = extractExtension(submittedName);
        String fileName = UUID.randomUUID() + extension;
        byte[] imageBytes;
        try (InputStream inputStream = part.getInputStream()) {
            imageBytes = inputStream.readAllBytes();
        }
        for (Path uploadDir : resolveProductImageDirectories()) {
            Files.createDirectories(uploadDir);
            Files.write(uploadDir.resolve(fileName), imageBytes);
        }
        return PRODUCT_IMAGE_DIR + fileName;
    }

    private List<Path> resolveProductImageDirectories() {
        List<Path> directories = new ArrayList<>();

        // 1) Webapp deployata (es. target/autohub/images/products) — file serviti da Tomcat
        String deployedPath = getServletContext().getRealPath(PRODUCT_IMAGE_DIR);
        if (deployedPath != null && !deployedPath.isBlank()) {
            Path deployDir = Path.of(deployedPath).toAbsolutePath().normalize();
            addUploadDirectory(directories, deployDir);

            // 2) Se il deploy è sotto target/, copia anche in src/main/webapp/images/products
            String normalized = deployDir.toString().replace('\\', '/');
            int targetIdx = normalized.indexOf("/target/");
            if (targetIdx >= 0) {
                Path srcDir = Path.of(normalized.substring(0, targetIdx))
                        .resolve("src/main/webapp/images/products")
                        .toAbsolutePath()
                        .normalize();
                addUploadDirectory(directories, srcDir);
            }
        }

        // 3) Fallback se non c'è /target/ nel path (altro tipo di deploy)
        addUploadDirectory(
                directories,
                Path.of(System.getProperty("user.dir"), "src", "main", "webapp", "images", "products")
                        .toAbsolutePath()
                        .normalize()
        );

        return directories;
    }

    private void addUploadDirectory(List<Path> directories, Path directory) {
        if (!directories.contains(directory)) {
            directories.add(directory);
        }
    }

    private String getSubmittedFileName(Part part) {
        String submittedName = part.getSubmittedFileName();
        if (submittedName == null || submittedName.isBlank()) {
            return "veicolo.jpg";
        }
        String normalizedName = submittedName.replace("\\", "/");
        int slashIndex = normalizedName.lastIndexOf('/');
        return slashIndex >= 0 ? normalizedName.substring(slashIndex + 1) : normalizedName;
    }

    private String extractExtension(String fileName) {
        int dotIndex = fileName == null ? -1 : fileName.lastIndexOf('.');
        if (dotIndex < 0 || dotIndex == fileName.length() - 1) {
            return ".jpg";
        }
        String extension = fileName.substring(dotIndex).toLowerCase();
        return extension.matches("\\.(jpg|jpeg|png|webp|gif)") ? extension : ".jpg";
    }

}
