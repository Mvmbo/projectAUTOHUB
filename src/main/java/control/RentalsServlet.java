package control;

import dao.RentalDAO;
import model.RentalVehicle;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/rentals")
public class RentalsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            RentalDAO dao = new RentalDAO();
            List<RentalVehicle> vehicles = dao.findAllVehicles();
            req.setAttribute("vehicles", vehicles);

            List<String> cities = new ArrayList<>();
            for (RentalVehicle v : vehicles) {
                if (v.getCity() != null && !cities.contains(v.getCity())) {
                    cities.add(v.getCity());
                }
            }
            req.setAttribute("cities", cities);

        } catch (Exception e) {
            req.setAttribute("error", "Impossibile caricare i veicoli: " + e.getMessage());
        }

        req.getRequestDispatcher("/WEB-INF/view/rentals.jsp").forward(req, resp);
    }
}
