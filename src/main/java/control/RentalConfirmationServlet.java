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

@WebServlet("/rental-confirmation")
public class RentalConfirmationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Integer rentalId = (Integer) session.getAttribute("lastRentalId");
        if (rentalId == null) {
            resp.sendRedirect(req.getContextPath() + "/rentals");
            return;
        }

        try {
            RentalDAO dao = new RentalDAO();
            Rental rental = dao.findRentalById(rentalId).orElse(null);
            session.removeAttribute("lastRentalId");

            if (rental == null) {
                resp.sendRedirect(req.getContextPath() + "/rentals");
                return;
            }

            User user = (User) session.getAttribute("sessionUser");
            if (rental.getUserId() != user.getId()) {
                resp.sendRedirect(req.getContextPath() + "/rentals");
                return;
            }

            req.setAttribute("rental", rental);
            req.getRequestDispatcher("/WEB-INF/view/rental-confirmation.jsp").forward(req, resp);

        } catch (Exception e) {
            req.setAttribute("error", "Impossibile caricare la prenotazione.");
            req.getRequestDispatcher("/WEB-INF/view/rentals.jsp").forward(req, resp);
        }
    }
}
