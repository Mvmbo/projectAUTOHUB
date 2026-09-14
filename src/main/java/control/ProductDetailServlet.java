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
        addSpec(highlights, "bi-speedometer2", "Potenza", valueOrDefault(product.getPower(), inferPower(product)));
        addSpec(highlights, "bi-stopwatch", "0-100 km/h", valueOrDefault(product.getAcceleration(), inferAcceleration(product)));
        addSpec(highlights, "bi-lightning-charge", "Velocita'", valueOrDefault(product.getTopSpeed(), inferTopSpeed(product)));
        addSpec(highlights, "bi-calendar3", "Anno", product.getProductionYear() != null ? product.getProductionYear().toString() : inferYear(product));
        return highlights;
    }

    private List<Map<String, String>> buildTechnicalSpecs(Product product) {
        List<Map<String, String>> specs = new ArrayList<>();
        addSpec(specs, "bi-cpu", "Motore", valueOrDefault(product.getEngine(), inferEngine(product)));
        addSpec(specs, "bi-gear", "Cambio", valueOrDefault(product.getTransmission(), inferTransmission(product)));
        addSpec(specs, "bi-diagram-3", "Trazione", valueOrDefault(product.getDrivetrain(), inferDrivetrain(product)));
        addSpec(specs, "bi-fuel-pump", "Consumi", valueOrDefault(product.getFuelConsumption(), inferConsumption(product)));
        addSpec(specs, "bi-signpost-2", "Chilometraggio", valueOrDefault(product.getMileage(), inferMileage(product)));
        addSpec(specs, "bi-upc-scan", "Codice veicolo", "AH-" + product.getId());
        return specs;
    }

    private List<Map<String, String>> buildDimensionSpecs(Product product) {
        List<Map<String, String>> specs = new ArrayList<>();
        addSpec(specs, "bi-arrows-angle-expand", "Dimensioni", valueOrDefault(product.getDimensions(), inferDimensions(product)));
        addSpec(specs, "bi-box-seam", "Disponibilita'", product.getStockQuantity() > 0 ? product.getStockQuantity() + " unita' disponibili" : "Non disponibile");
        addSpec(specs, "bi-tags", "Categoria", valueOrDefault(product.getCategory(), "Automotive premium"));
        addSpec(specs, "bi-shield-check", "Garanzia", inferWarranty(product));
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

        if (!items.isEmpty()) {
            return items;
        }

        if (isVehicle(product)) {
            items.add("Interni in pelle premium con cuciture a contrasto");
            items.add("Sistema infotainment con navigazione e connettivita' smartphone");
            items.add("Fari LED adattivi e pacchetto assistenza alla guida");
            items.add("Impianto frenante sportivo e assetto performance");
            items.add("Controllo qualita' AutoHUB con verifica documentale");
        } else {
            items.add("Materiali selezionati per uso stradale e sportivo");
            items.add("Compatibilita' verificata dal team tecnico AutoHUB");
            items.add("Finitura premium coerente con vetture di fascia alta");
            items.add("Assistenza pre e post vendita inclusa");
        }
        return items;
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

    private String valueOrDefault(String value, String fallback) {
        return value != null && !value.isBlank() ? value : fallback;
    }

    private String safeLower(String value) {
        return value == null ? "" : value.toLowerCase();
    }

    private boolean isVehicle(Product product) {
        String category = safeLower(product.getCategory());
        return category.contains("super") || category.contains("auto") || category.contains("gran turismo") || category.contains("suv");
    }

    private String inferPower(Product product) {
        String name = safeLower(product.getName());
        if (name.contains("ferrari")) return "670 CV";
        if (name.contains("lamborghini")) return "640 CV";
        if (name.contains("porsche")) return "520 CV";
        if (isVehicle(product)) return "450-700 CV";
        return "Configurazione performance";
    }

    private String inferAcceleration(Product product) {
        if (!isVehicle(product)) return "Non applicabile";
        String name = safeLower(product.getName());
        if (name.contains("porsche")) return "3,2 s";
        if (name.contains("ferrari") || name.contains("lamborghini")) return "2,9 s";
        return "3,8 s";
    }

    private String inferTopSpeed(Product product) {
        if (!isVehicle(product)) return "Non applicabile";
        String name = safeLower(product.getName());
        if (name.contains("porsche")) return "296 km/h";
        if (name.contains("ferrari") || name.contains("lamborghini")) return "325 km/h";
        return "280 km/h";
    }

    private String inferYear(Product product) {
        return isVehicle(product) ? "2023" : "2026";
    }

    private String inferEngine(Product product) {
        String name = safeLower(product.getName());
        if (name.contains("ferrari")) return "V8 biturbo 3.9 L";
        if (name.contains("lamborghini")) return "V10 aspirato 5.2 L";
        if (name.contains("porsche")) return "6 cilindri boxer 4.0 L";
        if (isVehicle(product)) return "Motorizzazione sportiva ad alte prestazioni";
        return "Componente automotive premium";
    }

    private String inferTransmission(Product product) {
        return isVehicle(product) ? "Automatico doppia frizione" : "Non applicabile";
    }

    private String inferDrivetrain(Product product) {
        String name = safeLower(product.getName());
        if (name.contains("lamborghini")) return "Integrale AWD";
        if (name.contains("porsche")) return "Posteriore";
        return isVehicle(product) ? "Posteriore / AWD" : "Non applicabile";
    }

    private String inferConsumption(Product product) {
        return isVehicle(product) ? "11,4-13,8 l/100 km ciclo combinato" : "Non applicabile";
    }

    private String inferMileage(Product product) {
        return isVehicle(product) ? "Da verificare in fase di trattativa" : "Nuovo";
    }

    private String inferDimensions(Product product) {
        return isVehicle(product) ? "Circa 4,55 m x 1,95 m x 1,20 m" : "Specifiche variabili per modello";
    }

    private String inferWarranty(Product product) {
        return isVehicle(product) ? "12 mesi con controlli AutoHUB" : "24 mesi sul prodotto";
    }
}
