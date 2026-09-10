package dao;

import model.Product;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class ProductDAO {

    private boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        for (int i = 1; i <= metaData.getColumnCount(); i++) {
            if (columnName.equalsIgnoreCase(metaData.getColumnLabel(i))) {
                return true;
            }
        }
        return false;
    }

    private boolean tableHasColumn(String tableName, String columnName) throws SQLException {
        Connection conn = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            DatabaseMetaData metaData = conn.getMetaData();
            rs = metaData.getColumns(conn.getCatalog(), null, tableName, columnName);
            return rs.next();
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException ignored) {}
            }
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    private String getOptionalString(ResultSet rs, String columnName) throws SQLException {
        return hasColumn(rs, columnName) ? rs.getString(columnName) : null;
    }

    private Integer getOptionalInteger(ResultSet rs, String columnName) throws SQLException {
        if (!hasColumn(rs, columnName)) {
            return null;
        }
        int value = rs.getInt(columnName);
        return rs.wasNull() ? null : value;
    }

    private String normalizeProductImagePaths(String rawValue) {
        if (rawValue == null || rawValue.isBlank()) {
            return "";
        }
        List<String> imagePaths = new ArrayList<>();
        String cleaned = rawValue.replace("[", "")
                .replace("]", "")
                .replace("\"", "")
                .replace("'", "");
        for (String value : cleaned.split(",")) {
            String normalizedPath = normalizeProductImagePath(value);
            if (normalizedPath != null && !normalizedPath.isBlank() && !imagePaths.contains(normalizedPath)) {
                imagePaths.add(normalizedPath);
            }
        }
        return String.join(",", imagePaths);
    }

    private String normalizeProductImagePath(String path) {
        if (path == null || path.isBlank()) {
            return "";
        }
        String normalizedPath = path.trim().replace("\\", "/");
        if (normalizedPath.startsWith("images/products/")) {
            normalizedPath = "/" + normalizedPath;
        }
        return normalizedPath.startsWith("/images/products/") ? normalizedPath : "";
    }
    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getBigDecimal("price"));
        p.setStockQuantity(rs.getInt("stock_quantity"));
        p.setCategory(rs.getString("category"));
        p.setImageUrl(normalizeProductImagePath(rs.getString("image_url")));
        p.setImageUrls(normalizeProductImagePaths(getOptionalString(rs, "image_urls")));
        p.setProductionYear(getOptionalInteger(rs, "production_year"));
        p.setEngine(getOptionalString(rs, "engine"));
        p.setPower(getOptionalString(rs, "power"));
        p.setTransmission(getOptionalString(rs, "transmission"));
        p.setDrivetrain(getOptionalString(rs, "drivetrain"));
        p.setAcceleration(getOptionalString(rs, "acceleration"));
        p.setTopSpeed(getOptionalString(rs, "top_speed"));
        p.setFuelConsumption(getOptionalString(rs, "fuel_consumption"));
        p.setDimensions(getOptionalString(rs, "dimensions"));
        p.setMileage(getOptionalString(rs, "mileage"));
        p.setEquipment(getOptionalString(rs, "equipment"));
        p.setDealerId(getOptionalInteger(rs, "dealer_id"));
        p.setDealerName(getOptionalString(rs, "dealer_name"));
        p.setDeleted(rs.getBoolean("is_deleted"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) p.setCreatedAt(ts.toLocalDateTime());
        ts = rs.getTimestamp("updated_at");
        if (ts != null) p.setUpdatedAt(ts.toLocalDateTime());
        return p;
    }

    public List<Product> findAll(boolean includeDeleted) throws SQLException {
        boolean hasDealerId = tableHasColumn("products", "dealer_id");
        String select = hasDealerId
                ? "SELECT p.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name FROM products p LEFT JOIN users u ON p.dealer_id = u.id"
                : "SELECT * FROM products";
        String sql = includeDeleted
                ? select + (hasDealerId ? " ORDER BY p.created_at DESC" : " ORDER BY created_at DESC")
                : select + (hasDealerId ? " WHERE p.is_deleted = FALSE ORDER BY p.created_at DESC" : " WHERE is_deleted = FALSE ORDER BY created_at DESC");
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<Product> list = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public Optional<Product> findById(int id) throws SQLException {
        boolean hasDealerId = tableHasColumn("products", "dealer_id");
        String sql = hasDealerId
                ? "SELECT p.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name FROM products p LEFT JOIN users u ON p.dealer_id = u.id WHERE p.id = ?"
                : "SELECT * FROM products WHERE id = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) return Optional.of(mapRow(rs));
            return Optional.empty();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
    }

    public List<Product> findByCategory(String category) throws SQLException {
        boolean hasDealerId = tableHasColumn("products", "dealer_id");
        String sql = hasDealerId
                ? "SELECT p.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name FROM products p LEFT JOIN users u ON p.dealer_id = u.id WHERE p.category = ? AND p.is_deleted = FALSE ORDER BY p.created_at DESC"
                : "SELECT * FROM products WHERE category = ? AND is_deleted = FALSE ORDER BY created_at DESC";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<Product> list = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, category);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public List<Product> search(String keyword) throws SQLException {
        boolean hasDealerId = tableHasColumn("products", "dealer_id");
        String sql = hasDealerId
                ? "SELECT p.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name FROM products p LEFT JOIN users u ON p.dealer_id = u.id WHERE p.is_deleted = FALSE AND (LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ?) ORDER BY p.name"
                : "SELECT * FROM products WHERE is_deleted = FALSE AND (LOWER(name) LIKE ? OR LOWER(description) LIKE ?) ORDER BY name";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<Product> list = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            String like = "%" + keyword.toLowerCase() + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public List<String> findAllCategories() throws SQLException {
        String sql = "SELECT DISTINCT category FROM products WHERE is_deleted = FALSE AND category IS NOT NULL ORDER BY category";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<String> cats = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) cats.add(rs.getString("category"));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return cats;
    }

    public List<Product> findWithFilters(String category, String keyword,
                                         BigDecimal minPrice, BigDecimal maxPrice,
                                         String sortBy) throws SQLException {
        boolean hasDealerId = tableHasColumn("products", "dealer_id");
        StringBuilder sb = new StringBuilder(hasDealerId
                ? "SELECT p.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name FROM products p LEFT JOIN users u ON p.dealer_id = u.id WHERE p.is_deleted = FALSE"
                : "SELECT * FROM products WHERE is_deleted = FALSE");
        List<Object> params = new ArrayList<>();

        if (category != null && !category.isBlank()) {
            sb.append(hasDealerId ? " AND p.category = ?" : " AND category = ?");
            params.add(category);
        }
        if (keyword != null && !keyword.isBlank()) {
            sb.append(hasDealerId ? " AND (LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ?)" : " AND (LOWER(name) LIKE ? OR LOWER(description) LIKE ?)");
            String like = "%" + keyword.toLowerCase() + "%";
            params.add(like);
            params.add(like);
        }
        if (minPrice != null) {
            sb.append(hasDealerId ? " AND p.price >= ?" : " AND price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sb.append(hasDealerId ? " AND p.price <= ?" : " AND price <= ?");
            params.add(maxPrice);
        }

        switch (sortBy == null ? "" : sortBy) {
            case "price_asc":  sb.append(hasDealerId ? " ORDER BY p.price ASC" : " ORDER BY price ASC");  break;
            case "price_desc": sb.append(hasDealerId ? " ORDER BY p.price DESC" : " ORDER BY price DESC"); break;
            case "name_asc":   sb.append(hasDealerId ? " ORDER BY p.name ASC" : " ORDER BY name ASC");   break;
            default:           sb.append(hasDealerId ? " ORDER BY p.created_at DESC" : " ORDER BY created_at DESC"); break;
        }

        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<Product> list = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sb.toString());
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof String)     ps.setString(i + 1, (String) v);
                else if (v instanceof BigDecimal) ps.setBigDecimal(i + 1, (BigDecimal) v);
            }
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public Product create(Product product) throws SQLException {
        boolean hasDealerId = tableHasColumn("products", "dealer_id");
        boolean hasExtendedFields = tableHasColumn("products", "production_year");
        String sql = hasExtendedFields
                ? "INSERT INTO products (name, description, price, stock_quantity, category, image_url, image_urls, " +
                  "production_year, engine, power, transmission, drivetrain, acceleration, top_speed, " +
                  "fuel_consumption, dimensions, mileage, equipment" + (hasDealerId ? ", dealer_id" : "") + ") " +
                  "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?" + (hasDealerId ? ",?" : "") + ")"
                : "INSERT INTO products (name, description, price, stock_quantity, category, image_url" +
                  (hasDealerId ? ", dealer_id" : "") + ") VALUES (?,?,?,?,?,?" + (hasDealerId ? ",?" : "") + ")";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, product.getName());
            ps.setString(2, product.getDescription());
            ps.setBigDecimal(3, product.getPrice());
            ps.setInt(4, product.getStockQuantity());
            ps.setString(5, product.getCategory());
            ps.setString(6, product.getImageUrl());
            int index = 7;
            if (hasExtendedFields) {
                ps.setString(index++, product.getImageUrls());
                if (product.getProductionYear() == null) ps.setNull(index++, Types.INTEGER); else ps.setInt(index++, product.getProductionYear());
                ps.setString(index++, product.getEngine());
                ps.setString(index++, product.getPower());
                ps.setString(index++, product.getTransmission());
                ps.setString(index++, product.getDrivetrain());
                ps.setString(index++, product.getAcceleration());
                ps.setString(index++, product.getTopSpeed());
                ps.setString(index++, product.getFuelConsumption());
                ps.setString(index++, product.getDimensions());
                ps.setString(index++, product.getMileage());
                ps.setString(index++, product.getEquipment());
            }
            if (hasDealerId) {
                if (product.getDealerId() == null) ps.setNull(index, Types.INTEGER); else ps.setInt(index, product.getDealerId());
            }
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) product.setId(rs.getInt(1));
            return product;
        } finally {
            DBUtil.close(conn, ps, rs);
        }
    }

    public boolean update(Product product) throws SQLException {
        boolean hasExtendedFields = tableHasColumn("products", "production_year");
        String sql = hasExtendedFields
                ? "UPDATE products SET name=?, description=?, price=?, stock_quantity=?, category=?, image_url=?, image_urls=?, " +
                  "production_year=?, engine=?, power=?, transmission=?, drivetrain=?, acceleration=?, top_speed=?, " +
                  "fuel_consumption=?, dimensions=?, mileage=?, equipment=?, updated_at=NOW() WHERE id=?"
                : "UPDATE products SET name=?, description=?, price=?, stock_quantity=?, category=?, image_url=?, updated_at=NOW() WHERE id=?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, product.getName());
            ps.setString(2, product.getDescription());
            ps.setBigDecimal(3, product.getPrice());
            ps.setInt(4, product.getStockQuantity());
            ps.setString(5, product.getCategory());
            ps.setString(6, product.getImageUrl());
            int index = 7;
            if (hasExtendedFields) {
                ps.setString(index++, product.getImageUrls());
                if (product.getProductionYear() == null) ps.setNull(index++, Types.INTEGER); else ps.setInt(index++, product.getProductionYear());
                ps.setString(index++, product.getEngine());
                ps.setString(index++, product.getPower());
                ps.setString(index++, product.getTransmission());
                ps.setString(index++, product.getDrivetrain());
                ps.setString(index++, product.getAcceleration());
                ps.setString(index++, product.getTopSpeed());
                ps.setString(index++, product.getFuelConsumption());
                ps.setString(index++, product.getDimensions());
                ps.setString(index++, product.getMileage());
                ps.setString(index++, product.getEquipment());
            }
            ps.setInt(index, product.getId());
            return ps.executeUpdate() > 0;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    public boolean softDelete(int id) throws SQLException {
        String sql = "UPDATE products SET is_deleted = TRUE, updated_at = NOW() WHERE id = ?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    public List<Product> findNewest(int limit) throws SQLException {
        boolean hasDealerId = tableHasColumn("products", "dealer_id");
        String sql = hasDealerId
                ? "SELECT p.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name FROM products p LEFT JOIN users u ON p.dealer_id = u.id WHERE p.is_deleted = FALSE ORDER BY p.created_at DESC LIMIT ?"
                : "SELECT * FROM products WHERE is_deleted = FALSE ORDER BY created_at DESC LIMIT ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<Product> list = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM products WHERE is_deleted = FALSE";
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

    public List<Product> findByDealerId(int dealerId) throws SQLException {
        if (!tableHasColumn("products", "dealer_id")) {
            return new ArrayList<>();
        }
        String sql = "SELECT p.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name FROM products p LEFT JOIN users u ON p.dealer_id = u.id WHERE p.dealer_id = ? ORDER BY p.created_at DESC";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<Product> list = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, dealerId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public boolean softDeleteForDealer(int id, int dealerId) throws SQLException {
        if (!tableHasColumn("products", "dealer_id")) {
            return false;
        }
        String sql = "UPDATE products SET is_deleted = TRUE, updated_at = NOW() WHERE id = ? AND dealer_id = ?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.setInt(2, dealerId);
            return ps.executeUpdate() > 0;
        } finally {
            DBUtil.close(conn, ps);
        }
    }
}
