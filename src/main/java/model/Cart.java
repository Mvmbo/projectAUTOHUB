package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Shopping Cart model.
 * Stores cart items in a LinkedHashMap to preserve insertion order.
 * Used for both authenticated and guest users (stored in session).
 */
public class Cart implements Serializable {
    private static final long serialVersionUID = 1L;

    private final Map<Integer, CartItem> items = new LinkedHashMap<>();

    /**
     * Adds a product to the cart with the specified quantity.
     * If the product already exists, increments the quantity.
     */
    public void addItem(Product product, int qty) {
        if (product == null || qty <= 0) {
            return;
        }
        int id = product.getId();
        if (items.containsKey(id)) {
            CartItem existing = items.get(id);
            if (existing != null) {
                existing.setQuantity(existing.getQuantity() + qty);
            }
        } else {
            items.put(id, new CartItem(product, qty));
        }
    }

    /**
     * Updates the quantity of a product in the cart.
     * If quantity is 0 or negative, removes the item.
     */
    public void updateItem(int productId, int qty) {
        if (qty <= 0) {
            items.remove(productId);
        } else if (items.containsKey(productId)) {
            CartItem item = items.get(productId);
            if (item != null) {
                item.setQuantity(qty);
            }
        }
    }

    /**
     * Removes a product from the cart.
     */
    public void removeItem(int productId) {
        items.remove(productId);
    }

    /**
     * Clears all items from the cart.
     */
    public void clear() {
        items.clear();
    }

    /**
     * Gets all cart items.
     */
    public Collection<CartItem> getItems() {
        return items.values();
    }

    /**
     * Gets the internal items map.
     */
    public Map<Integer, CartItem> getItemsMap() {
        return items;
    }

    /**
     * Gets a specific cart item by product ID.
     */
    public CartItem getCartItem(int productId) {
        return items.get(productId);
    }

    /**
     * Calculates the total amount of all items in the cart.
     */
    public BigDecimal getTotalAmount() {
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : items.values()) {
            if (item != null) {
                BigDecimal subtotal = item.getSubtotal();
                if (subtotal != null) {
                    total = total.add(subtotal);
                }
            }
        }
        return total;
    }

    /**
     * Gets the total number of items in the cart (sum of all quantities).
     */
    public int getTotalItems() {
        int count = 0;
        for (CartItem item : items.values()) {
            if (item != null) {
                count += item.getQuantity();
            }
        }
        return count;
    }

    /**
     * Checks if the cart has no items.
     * In JSP use ${empty cart.items} — do not use ${cart.empty} (EL reserved keyword).
     */
    public boolean isEmpty() {
        return items.isEmpty();
    }

    /**
     * Gets the count of distinct products (not total quantity).
     */
    public int getItemCount() {
        return items.size();
    }
}
