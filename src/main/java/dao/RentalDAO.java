package dao;

import model.Rental;
import model.RentalVehicle;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class RentalDAO {

    private RentalVehicle mapVehicle(ResultSet rs) throws SQLException {
        RentalVehicle v = new RentalVehicle();
        v.setId(rs.getInt("id"));
        v.setName(rs.getString("name"));
        v.setBrand(rs.getString("brand"));
        v.setDescription(rs.getString("description"));
        v.setPricePerDay(rs.getBigDecimal("price_per_day"));
        v.setCategory(rs.getString("category"));
        v.setImageUrl(rs.getString("image_url"));
        v.setImageUrls(parseImageUrls(
                hasColumn(rs, "image_urls") ? rs.getString("image_urls") : null,
                v.getImageUrl()
        ));
        v.setAvailable(rs.getBoolean("is_available"));
        v.setLatitude(rs.getBigDecimal("latitude"));
        v.setLongitude(rs.getBigDecimal("longitude"));
        v.setCity(rs.getString("city"));
        if (hasColumn(rs, "dealer_id")) {
            int dealerId = rs.getInt("dealer_id");
            v.setDealerId(rs.wasNull() ? null : dealerId);
        }
        if (hasColumn(rs, "dealer_name")) {
            v.setDealerName(rs.getString("dealer_name"));
        }
        if (hasColumn(rs, "dealer_address")) {
            v.setDealerAddress(rs.getString("dealer_address"));
        }
        if (hasColumn(rs, "dealer_city")) {
            v.setDealerCity(rs.getString("dealer_city"));
        }
        if (hasColumn(rs, "dealer_latitude")) {
            v.setDealerLatitude(rs.getBigDecimal("dealer_latitude"));
        }
        if (hasColumn(rs, "dealer_longitude")) {
            v.setDealerLongitude(rs.getBigDecimal("dealer_longitude"));
        }
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) v.setCreatedAt(ts.toLocalDateTime());
        return v;
    }

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

    private Rental mapRental(ResultSet rs) throws SQLException {
        Rental r = new Rental();
        r.setId(rs.getInt("id"));
        r.setUserId(rs.getInt("user_id"));
        r.setVehicleId(rs.getInt("vehicle_id"));
        Date startDate = rs.getDate("start_date");
        Date endDate = rs.getDate("end_date");
        if (startDate != null) r.setStartDate(startDate.toLocalDate());
        if (endDate != null) r.setEndDate(endDate.toLocalDate());
        r.setPickupCity(rs.getString("pickup_city"));
        r.setPickupAddress(rs.getString("pickup_address"));
        r.setTotalDays(rs.getInt("total_days"));
        r.setTotalAmount(rs.getBigDecimal("total_amount"));
        r.setStatus(rs.getString("status"));
        r.setNotes(rs.getString("notes"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) r.setCreatedAt(ts.toLocalDateTime());
        return r;
    }

    // ===================== VEHICLE QUERIES =====================

    public List<RentalVehicle> findAllVehicles() throws SQLException {
        boolean hasDealerId = tableHasColumn("rental_vehicles", "dealer_id");
        String sql = hasDealerId
                ? "SELECT rv.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name, u.address AS dealer_address, u.city AS dealer_city, u.latitude AS dealer_latitude, u.longitude AS dealer_longitude FROM rental_vehicles rv LEFT JOIN users u ON rv.dealer_id = u.id WHERE rv.is_available = 1 ORDER BY rv.price_per_day ASC"
                : "SELECT * FROM rental_vehicles WHERE is_available = 1 ORDER BY price_per_day ASC";
        List<RentalVehicle> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapVehicle(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public List<RentalVehicle> findVehiclesByCity(String city) throws SQLException {
        boolean hasDealerId = tableHasColumn("rental_vehicles", "dealer_id");
        String sql = hasDealerId
                ? "SELECT rv.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name, u.address AS dealer_address, u.city AS dealer_city, u.latitude AS dealer_latitude, u.longitude AS dealer_longitude FROM rental_vehicles rv LEFT JOIN users u ON rv.dealer_id = u.id WHERE rv.is_available = 1 AND rv.city LIKE ?"
                : "SELECT * FROM rental_vehicles WHERE is_available = 1 AND city LIKE ?";
        List<RentalVehicle> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, "%" + city + "%");
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapVehicle(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public Optional<RentalVehicle> findVehicleById(int id) throws SQLException {
        boolean hasDealerId = tableHasColumn("rental_vehicles", "dealer_id");
        String sql = hasDealerId
                ? "SELECT rv.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name, u.address AS dealer_address, u.city AS dealer_city, u.latitude AS dealer_latitude, u.longitude AS dealer_longitude FROM rental_vehicles rv LEFT JOIN users u ON rv.dealer_id = u.id WHERE rv.id = ?"
                : "SELECT * FROM rental_vehicles WHERE id = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) return Optional.of(mapVehicle(rs));
            return Optional.empty();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
    }

    public List<RentalVehicle> findAllVehiclesForMap() throws SQLException {
        boolean hasDealerId = tableHasColumn("rental_vehicles", "dealer_id");
        String sql = hasDealerId
                ? "SELECT rv.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name, u.address AS dealer_address, u.city AS dealer_city, u.latitude AS dealer_latitude, u.longitude AS dealer_longitude FROM rental_vehicles rv LEFT JOIN users u ON rv.dealer_id = u.id WHERE rv.latitude IS NOT NULL ORDER BY rv.city"
                : "SELECT * FROM rental_vehicles WHERE latitude IS NOT NULL ORDER BY city";
        List<RentalVehicle> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapVehicle(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public RentalVehicle createVehicle(RentalVehicle vehicle) throws SQLException {
        boolean hasDealerId = tableHasColumn("rental_vehicles", "dealer_id");
        boolean hasImageUrls = tableHasColumn("rental_vehicles", "image_urls");
        String sql = "INSERT INTO rental_vehicles (name, brand, description, price_per_day, category, image_url" +
                (hasImageUrls ? ", image_urls" : "") + ", is_available, latitude, longitude, city" +
                (hasDealerId ? ", dealer_id" : "") + ") " +
                "VALUES (?,?,?,?,?,?" + (hasImageUrls ? ",?" : "") + ",?,?,?,?" + (hasDealerId ? ",?" : "") + ")";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, vehicle.getName());
            ps.setString(2, vehicle.getBrand());
            ps.setString(3, vehicle.getDescription());
            ps.setBigDecimal(4, vehicle.getPricePerDay());
            ps.setString(5, vehicle.getCategory());
            ps.setString(6, vehicle.getImageUrl());
            int index = 7;
            if (hasImageUrls) {
                ps.setString(index++, joinImageUrls(vehicle.getImageUrls()));
            }
            ps.setBoolean(index++, vehicle.isAvailable());
            ps.setBigDecimal(index++, vehicle.getLatitude());
            ps.setBigDecimal(index++, vehicle.getLongitude());
            ps.setString(index++, vehicle.getCity());
            if (hasDealerId) {
                if (vehicle.getDealerId() == null) ps.setNull(index, Types.INTEGER); else ps.setInt(index, vehicle.getDealerId());
            }
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) vehicle.setId(rs.getInt(1));
            return vehicle;
        } finally {
            DBUtil.close(conn, ps, rs);
        }
    }

    public List<RentalVehicle> findVehiclesByDealerId(int dealerId) throws SQLException {
        if (!tableHasColumn("rental_vehicles", "dealer_id")) {
            return new ArrayList<>();
        }
        String sql = "SELECT rv.*, COALESCE(NULLIF(u.full_name, ''), u.username) AS dealer_name, u.address AS dealer_address, u.city AS dealer_city, u.latitude AS dealer_latitude, u.longitude AS dealer_longitude FROM rental_vehicles rv LEFT JOIN users u ON rv.dealer_id = u.id WHERE rv.dealer_id = ? ORDER BY rv.created_at DESC";
        List<RentalVehicle> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, dealerId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapVehicle(rs));
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public boolean softDeleteVehicle(int id) throws SQLException {
        String sql = "UPDATE rental_vehicles SET is_available = FALSE, latitude = NULL, longitude = NULL WHERE id = ?";
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

    public boolean softDeleteVehicleForDealer(int id, int dealerId) throws SQLException {
        if (!tableHasColumn("rental_vehicles", "dealer_id")) {
            return false;
        }
        String sql = "UPDATE rental_vehicles SET is_available = FALSE, latitude = NULL, longitude = NULL WHERE id = ? AND dealer_id = ?";
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

    public boolean updateVehicleForDealer(RentalVehicle vehicle, int dealerId) throws SQLException {
        if (!tableHasColumn("rental_vehicles", "dealer_id")) {
            return false;
        }
        boolean hasImageUrls = tableHasColumn("rental_vehicles", "image_urls");
        String sql = "UPDATE rental_vehicles SET name=?, brand=?, description=?, price_per_day=?, category=?, image_url=?, " +
                (hasImageUrls ? "image_urls=?, " : "") +
                "is_available=?, latitude=?, longitude=?, city=? WHERE id=? AND dealer_id=?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, vehicle.getName());
            ps.setString(2, vehicle.getBrand());
            ps.setString(3, vehicle.getDescription());
            ps.setBigDecimal(4, vehicle.getPricePerDay());
            ps.setString(5, vehicle.getCategory());
            ps.setString(6, vehicle.getImageUrl());
            int index = 7;
            if (hasImageUrls) {
                ps.setString(index++, joinImageUrls(vehicle.getImageUrls()));
            }
            ps.setBoolean(index++, vehicle.isAvailable());
            ps.setBigDecimal(index++, vehicle.getLatitude());
            ps.setBigDecimal(index++, vehicle.getLongitude());
            ps.setString(index++, vehicle.getCity());
            ps.setInt(index++, vehicle.getId());
            ps.setInt(index, dealerId);
            return ps.executeUpdate() > 0;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    