package control;

import dao.OrderDAO;
import dao.ProductDAO;
import dao.UserDAO;
import model.Order;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int productCount = 0;
        int todayOrders = 0;
        int userCount = 0;
        List<Order> recentOrders = Collections.emptyList();
        List<String> loadErrors = new ArrayList<>();

        ProductDAO productDAO = new ProductDAO();
        OrderDAO orderDAO = new OrderDAO();
        UserDAO userDAO = new UserDAO();

        try {
            productCount = Math.max(0, productDAO.countAll());
        } catch (Exception e) {
            loadErrors.add("prodotti: " + safeMessage(e));
        }

        try {
            todayOrders = Math.max(0, orderDAO.countToday());
        } catch (Exception e) {
            loadErrors.add("ordini di oggi: " + safeMessage(e));
        }

        try {
            List<User> users = userDAO.findAll();
            userCount = users == null ? 0 : users.size();
        } catch (Exception e) {
            loadErrors.add("utenti: " + safeMessage(e));
        }

        try {
            List<Order> orders = orderDAO.findRecent(5);
            recentOrders = orders == null ? Collections.emptyList() : orders;
        } catch (Exception e) {
            loadErrors.add("ordini recenti: " + safeMessage(e));
        }

        req.setAttribute("productCount", productCount);
        req.setAttribute("todayOrders", todayOrders);
        req.setAttribute("userCount", userCount);
        req.setAttribute("recentOrders", recentOrders);

        if (!loadErrors.isEmpty()) {
            req.setAttribute("error", "Dashboard caricata con valori di default per: " + String.join("; ", loadErrors));
        }

        try {
            req.getRequestDispatcher("/WEB-INF/view/admin/dashboard.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Errore rendering dashboard admin: " + safeMessage(e), e);
        }
    }

    private String safeMessage(Exception e) {
        if (e == null || e.getMessage() == null || e.getMessage().isBlank()) {
            return "errore non specificato";
        }
        return e.getMessage();
    }
}
