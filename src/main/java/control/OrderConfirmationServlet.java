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

@WebServlet("/order-confirmation")
public class OrderConfirmationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Integer orderId = (Integer) session.getAttribute("lastOrderId");
        if (orderId == null) {
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        try {
            OrderDAO dao = new OrderDAO();
            Order order = dao.findOrderWithItems(orderId);
            session.removeAttribute("lastOrderId");

            if (order == null) {
                resp.sendRedirect(req.getContextPath() + "/orders");
                return;
            }

            User user = (User) session.getAttribute("sessionUser");
            if (order.getUserId() != user.getId()) {
                resp.sendRedirect(req.getContextPath() + "/orders");
                return;
            }

            req.setAttribute("order", order);
            req.getRequestDispatcher("/WEB-INF/view/order-confirmation.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Unable to load order.");
            req.getRequestDispatcher("/WEB-INF/view/order-history.jsp").forward(req, resp);
        }
    }
}
