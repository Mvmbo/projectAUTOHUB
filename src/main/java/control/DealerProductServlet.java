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

    private List<String> buildImagePathList(HttpServletRequest req, String vehicleName, Product existingProduct) throws IOException, ServletException {
        List<String> imagePaths = new ArrayList<>();
        Collection<Part> parts = req.getParts();
        int uploadedImageCount = 0;

        for (Part part : parts) {
            if ("vehicleImages".equals(part.getName()) && part.getSize() > 0) {
                uploadedImageCount++;
            }
        }

        if (uploadedImageCount == 0 && existingProduct != null) {
            addLocalImagePaths(imagePaths, existingProduct.getImageUrls());
            addLocalImagePath(imagePaths, existingProduct.getImageUrl());
            if (imagePaths.size() < MIN_VEHICLE_IMAGES) {
                throw new ServletException("Carica almeno 3 immagini del veicolo salvate sul server.");
            }
            return imagePaths;
        }

        if (uploadedImageCount < MIN_VEHICLE_IMAGES) {
            throw new ServletException("Carica almeno 3 immagini del veicolo.");
        }
        if (uploadedImageCount > MAX_VEHICLE_IMAGES) {
            throw new ServletException("Puoi caricare al massimo 5 immagini del veicolo.");
        }

        for (Part part : parts) {
            if (!"vehicleImages".equals(part.getName()) || part.getSize() == 0) {
                continue;
            }
            String contentType = part.getContentType();
            if (contentType == null || !contentType.toLowerCase().startsWith("image/")) {
                continue;
            }
            imagePaths.add(saveVehicleImage(part));
        }

        if (imagePaths.size() < MIN_VEHICLE_IMAGES) {
            throw new ServletException("Carica almeno 3 immagini valide del veicolo.");
        }
        return imagePaths;
    }

    private void addLocalImagePaths(List<String> imagePaths, String rawValue) {
        if (rawValue == null || rawValue.isBlank()) {
            return;
        }
        String cleaned = rawValue.replace("[", "")
                .replace("]", "")
                .replace("\"", "")
                .replace("'", "");
        for (String value : cleaned.split(",")) {
            addLocalImagePath(imagePaths, value.trim());
        }
    }

    private void addLocalImagePath(List<String> imagePaths, String path) {
        if (path == null || path.isBlank()) {
            return;
        }
        String normalizedPath = path.trim().replace("\\", "/");
        if (normalizedPath.startsWith("images/products/")) {
            normalizedPath = "/" + normalizedPath;
        }
        if (normalizedPath.startsWith(PRODUCT_IMAGE_DIR) && !imagePaths.contains(normalizedPath) && imagePaths.size() < MAX_VEHICLE_IMAGES) {
            imagePaths.add(normalizedPath);
        }
    }

    private String saveVehicleImage(Part part) throws IOException {
        String submittedName = getSubmittedFileName(part);
        String extension = extractExtension(submittedName);
        String fileName = UUID.randomUUID() + extension;
        byte[] imageBytes;
        try (InputStream inputStream = part.getInputStream()) {
            imageBytes = inputStream.readAllBytes();
        }
        for (Path uploadDir : resolveProductImageDirectories()) {
            Files.createDirectories(uploadDir);
            Files.write(uploadDir.resolve(fileName), imageBytes);
        }
        return PRODUCT_IMAGE_DIR + fileName;
    }

    private List<Path> resolveProductImageDirectories() {
        List<Path> directories = new ArrayList<>();

        // 1) Webapp deployata (es. target/autohub/images/products) — file serviti da Tomcat
        String deployedPath = getServletContext().getRealPath(PRODUCT_IMAGE_DIR);
        if (deployedPath != null && !deployedPath.isBlank()) {
            Path deployDir = Path.of(deployedPath).toAbsolutePath().normalize();
            addUploadDirectory(directories, deployDir);

            // 2) Se il deploy è sotto target/, copia anche in src/main/webapp/images/products
            String normalized = deployDir.toString().replace('\\', '/');
            int targetIdx = normalized.indexOf("/target/");
            if (targetIdx >= 0) {
                Path srcDir = Path.of(normalized.substring(0, targetIdx))
                        .resolve("src/main/webapp/images/products")
                        .toAbsolutePath()
                        .normalize();
                addUploadDirectory(directories, srcDir);
            }
        }

        // 3) Fallback se non c'è /target/ nel path (altro tipo di deploy)
        addUploadDirectory(
                directories,
                Path.of(System.getProperty("user.dir"), "src", "main", "webapp", "images", "products")
                        .toAbsolutePath()
                        .normalize()
        );

        return directories;
    }

    private void addUploadDirectory(List<Path> directories, Path directory) {
        if (!directories.contains(directory)) {
            directories.add(directory);
        }
    }

    private String getSubmittedFileName(Part part) {
        String submittedName = part.getSubmittedFileName();
        if (submittedName == null || submittedName.isBlank()) {
            return "veicolo.jpg";
        }
        String normalizedName = submittedName.replace("\\", "/");
        int slashIndex = normalizedName.lastIndexOf('/');
        return slashIndex >= 0 ? normalizedName.substring(slashIndex + 1) : normalizedName;
    }

    private String extractExtension(String fileName) {
        int dotIndex = fileName == null ? -1 : fileName.lastIndexOf('.');
        if (dotIndex < 0 || dotIndex == fileName.length() - 1) {
            return ".jpg";
        }
        String extension = fileName.substring(dotIndex).toLowerCase();
        return extension.matches("\\.(jpg|jpeg|png|webp|gif)") ? extension : ".jpg";
    }

}
