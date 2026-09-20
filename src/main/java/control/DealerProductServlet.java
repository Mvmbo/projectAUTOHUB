package control;

import dao.ProductDAO;
import model.Product;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

@WebServlet("/dealer/sale-vehicles")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 25 * 1024 * 1024
)
public class DealerProductServlet extends HttpServlet {
    private static final int MIN_VEHICLE_IMAGES = 3;
    private static final int MAX_VEHICLE_IMAGES = 5;
    private static final String PRODUCT_IMAGE_DIR = "/images/products/";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User dealer = DealerDashboardServlet.requireDealer(req, resp);
        if (dealer == null) return;

        String action = req.getParameter("action");
        try {
            ProductDAO dao = new ProductDAO();
            if ("new".equals(action)) {
                req.setAttribute("mode", "sale");
                req.getRequestDispatcher("/WEB-INF/view/dealer/vehicle-form.jsp").forward(req, resp);
                return;
            }
            if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Product product = dao.findById(id).orElse(null);
                if (product == null || product.getDealerId() == null || product.getDealerId() != dealer.getId()) {
                    resp.sendRedirect(req.getContextPath() + "/dealer/sale-vehicles?success=not-owned");
                    return;
                }
                req.setAttribute("mode", "sale");
                req.setAttribute("saleVehicle", product);
                req.getRequestDispatcher("/WEB-INF/view/dealer/vehicle-form.jsp").forward(req, resp);
                return;
            }
            req.setAttribute("saleVehicles", dao.findByDealerId(dealer.getId()));
        } catch (Exception e) {
            req.setAttribute("error", "Errore caricamento veicoli in vendita: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/view/dealer/sale-vehicles.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User dealer = DealerDashboardServlet.requireDealer(req, resp);
        if (dealer == null) return;

        String action = req.getParameter("action");
        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean deleted = new ProductDAO().softDeleteForDealer(id, dealer.getId());
                resp.sendRedirect(req.getContextPath() + "/dealer/sale-vehicles?success=" + (deleted ? "deleted" : "not-owned"));
                return;
            }

            Product existingProduct = null;
            if ("update".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                existingProduct = new ProductDAO().findById(id).orElse(null);
                if (existingProduct == null || existingProduct.getDealerId() == null || existingProduct.getDealerId() != dealer.getId()) {
                    resp.sendRedirect(req.getContextPath() + "/dealer/sale-vehicles?success=not-owned");
                    return;
                }
            }

            Product p = new Product();
            if (existingProduct != null) {
                p.setId(existingProduct.getId());
            }
            p.setName(trim(req.getParameter("name")));
            p.setDescription(trim(req.getParameter("description")));
            p.setCategory(defaultIfBlank(req.getParameter("category"), "Auto Concessionario"));
            List<String> imagePaths = buildImagePathList(req, p.getName(), existingProduct);
            p.setImageUrl(imagePaths.get(0));
            p.setImageUrls(String.join(",", imagePaths));
            p.setDealerId(dealer.getId());
            try { p.setPrice(new BigDecimal(req.getParameter("price"))); } catch (Exception e) { p.setPrice(BigDecimal.ZERO); }
            try { p.setStockQuantity(Integer.parseInt(req.getParameter("stockQuantity"))); } catch (Exception e) { p.setStockQuantity(1); }
            try { p.setProductionYear(Integer.parseInt(req.getParameter("productionYear"))); } catch (Exception e) { p.setProductionYear(null); }
            p.setEngine(trim(req.getParameter("engine")));
            p.setPower(trim(req.getParameter("power")));
            p.setTransmission(trim(req.getParameter("transmission")));
            p.setDrivetrain(trim(req.getParameter("drivetrain")));
            p.setMileage(trim(req.getParameter("mileage")));
            p.setAcceleration(trim(req.getParameter("acceleration")));
            p.setTopSpeed(trim(req.getParameter("topSpeed")));
            p.setFuelConsumption(trim(req.getParameter("fuelConsumption")));
            p.setDimensions(trim(req.getParameter("dimensions")));
            p.setEquipment(trim(req.getParameter("equipment")));

            if (existingProduct == null) {
                new ProductDAO().create(p);
                resp.sendRedirect(req.getContextPath() + "/dealer/sale-vehicles?success=created");
            } else {
                new ProductDAO().update(p);
                resp.sendRedirect(req.getContextPath() + "/dealer/sale-vehicles?success=updated");
            }
        } catch (Exception e) {
            req.setAttribute("mode", "sale");
            req.setAttribute("error", "Inserimento non riuscito: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/view/dealer/vehicle-form.jsp").forward(req, resp);
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String defaultIfBlank(String value, String fallback) {
        String trimmed = trim(value);
        return trimmed.isBlank() ? fallback : trimmed;
    }

    