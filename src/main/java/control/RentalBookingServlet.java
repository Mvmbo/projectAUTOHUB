package control;

import dao.RentalDAO;
import model.Rental;
import model.RentalVehicle;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@WebServlet("/rental-booking")
public class RentalBookingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login?redirectUrl=/rentals");
            return;
        }

        String vehicleIdParam = req.getParameter("vehicleId");
        if (vehicleIdParam == null || vehicleIdParam.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/rentals");
            return;
        }

        try {
            int vehicleId = Integer.parseInt(vehicleIdParam);
            RentalDAO dao = new RentalDAO();
            Optional<RentalVehicle> opt = dao.findVehicleById(vehicleId);

            if (opt.isEmpty() || !opt.get().isAvailable()) {
                resp.sendRedirect(req.getContextPath() + "/rentals");
                return;
            }

            req.setAttribute("vehicle", opt.get());
            req.getRequestDispatcher("/WEB-INF/view/rental-booking.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/rentals");
        } catch (Exception e) {
            req.setAttribute("error", "Errore durante il caricamento del veicolo.");
            req.getRequestDispatcher("/WEB-INF/view/rentals.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User user = (User) session.getAttribute("sessionUser");

        String vehicleIdParam = req.getParameter("vehicleId");
        String startDateParam = req.getParameter("startDate");
        String endDateParam = req.getParameter("endDate");
        String notes = req.getParameter("notes");

        Map<String, String> errors = new HashMap<>();

        if (vehicleIdParam == null || vehicleIdParam.isBlank())
            errors.put("vehicleId", "Veicolo non specificato.");
        if (startDateParam == null || startDateParam.isBlank())
            errors.put("startDate", "Data inizio obbligatoria.");
        if (endDateParam == null || endDateParam.isBlank())
            errors.put("endDate", "Data fine obbligatoria.");

        LocalDate startDate = null;
        LocalDate endDate = null;
        try {
            if (startDateParam != null && !startDateParam.isBlank())
                startDate = LocalDate.parse(startDateParam);
            if (endDateParam != null && !endDateParam.isBlank())
                endDate = LocalDate.parse(endDateParam);
        } catch (Exception e) {
            errors.put("dates", "Formato date non valido.");
        }

        if (startDate != null && endDate != null) {
            if (startDate.isBefore(LocalDate.now()))
                errors.put("startDate", "La data inizio non può essere nel passato.");
            if (endDate.isBefore(startDate))
                errors.put("endDate", "La data fine deve essere successiva alla data inizio.");
        }

        if (!errors.isEmpty()) {
            try {
                int vehicleId = Integer.parseInt(vehicleIdParam);
                RentalDAO dao = new RentalDAO();
                req.setAttribute("vehicle", dao.findVehicleById(vehicleId).orElse(null));
            } catch (Exception ignored) {}
            req.setAttribute("errors", errors);
            req.getRequestDispatcher("/WEB-INF/view/rental-booking.jsp").forward(req, resp);
            return;
        }

        try {
            int vehicleId = Integer.parseInt(vehicleIdParam);
            RentalDAO dao = new RentalDAO();
            Optional<RentalVehicle> opt = dao.findVehicleById(vehicleId);

            if (opt.isEmpty() || !opt.get().isAvailable()) {
                resp.sendRedirect(req.getContextPath() + "/rentals");
                return;
            }

            RentalVehicle vehicle = opt.get();
            String pickupCity = resolvePickupCity(vehicle);
            String pickupAddress = resolvePickupAddress(vehicle);
            long totalDays = ChronoUnit.DAYS.between(startDate, endDate) + 1;
            BigDecimal totalAmount = vehicle.getPricePerDay().multiply(BigDecimal.valueOf(totalDays));

            Rental rental = new Rental();
            rental.setUserId(user.getId());
            rental.setVehicleId(vehicleId);
            rental.setStartDate(startDate);
            rental.setEndDate(endDate);
            rental.setPickupCity(pickupCity);
            rental.setPickupAddress(pickupAddress);
            rental.setTotalDays((int) totalDays);
            rental.setTotalAmount(totalAmount);
            rental.setStatus("active");
            rental.setNotes(notes);

            dao.createRental(rental);
            dao.moveVehicleToDealer(vehicleId);
            dao.updateVehicleAvailability(vehicleId, false);
            session.setAttribute("lastRentalId", rental.getId());

            resp.sendRedirect(req.getContextPath() + "/rental-confirmation");

        } catch (Exception e) {
            req.setAttribute("error", "Prenotazione fallita: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/view/rental-booking.jsp").forward(req, resp);
        }
    }

    private String resolvePickupCity(RentalVehicle vehicle) {
        if (isNotBlank(vehicle.getDealerCity())) {
            return vehicle.getDealerCity().trim();
        }
        if (isNotBlank(vehicle.getCity())) {
            return vehicle.getCity().trim();
        }
        return "Sede concessionario";
    }

    private String resolvePickupAddress(RentalVehicle vehicle) {
        if (isNotBlank(vehicle.getDealerAddress())) {
            return vehicle.getDealerAddress().trim();
        }
        if (isNotBlank(vehicle.getDealerName())) {
            return vehicle.getDealerName().trim();
        }
        return "Posizione attuale del veicolo";
    }

    private boolean isNotBlank(String value) {
        return value != null && !value.isBlank();
    }
}
