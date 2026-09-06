package model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Cart Item model.
 * Represents a product and its quantity in the shopping cart.
 */
public class CartItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private Product product;
    private int quantity;

    public CartItem() {
        this.quantity = 1;
    }

    public CartItem(Product product, int quantity) {
        this.product = product;
        this.quantity = quantity > 0 ? quantity : 1;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity > 0 ? quantity : 1;
    }

    /**
     * Calculates the subtotal for this cart item.
     * Returns BigDecimal.ZERO if product or price is null.
     */
    public BigDecimal getSubtotal() {
        if (product == null) {
            return BigDecimal.ZERO;
        }
        BigDecimal price = product.getPrice();
        if (price == null) {
            return BigDecimal.ZERO;
        }
        return price.multiply(BigDecimal.valueOf(quantity));
    }
}
