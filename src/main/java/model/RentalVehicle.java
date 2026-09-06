package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class RentalVehicle {

    private Integer id;
    private String name;
    private String brand;
    private String description;
    private BigDecimal pricePerDay;
    private String category;
    private String imageUrl;
    private List<String> imageUrls;
    private boolean isAvailable;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private String city;
    private Integer dealerId;
    private String dealerName;
    private String dealerAddress;
    private String dealerCity;
    private BigDecimal dealerLatitude;
    private BigDecimal dealerLongitude;
    private LocalDateTime createdAt;

    public RentalVehicle() {
        this.imageUrls = new ArrayList<>();
        this.isAvailable = true;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getPricePerDay() { return pricePerDay; }
    public void setPricePerDay(BigDecimal pricePerDay) { this.pricePerDay = pricePerDay; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public List<String> getImageUrls() { return imageUrls; }
    public void setImageUrls(List<String> imageUrls) { this.imageUrls = imageUrls; }

    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { this.isAvailable = available; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public Integer getDealerId() { return dealerId; }
    public void setDealerId(Integer dealerId) { this.dealerId = dealerId; }

    public String getDealerName() { return dealerName; }
    public void setDealerName(String dealerName) { this.dealerName = dealerName; }

    public String getDealerAddress() { return dealerAddress; }
    public void setDealerAddress(String dealerAddress) { this.dealerAddress = dealerAddress; }

    public String getDealerCity() { return dealerCity; }
    public void setDealerCity(String dealerCity) { this.dealerCity = dealerCity; }

    public BigDecimal getDealerLatitude() { return dealerLatitude; }
    public void setDealerLatitude(BigDecimal dealerLatitude) { this.dealerLatitude = dealerLatitude; }

    public BigDecimal getDealerLongitude() { return dealerLongitude; }
    public void setDealerLongitude(BigDecimal dealerLongitude) { this.dealerLongitude = dealerLongitude; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
