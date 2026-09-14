package control;

import dao.UserDAO;
import model.User;
import service.GeocodingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (req.getSession(false) != null && req.getSession(false).getAttribute("sessionUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username    = trim(req.getParameter("username"));
        String email       = trim(req.getParameter("email"));
        String password    = req.getParameter("password");
        String confirm     = req.getParameter("confirmPassword");
        String fullName    = trim(req.getParameter("fullName"));
        String phone       = trim(req.getParameter("phone"));
        String address     = trim(req.getParameter("address"));
        String city        = trim(req.getParameter("city"));
        String postalCode  = trim(req.getParameter("postalCode"));
        String country     = trim(req.getParameter("country"));
        String accountType = trim(req.getParameter("accountType"));
        if (!"dealer".equals(accountType)) accountType = "customer";

        Map<String, String> errors = new HashMap<>();

        // Server-side validation
        if (username.isEmpty())  errors.put("username", "Username obbligatorio.");
        else if (!username.matches("[a-zA-Z0-9_]{3,30}")) errors.put("username", "Username: 3-30 caratteri, solo lettere, numeri e underscore.");

        if (email.isEmpty()) errors.put("email", "Indirizzo email obbligatorio.");
        else if (!email.matches("^[\\w.+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$")) errors.put("email", "Indirizzo email non valido.");

        if (password == null || password.length() < 8) errors.put("password", "La password deve avere almeno 8 caratteri.");
        else if (!password.equals(confirm)) errors.put("confirmPassword", "Le password non coincidono.");

        if (fullName.isEmpty()) errors.put("fullName", "Nome completo obbligatorio.");

        if (errors.isEmpty()) {
            try {
                UserDAO dao = new UserDAO();
                if (dao.findByUsername(username).isPresent()) errors.put("username", "Username già in uso.");
                if (dao.findByEmail(email).isPresent())       errors.put("email", "Email già registrata.");

                if (errors.isEmpty()) {
                    User user = new User();
                    user.setUsername(username);
                    user.setEmail(email);
                    user.setPasswordHash(UserDAO.hashPassword(password));
                    user.setFullName(fullName);
                    user.setPhone(phone);
                    user.setAddress(address);
                    user.setCity(city);
                    user.setPostalCode(postalCode);
                    user.setCountry(country);
                    user.setRole(accountType);

                    if (user.isDealer()) {
                        geocodeDealerAddress(user);
                    }

                    dao.create(user);

                    req.getSession().setAttribute("sessionUser", user);
                    if (user.isDealer()) {
                        req.getSession().setAttribute("sessionDealer", Boolean.TRUE);
                        resp.sendRedirect(req.getContextPath() + "/dealer/dashboard");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/home");
                    }
                    return;
                }
            } catch (Exception e) {
                errors.put("general", "Registrazione non riuscita: " + e.getMessage());
            }
        }

        // Return with errors
        req.setAttribute("errors", errors);
        req.setAttribute("formData", buildFormData(username, email, fullName, phone, address, city, postalCode, country, accountType));
        req.getRequestDispatcher("/WEB-INF/view/register.jsp").forward(req, resp);
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private Map<String, String> buildFormData(String username, String email, String fullName,
                                               String phone, String address, String city,
                                               String postalCode, String country, String accountType) {
        Map<String, String> m = new HashMap<>();
        m.put("username", username); m.put("email", email); m.put("fullName", fullName);
        m.put("phone", phone); m.put("address", address); m.put("city", city);
        m.put("postalCode", postalCode); m.put("country", country);
        m.put("accountType", accountType);
        return m;
    }

    private void geocodeDealerAddress(User user) {
        if (user.getAddress() == null || user.getAddress().isBlank()
                || user.getCity() == null || user.getCity().isBlank()) {
            return;
        }

        try {
            GeocodingService geocodingService = new GeocodingService();
            geocodingService.geocode(user.getAddress(), user.getCity(), user.getPostalCode(), user.getCountry())
                    .ifPresent(coordinates -> {
                        user.setLatitude(coordinates.getLatitude());
                        user.setLongitude(coordinates.getLongitude());
                    });
        } catch (Exception ignored) {
            // La registrazione resta valida anche se Nominatim non risponde.
        }
    }
}
