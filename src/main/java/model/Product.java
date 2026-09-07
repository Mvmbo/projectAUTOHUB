package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;

public class Product implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String description;
    private BigDecimal price;
    private int stockQuantity;
    private String category;
    private String imageUrl;
    private String imageUrls;
    private Integer productionYear;
    private String engine;
    private String power;
    private String transmission;
    private String drivetrain;
    private String acceleration;
    private String topSpeed;
    private String fuelConsumption;
    private String dimensions;
    private String mileage;
    private String equipment;
    private Integer dealerId;
    private String dealerName;
    private boolean isDeleted;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Product() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getImageUrls() { return imageUrls; }
    public void setImageUrls(String imageUrls) { this.imageUrls = imageUrls; }

    public Integer getProductionYear() { return productionYear; }
    public void setProductionYear(Integer productionYear) { this.productionYear = productionYear; }

    public String getEngine() { return engine; }
    public void setEngine(String engine) { this.engine = engine; }

    public String getPower() { return power; }
    public void setPower(String power) { this.power = power; }

    public String getTransmission() { return transmission; }
    public void setTransmission(String transmission) { this.transmission = transmission; }

    public String getDrivetrain() { return drivetrain; }
    public void setDrivetrain(String drivetrain) { this.drivetrain = drivetrain; }

    public String getAcceleration() { return acceleration; }
    public void setAcceleration(String acceleration) { this.acceleration = acceleration; }

    public String getTopSpeed() { return topSpeed; }
    public void setTopSpeed(String topSpeed) { this.topSpeed = topSpeed; }

    public String getFuelConsumption() { return fuelConsumption; }
    public void setFuelConsumption(String fuelConsumption) { this.fuelConsumption = fuelConsumption; }

    public String getDimensions() { return dimensions; }
    public void setDimensions(String dimensions) { this.dimensions = dimensions; }

    public String getMileage() { return mileage; }
    public void setMileage(String mileage) { this.mileage = mileage; }

    public String getEquipment() { return equipment; }
    public void setEquipment(String equipment) { this.equipment = equipment; }

    public Integer getDealerId() { return dealerId; }
    public void setDealerId(Integer dealerId) { this.dealerId = dealerId; }

    public String getDealerName() { return dealerName; }
    public void setDealerName(String dealerName) { this.dealerName = dealerName; }

    public boolean isDeleted() { return isDeleted; }
    public void setDeleted(boolean deleted) { isDeleted = deleted; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Date getCreatedAtAsDate() {
        if (createdAt == null) {
            return null;
        }
        return Date.from(createdAt.atZone(ZoneId.systemDefault()).toInstant());
    }

    public Date getUpdatedAtAsDate() {
        if (updatedAt == null) {
            return null;
        }
        return Date.from(updatedAt.atZone(ZoneId.systemDefault()).toInstant());
    }
}
