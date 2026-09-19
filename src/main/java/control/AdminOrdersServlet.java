package control;

import dao.OrderDAO;
import dao.UserDAO;
import model.Order;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet("/admin/orders")
public class AdminOrdersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("sessionAdmin"))) {
            resp.sendRedirect(req.getContextPath() + "/admin/login");
            return;
        }

        LocalDate fromDate = null;
        LocalDate toDate   = null;
        Integer   userId   = null;

        try {
            String from = req.getParameter("fromDate");
            if (from != null && !from.isBlank()) fromDate = LocalDate.parse(from);
        } catch (DateTimeParseException ignored) {}

        try {
            String to = req.getParameter("toDate");
            if (to != null && !to.isBlank()) toDate = LocalDate.parse(to);
        } catch (DateTimeParseException ignored) {}

        try {
            String uid = req.getParameter("userId");
            if (uid != null && !uid.isBlank()) userId = Integer.parseInt(uid);
        } catch (NumberFormatException ignored) {}

        try {
            OrderDAO orderDAO = new OrderDAO();
            UserDAO  userDAO  = new UserDAO();

            List<Order> orders = orderDAO.findWithFilters(fromDate, toDate, userId);
            List<User>  users  = userDAO.findAll();

            req.setAttribute("orders", orders);
            req.setAttribute("users", users);
            req.setAttribute("fromDate", fromDate);
            req.setAttribute("toDate", toDate);
            req.setAttribute("filterUserId", userId);
        } catch (Exception e) {
            req.setAttribute("error", "Errore caricamento ordini: " + e.getMessage());
        }

        req.getRequestDispatcher("/WEB-INF/view/admin/orders.jsp").forward(req, resp);
    }
}
