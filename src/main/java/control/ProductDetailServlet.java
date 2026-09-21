package control;

import dao.ProductDAO;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@WebServlet("/product")
public class ProductDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/catalog");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            ProductDAO dao = new ProductDAO();
            Optional<Product> opt = dao.findById(id);

            if (opt.isEmpty() || opt.get().isDeleted()) {
                resp.sendRedirect(req.getContextPath() + "/catalog");
                return;
            }

            Product product = opt.get();
            req.setAttribute("product", product);
            req.setAttribute("productImages", buildProductImages(product));
            req.setAttribute("performanceHighlights", buildPerformanceHighlights(product));
            req.setAttribute("technicalSpecs", buildTechnicalSpecs(product));
            req.setAttribute("dimensionSpecs", buildDimensionSpecs(product));
            req.setAttribute("equipmentItems", buildEquipmentItems(product));
            req.getRequestDispatcher("/WEB-INF/view/product-detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/catalog");
        } catch (Exception e) {
            req.setAttribute("error", "Impossibile caricare il prodotto.");
            req.getRequestDispatcher("/WEB-INF/view/catalog.jsp").forward(req, resp);
        }
    }

    private List<String> buildProductImages(Product product) {
        List<String> images = new ArrayList<>();
        addImage(images, product.getImageUrl());

        String imageUrls = product.getImageUrls();
        if (imageUrls != null && !imageUrls.isBlank()) {
            String cleaned = imageUrls.replace("[", "")
                    .replace("]", "")
                    .replace("\"", "")
                    .replace("'", "");
            for (String url : cleaned.split(",")) {
                addImage(images, url.trim());
            }
        }
        return images;
    }

    private List<Map<String, String>> buildPerformanceHighlights(Product product) {
        List<Map<String, String>> highlights = new ArrayList<>();
        addSpec(highlights, "bi-speedometer2", "Potenza", nd(product.getPower()));
        addSpec(highlights, "bi-stopwatch", "0-100 km/h", nd(product.getAcceleration()));
        addSpec(highlights, "bi-lightning-charge", "Velocita'", nd(product.getTopSpeed()));
        addSpec(highlights, "bi-calendar3", "Anno", product.getProductionYear() != null ? product.getProductionYear().toString() : "N/D");
        return highlights;
    }

    private List<Map<String, String>> buildTechnicalSpecs(Product product) {
        List<Map<String, String>> specs = new ArrayList<>();
        addSpec(specs, "bi-cpu", "Motore", nd(product.getEngine()));
        addSpec(specs, "bi-gear", "Cambio", nd(product.getTransmission()));
        addSpec(specs, "bi-diagram-3", "Trazione", nd(product.getDrivetrain()));
        addSpec(specs, "bi-fuel-pump", "Consumi", nd(product.getFuelConsumption()));
        addSpec(specs, "bi-signpost-2", "Chilometraggio", nd(product.getMileage()));
        addSpec(specs, "bi-upc-scan", "Codice veicolo", "AH-" + product.getId());
        return specs;
    }

    private List<Map<String, String>> buildDimensionSpecs(Product product) {
        List<Map<String, String>> specs = new ArrayList<>();
        addSpec(specs, "bi-arrows-angle-expand", "Dimensioni", nd(product.getDimensions()));
        addSpec(specs, "bi-box-seam", "Disponibilita'", product.getStockQuantity() > 0 ? product.getStockQuantity() + " unita' disponibili" : "Non disponibile");
        addSpec(specs, "bi-tags", "Categoria", nd(product.getCategory()));
        return specs;
    }

    private List<String> buildEquipmentItems(Product product) {
        List<String> items = new ArrayList<>();
        if (product.getEquipment() != null && !product.getEquipment().isBlank()) {
            for (String item : product.getEquipment().split(";")) {
                if (!item.isBlank()) {
                    items.add(item.trim());
                }
            }
        }
        return items;
    }

    private String nd(String value) {
        return value != null && !value.isBlank() ? value : "N/D";
    }

    private void addImage(List<String> images, String url) {
        String normalizedUrl = normalizeProductImagePath(url);
        if (normalizedUrl != null && !images.contains(normalizedUrl)) {
            images.add(normalizedUrl);
        }
    }

    private String normalizeProductImagePath(String path) {
        if (path == null || path.isBlank()) {
            return null;
        }
        String normalizedPath = path.trim().replace("\\", "/");
        if (normalizedPath.startsWith("images/products/")) {
            normalizedPath = "/" + normalizedPath;
        }
        return normalizedPath.startsWith("/images/products/") ? normalizedPath : null;
    }

    private void addSpec(List<Map<String, String>> specs, String icon, String label, String value) {
        Map<String, String> spec = new LinkedHashMap<>();
        spec.put("icon", icon);
        spec.put("label", label);
        spec.put("value", value);
        specs.add(spec);
    }
}

