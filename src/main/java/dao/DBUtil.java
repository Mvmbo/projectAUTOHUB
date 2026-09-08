package dao;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DBUtil {

    private static DataSource dataSource;

    private static DataSource getDataSource() throws SQLException {
        if (dataSource == null) {
            try {
                Context initCtx = new InitialContext();
                Context envCtx = (Context) initCtx.lookup("java:comp/env");
                dataSource = (DataSource) envCtx.lookup("jdbc/autohub");
            } catch (NamingException e) {
                throw new SQLException("Lookup DataSource non riuscito: " + e.getMessage(), e);
            }
        }
        return dataSource;
    }

    public static Connection getConnection() throws SQLException {
        return getDataSource().getConnection();
    }

    public static void close(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs   != null) { try { rs.close();   } catch (SQLException ignored) {} }
        if (ps   != null) { try { ps.close();   } catch (SQLException ignored) {} }
        if (conn != null) { try { conn.close();  } catch (SQLException ignored) {} }
    }

    public static void close(Connection conn, PreparedStatement ps) {
        close(conn, ps, null);
    }
}
