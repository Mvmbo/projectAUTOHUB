package control;

import dao.RentalDAO;
import model.RentalVehicle;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Optional;

@WebServlet("/rental-detail")
public class RentalVehicleDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/rentals");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            Optional<RentalVehicle> vehicle = new RentalDAO().findVehicleById(id);
            if (vehicle.isEmpty() || !vehicle.get().isAvailable()) {
                resp.sendRedirect(req.getContextPath() + "/rentals");
                return;
            }

            req.setAttribute("vehicle", vehicle.get());
            req.getRequestDispatcher("/WEB-INF/view/rental-detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/rentals");
        } catch (Exception e) {
            req.setAttribute("error", "Impossibile caricare i dettagli del veicolo.");
            req.getRequestDispatcher("/WEB-INF/view/rentals.jsp").forward(req, resp);
        }
    }
}
