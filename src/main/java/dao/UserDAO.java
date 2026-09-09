package dao;

import model.User;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class UserDAO {

    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(password.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setPhone(rs.getString("phone"));
        u.setAddress(rs.getString("address"));
        u.setCity(rs.getString("city"));
        u.setPostalCode(rs.getString("postal_code"));
        u.setCountry(rs.getString("country"));
        u.setLatitude(rs.getBigDecimal("latitude"));
        u.setLongitude(rs.getBigDecimal("longitude"));
        u.setRole(rs.getString("role"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) u.setCreatedAt(ts.toLocalDateTime());
        return u;
    }

    public Optional<User> findByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM users WHERE username = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            rs = ps.executeQuery();
            if (rs.next()) return Optional.of(mapRow(rs));
            return Optional.empty();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
    }

    public Optional<User> findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) return Optional.of(mapRow(rs));
            return Optional.empty();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
    }

    public Optional<User> findById(int id) throws SQLException {
        String sql = "SELECT * FROM users WHERE id = ?";
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

    public List<User> findAll() throws SQLException {
        String sql = "SELECT * FROM users ORDER BY id";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<User> list = new ArrayList<>();
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

    public List<User> findDealersWithCoordinates() throws SQLException {
        String sql = "SELECT * FROM users " +
                "WHERE role IN ('dealer', 'concessionario') " +
                "AND latitude IS NOT NULL AND longitude IS NOT NULL " +
                "ORDER BY COALESCE(NULLIF(full_name, ''), username)";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<User> list = new ArrayList<>();
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

    public boolean create(User user) throws SQLException {
        String sql = "INSERT INTO users (username, email, password_hash, full_name, phone, address, city, postal_code, country, latitude, longitude, role) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getAddress());
            ps.setString(7, user.getCity());
            ps.setString(8, user.getPostalCode());
            ps.setString(9, user.getCountry());
            ps.setBigDecimal(10, user.getLatitude());
            ps.setBigDecimal(11, user.getLongitude());
            ps.setString(12, user.getRole() != null ? user.getRole() : "customer");

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                return false;
            }

            rs = ps.getGeneratedKeys();
            if (rs.next()) user.setId(rs.getInt(1));
            return true;
        } finally {
            DBUtil.close(conn, ps, rs);
        }
    }

    public boolean updateAddressAndCoordinates(User user) throws SQLException {
        String sql = "UPDATE users SET phone = ?, address = ?, city = ?, postal_code = ?, country = ?, latitude = ?, longitude = ? WHERE id = ?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getPhone());
            ps.setString(2, user.getAddress());
            ps.setString(3, user.getCity());
            ps.setString(4, user.getPostalCode());
            ps.setString(5, user.getCountry());
            ps.setBigDecimal(6, user.getLatitude());
            ps.setBigDecimal(7, user.getLongitude());
            ps.setInt(8, user.getId());
            return ps.executeUpdate() > 0;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    public Optional<User> authenticate(String username, String password) throws SQLException {
        String hash = hashPassword(password);
        String sql = "SELECT * FROM users WHERE username = ? AND password_hash = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, hash);
            rs = ps.executeQuery();
            if (rs.next()) return Optional.of(mapRow(rs));
            return Optional.empty();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
    }
}
