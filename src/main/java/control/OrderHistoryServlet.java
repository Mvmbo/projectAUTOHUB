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
import java.util.Collections;
import java.util.List;

@WebServlet("/orders")
public class OrderHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login?redirectUrl=/orders");
            return;
        }

        Object sessionUser = session.getAttribute("sessionUser");
        if (!(sessionUser instanceof User)) {
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login?redirectUrl=/orders");
            return;
        }

        User user = (User) sessionUser;
        try {
            OrderDAO dao = new OrderDAO();
            List<Order> orders = dao.findByUserId(user.getId());
            req.setAttribute("orders", orders != null ? orders : Collections.emptyList());
        } catch (Exception e) {
            req.setAttribute("orders", Collections.emptyList());
            req.setAttribute("error", "Non e' stato possibile caricare i tuoi ordini. Riprova tra qualche minuto.");
        }

        req.getRequestDispatcher("/WEB-INF/view/order-history.jsp").forward(req, resp);
    }
}
