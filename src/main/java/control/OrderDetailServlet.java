package control;

import dao.OrderDAO;
import model.Order;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/order-detail")
public class OrderDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        try {
            int orderId = Integer.parseInt(idParam);
            OrderDAO dao = new OrderDAO();
            Order order = dao.findOrderWithItems(orderId);

            if (order == null) {
                resp.sendRedirect(req.getContextPath() + "/orders");
                return;
            }

            User user = (User) session.getAttribute("sessionUser");
            boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("sessionAdmin"));

            // Access control: only owner or admin
            if (!isAdmin && order.getUserId() != user.getId()) {
                resp.sendRedirect(req.getContextPath() + "/orders");
                return;
            }

            req.setAttribute("order", order);
            req.getRequestDispatcher("/WEB-INF/view/order-detail.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Unable to load order: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/view/order-history.jsp").forward(req, resp);
        }
    }
}
