package dao;

import model.CartItem;
import model.Order;
import model.OrderItem;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

public class OrderDAO {

    private Order mapOrderRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getInt("id"));
        o.setUserId(rs.getInt("user_id"));
        o.setStatus(rs.getString("status"));
        o.setShippingName(rs.getString("shipping_name"));
        o.setShippingAddress(rs.getString("shipping_address"));
        o.setShippingCity(rs.getString("shipping_city"));
        o.setShippingPostal(rs.getString("shipping_postal"));
        o.setShippingCountry(rs.getString("shipping_country"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setTotalAmount(rs.getBigDecimal("total_amount"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) o.setCreatedAt(ts.toLocalDateTime());
        return o;
    }

    private OrderItem mapItemRow(ResultSet rs) throws SQLException {
        OrderItem oi = new OrderItem();
        oi.setId(rs.getInt("id"));
        oi.setOrderId(rs.getInt("order_id"));
        int pid = rs.getInt("product_id");
        oi.setProductId(rs.wasNull() ? null : pid);
        oi.setProductName(rs.getString("product_name"));
        oi.setProductPrice(rs.getBigDecimal("product_price"));
        oi.setQuantity(rs.getInt("quantity"));
        oi.setSubtotal(rs.getBigDecimal("subtotal"));
        return oi;
    }

    public Order createOrder(Order order, Collection<CartItem> cartItems) throws SQLException {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String orderSql = "INSERT INTO orders (user_id, status, shipping_name, shipping_address, " +
                    "shipping_city, shipping_postal, shipping_country, payment_method, total_amount) " +
                    "VALUES (?,?,?,?,?,?,?,?,?)";
            PreparedStatement ps = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, order.getUserId());
            ps.setString(2, order.getStatus() != null ? order.getStatus() : "confirmed");
            ps.setString(3, order.getShippingName());
            ps.setString(4, order.getShippingAddress());
            ps.setString(5, order.getShippingCity());
            ps.setString(6, order.getShippingPostal());
            ps.setString(7, order.getShippingCountry());
            ps.setString(8, order.getPaymentMethod());
            ps.setBigDecimal(9, order.getTotalAmount());
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) order.setId(rs.getInt(1));
            rs.close(); ps.close();

            String itemSql = "INSERT INTO order_items (order_id, product_id, product_name, product_price, quantity, subtotal) " +
                    "VALUES (?,?,?,?,?,?)";
            PreparedStatement ps2 = conn.prepareStatement(itemSql);
            for (CartItem ci : cartItems) {
                ps2.setInt(1, order.getId());
                ps2.setInt(2, ci.getProduct().getId());
                ps2.setString(3, ci.getProduct().getName());
                ps2.setBigDecimal(4, ci.getProduct().getPrice());
                ps2.setInt(5, ci.getQuantity());
                ps2.setBigDecimal(6, ci.getSubtotal());
                ps2.addBatch();
            }
            ps2.executeBatch();
            ps2.close();

            conn.commit();
            return order;
        } catch (SQLException e) {
            if (conn != null) { try { conn.rollback(); } catch (SQLException ignored) {} }
            throw e;
        } finally {
            if (conn != null) { try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {} }
        }
    }

    public List<Order> findByUserId(int userId) throws SQLException {
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<Order> list = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapOrderRow(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public Order findOrderWithItems(int orderId) throws SQLException {
        Order order = null;

        String orderSql = "SELECT * FROM orders WHERE id = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(orderSql);
            ps.setInt(1, orderId);
            rs = ps.executeQuery();
            if (rs.next()) order = mapOrderRow(rs);
        } finally {
            DBUtil.close(conn, ps, rs);
        }

        if (order == null) return null;

        String itemSql = "SELECT * FROM order_items WHERE order_id = ? ORDER BY id";
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(itemSql);
            ps.setInt(1, orderId);
            rs = ps.executeQuery();
            while (rs.next()) order.addItem(mapItemRow(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }

        return order;
    }

    public List<Order> findAll() throws SQLException {
        String sql = "SELECT * FROM orders ORDER BY created_at DESC";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<Order> list = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapOrderRow(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public List<Order> findWithFilters(LocalDate fromDate, LocalDate toDate, Integer userId) throws SQLException {
        StringBuilder sb = new StringBuilder("SELECT * FROM orders WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (fromDate != null) {
            sb.append(" AND created_at >= ?");
            params.add(Timestamp.valueOf(fromDate.atStartOfDay()));
        }
        if (toDate != null) {
            sb.append(" AND created_at < ?");
            params.add(Timestamp.valueOf(toDate.plusDays(1).atStartOfDay()));
        }
        if (userId != null) {
            sb.append(" AND user_id = ?");
            params.add(userId);
        }
        sb.append(" ORDER BY created_at DESC");

        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<Order> list = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sb.toString());
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof Timestamp) ps.setTimestamp(i + 1, (Timestamp) v);
                else if (v instanceof Integer) ps.setInt(i + 1, (Integer) v);
            }
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapOrderRow(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public int countToday() throws SQLException {
        String sql = "SELECT COUNT(*) FROM orders WHERE created_at >= CURRENT_DATE";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
            return 0;
        } finally {
            DBUtil.close(conn, ps, rs);
        }
    }

    public List<Order> findRecent(int limit) throws SQLException {
        String sql = "SELECT * FROM orders ORDER BY created_at DESC LIMIT ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<Order> list = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapOrderRow(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public Optional<Order> findById(int orderId) throws SQLException {
        Order o = findOrderWithItems(orderId);
        return Optional.ofNullable(o);
    }
}
