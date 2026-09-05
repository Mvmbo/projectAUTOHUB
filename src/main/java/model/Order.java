package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class Order implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String status;
    private String shippingName;
    private String shippingAddress;
    private String shippingCity;
    private String shippingPostal;
    private String shippingCountry;
    private String paymentMethod;
    private BigDecimal totalAmount;
    private LocalDateTime createdAt;
    private List<OrderItem> items = new ArrayList<>();

    public Order() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getShippingName() { return shippingName; }
    public void setShippingName(String shippingName) { this.shippingName = shippingName; }

    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }

    public String getShippingCity() { return shippingCity; }
    public void setShippingCity(String shippingCity) { this.shippingCity = shippingCity; }

    public String getShippingPostal() { return shippingPostal; }
    public void setShippingPostal(String shippingPostal) { this.shippingPostal = shippingPostal; }

    public String getShippingCountry() { return shippingCountry; }
    public void setShippingCountry(String shippingCountry) { this.shippingCountry = shippingCountry; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getCreatedAtFormatted() {
        if (createdAt == null) {
            return "Data non disponibile";
        }
        return createdAt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    public Date getCreatedAtAsDate() {
        if (createdAt == null) {
            return null;
        }
        return Date.from(createdAt.atZone(ZoneId.systemDefault()).toInstant());
    }

    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }

    public void addItem(OrderItem item) {
        if (this.items == null) this.items = new ArrayList<>();
        this.items.add(item);
    }
}
