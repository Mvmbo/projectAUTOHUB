package control;

import dao.ProductDAO;
import dao.RentalDAO;
import dao.UserDAO;
import model.User;
import service.GeocodingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Optional;

@WebServlet("/dealer/dashboard")
public class DealerDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User dealer = requireDealer(req, resp);
        if (dealer == null) return;

        try {
            ProductDAO productDAO = new ProductDAO();
            RentalDAO rentalDAO = new RentalDAO();
            req.setAttribute("saleVehicles", productDAO.findByDealerId(dealer.getId()));
            req.setAttribute("rentalVehicles", rentalDAO.findVehiclesByDealerId(dealer.getId()));
        } catch (Exception e) {
            req.setAttribute("error", "Errore caricamento dashboard concessionario: " + e.getMessage());
        }

        req.getRequestDispatcher("/WEB-INF/view/dealer/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User dealer = requireDealer(req, resp);
        if (dealer == null) return;

        dealer.setPhone(trim(req.getParameter("phone")));
        dealer.setAddress(trim(req.getParameter("address")));
        dealer.setCity(trim(req.getParameter("city")));
        dealer.setPostalCode(trim(req.getParameter("postalCode")));
        dealer.setCountry(defaultIfBlank(req.getParameter("country"), "Italia"));
        dealer.setLatitude(null);
        dealer.setLongitude(null);

        try {
            new GeocodingService()
                    .geocode(dealer.getAddress(), dealer.getCity(), dealer.getPostalCode(), dealer.getCountry())
                    .ifPresent(coordinates -> {
                        dealer.setLatitude(coordinates.getLatitude());
                        dealer.setLongitude(coordinates.getLongitude());
                    });

            new UserDAO().updateAddressAndCoordinates(dealer);
            Optional<User> refreshed = new UserDAO().findById(dealer.getId());
            refreshed.ifPresent(user -> req.getSession().setAttribute("sessionUser", user));
            resp.sendRedirect(req.getContextPath() + "/dealer/dashboard?success=profile");
        } catch (Exception e) {
            req.setAttribute("error", "Aggiornamento sede non riuscito: " + e.getMessage());
            doGet(req, resp);
        }
    }

    static User requireDealer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute("sessionUser");
        if (!(sessionUser instanceof User)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        User user = (User) sessionUser;
        if (!user.isDealer()) {
            resp.sendRedirect(req.getContextPath() + (user.isAdmin() ? "/admin/dashboard" : "/home"));
            return null;
        }
        session.setAttribute("sessionDealer", Boolean.TRUE);
        return user;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String defaultIfBlank(String value, String fallback) {
        String trimmed = trim(value);
        return trimmed.isBlank() ? fallback : trimmed;
    }
}
