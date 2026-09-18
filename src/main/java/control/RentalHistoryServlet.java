package control;

import dao.RentalDAO;
import model.Rental;
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

@WebServlet("/my-rentals")
public class RentalHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login?redirectUrl=/my-rentals");
            return;
        }

        Object sessionUser = session.getAttribute("sessionUser");
        if (!(sessionUser instanceof User)) {
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login?redirectUrl=/my-rentals");
            return;
        }

        User user = (User) sessionUser;
        try {
            RentalDAO dao = new RentalDAO();
            List<Rental> rentals = dao.findRentalsByUserId(user.getId());
            req.setAttribute("rentals", rentals != null ? rentals : Collections.emptyList());
        } catch (Exception e) {
            req.setAttribute("rentals", Collections.emptyList());
            req.setAttribute("error", "Non e' stato possibile caricare i tuoi noleggi. Riprova tra qualche minuto.");
        }

        req.getRequestDispatcher("/WEB-INF/view/rental-history.jsp").forward(req, resp);
    }
}
