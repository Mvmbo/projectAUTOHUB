package control;

import dao.RentalDAO;
import dao.UserDAO;
import model.Rental;
import model.RentalVehicle;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/rentals")
public class AdminRentalsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            RentalDAO dao = new RentalDAO();
            UserDAO userDAO = new UserDAO();

            // Get all rentals
            List<Rental> allRentals = dao.findAllRentals();
            req.setAttribute("rentals", allRentals);

            // Get active vehicles with locations for map
            List<RentalVehicle> vehicles = dao.findAllVehiclesForMap();
            req.setAttribute("vehicles", vehicles);

            // Get active rentals for map
            List<Rental> activeRentals = dao.findActiveRentals();
            req.setAttribute("activeRentals", activeRentals);
            req.setAttribute("activeRentalCarsJson", buildActiveRentalCarsJson(activeRentals));

            List<User> dealers = userDAO.findDealersWithCoordinates();
            req.setAttribute("dealers", dealers);
            req.setAttribute("dealersJson", buildDealersJson(dealers));

            // Count active rentals
            int activeCount = dao.countActiveRentals();
            req.setAttribute("activeRentalsCount", activeCount);

        } catch (Exception e) {
            req.setAttribute("error", "Errore caricamento noleggi: " + e.getMessage());
        }

        req.getRequestDispatcher("/WEB-INF/view/admin/rentals-map.jsp").forward(req, resp);
    }

    private String buildActiveRentalCarsJson(List<Rental> activeRentals) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < activeRentals.size(); i++) {
            Rental rental = activeRentals.get(i);
            RentalVehicle vehicle = rental.getVehicle();
            if (i > 0) {
                json.append(',');
            }
            json.append('{')
                    .append("\"rentalId\":").append(numberOrZero(rental.getId())).append(',')
                    .append("\"vehicleId\":").append(numberOrZero(vehicle == null ? null : vehicle.getId())).append(',')
                    .append("\"name\":\"").append(jsonEscape(vehicle == null ? "" : vehicle.getName())).append("\",")
                    .append("\"brand\":\"").append(jsonEscape(vehicle == null ? "" : vehicle.getBrand())).append("\",")
                    .append("\"userName\":\"").append(jsonEscape(rental.getUserName())).append("\",")
                    .append("\"dealerName\":\"").append(jsonEscape(vehicle == null ? "" : vehicle.getDealerName())).append("\",")
                    .append("\"city\":\"").append(jsonEscape(firstNotBlank(rental.getPickupCity(), vehicle == null ? "" : vehicle.getCity(), "Roma"))).append("\",")
                    .append("\"startDate\":\"").append(jsonEscape(rental.getStartDate() == null ? "" : rental.getStartDate().toString())).append("\",")
                    .append("\"endDate\":\"").append(jsonEscape(rental.getEndDate() == null ? "" : rental.getEndDate().toString())).append("\",")
                    .append("\"hasDealerCoordinates\":").append(hasDealerCoordinates(vehicle)).append(',')
                    .append("\"dealerLat\":").append(decimalOrNull(vehicle == null ? null : vehicle.getDealerLatitude())).append(',')
                    .append("\"dealerLng\":").append(decimalOrNull(vehicle == null ? null : vehicle.getDealerLongitude()))
                    .append('}');
        }
        json.append(']');
        return json.toString();
    }

    private String buildDealersJson(List<User> dealers) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < dealers.size(); i++) {
            User dealer = dealers.get(i);
            if (i > 0) {
                json.append(',');
            }
            json.append('{')
                    .append("\"id\":").append(dealer.getId()).append(',')
                    .append("\"name\":\"").append(jsonEscape(firstNotBlank(dealer.getFullName(), dealer.getUsername(), "Concessionario"))).append("\",")
                    .append("\"address\":\"").append(jsonEscape(firstNotBlank(dealer.getAddress(), "", "Indirizzo non indicato"))).append("\",")
                    .append("\"city\":\"").append(jsonEscape(firstNotBlank(dealer.getCity(), "", "Citta non indicata"))).append("\",")
                    .append("\"lat\":").append(decimalOrNull(dealer.getLatitude())).append(',')
                    .append("\"lng\":").append(decimalOrNull(dealer.getLongitude()))
                    .append('}');
        }
        json.append(']');
        return json.toString();
    }

    private int numberOrZero(Integer value) {
        return value == null ? 0 : value;
    }

    private boolean hasDealerCoordinates(RentalVehicle vehicle) {
        return vehicle != null && vehicle.getDealerLatitude() != null && vehicle.getDealerLongitude() != null;
    }

    private String decimalOrNull(java.math.BigDecimal value) {
        if (value != null) {
            return value.toPlainString();
        }
        return "null";
    }

    private String firstNotBlank(String first, String second, String fallback) {
        if (first != null && !first.isBlank()) {
            return first;
        }
        if (second != null && !second.isBlank()) {
            return second;
        }
        return fallback;
    }

    private String jsonEscape(String value) {
        if (value == null) {
            return "";
        }
        StringBuilder escaped = new StringBuilder();
        for (int i = 0; i < value.length(); i++) {
            char ch = value.charAt(i);
            switch (ch) {
                case '"': escaped.append("\\\""); break;
                case '\\': escaped.append("\\\\"); break;
                case '\b': escaped.append("\\b"); break;
                case '\f': escaped.append("\\f"); break;
                case '\n': escaped.append("\\n"); break;
                case '\r': escaped.append("\\r"); break;
                case '\t': escaped.append("\\t"); break;
                default:
                    if (ch < 32) {
                        escaped.append(String.format("\\u%04x", (int) ch));
                    } else {
                        escaped.append(ch);
                    }
            }
        }
        return escaped.toString();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("releaseVehicle".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                RentalDAO dao = new RentalDAO();
                dao.updateVehicleAvailability(id, true);
                dao.moveVehicleToDealer(id);
                resp.sendRedirect(req.getContextPath() + "/admin/rentals?success=released");
            } catch (Exception e) {
                req.setAttribute("error", "Rilascio veicolo non riuscito: " + e.getMessage());
                doGet(req, resp);
            }
            return;
        }

        if (!"deleteVehicle".equals(action)) {
            resp.sendRedirect(req.getContextPath() + "/admin/rentals");
            return;
        }

        try {
            int id = Integer.parseInt(req.getParameter("id"));
            new RentalDAO().softDeleteVehicle(id);
            resp.sendRedirect(req.getContextPath() + "/admin/rentals?success=deleted");
        } catch (Exception e) {
            req.setAttribute("error", "Eliminazione veicolo non riuscita: " + e.getMessage());
            doGet(req, resp);
        }
    }
}

@WebServlet("/admin/rentals/update-location")
class UpdateVehicleLocationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            int vehicleId = Integer.parseInt(req.getParameter("vehicleId"));
            double lat = Double.parseDouble(req.getParameter("lat"));
            double lng = Double.parseDouble(req.getParameter("lng"));
            String city = req.getParameter("city");

            RentalDAO dao = new RentalDAO();
            dao.updateVehicleLocation(
                vehicleId,
                java.math.BigDecimal.valueOf(lat),
                java.math.BigDecimal.valueOf(lng),
                city
            );

            resp.getWriter().write("{\"success\":true}");

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }
}
