package control;

import dao.ProductDAO;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@WebServlet("/admin/products")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 25 * 1024 * 1024
)
public class AdminProductServlet extends HttpServlet {
    private static final int MIN_PRODUCT_IMAGES = 3;
    private static final int MAX_PRODUCT_IMAGES = 5;
    private static final String PRODUCT_IMAGE_DIR = "/images/products/";

    private boolean requireVehicleManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        boolean canManage = session != null && Boolean.TRUE.equals(session.getAttribute("sessionAdmin"));
        if (!canManage) {
            resp.sendRedirect(req.getContextPath() + "/admin/login");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!requireVehicleManager(req, resp)) return;

        String action = req.getParameter("action");
        if (action == null) action = "list";

        ProductDAO dao = new ProductDAO();

        try {
            switch (action) {
                case "new":
                    req.getRequestDispatcher("/WEB-INF/view/admin/product-form.jsp").forward(req, resp);
                    break;

                case "edit": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Optional<Product> opt = dao.findById(id);
                    if (opt.isEmpty()) {
                        resp.sendRedirect(req.getContextPath() + "/admin/products");
                        return;
                    }
                    req.setAttribute("product", opt.get());
                    req.getRequestDispatcher("/WEB-INF/view/admin/product-form.jsp").forward(req, resp);
                    break;
                }

                case "view": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Optional<Product> opt = dao.findById(id);
                    if (opt.isEmpty()) {
                        resp.sendRedirect(req.getContextPath() + "/admin/products");
                        return;
                    }
                    req.setAttribute("product", opt.get());
                    req.getRequestDispatcher("/WEB-INF/view/admin/product-detail.jsp").forward(req, resp);
                    break;
                }

                default: {
                    List<Product> products = dao.findAll(true);
                    List<String> categories = dao.findAllCategories();
                    req.setAttribute("products", products);
                    req.setAttribute("categories", categories);
                    req.getRequestDispatcher("/WEB-INF/view/admin/products.jsp").forward(req, resp);
                }
            }
        } catch (Exception e) {
            req.setAttribute("error", "Errore: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/view/admin/products.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!requireVehicleManager(req, resp)) return;

        String action = req.getParameter("action");
        ProductDAO dao = new ProductDAO();

        try {
            switch (action == null ? "" : action) {

                case "create": {
                    Product p = buildProduct(req, null);
                    dao.create(p);
                    resp.sendRedirect(req.getContextPath() + "/admin/products?success=created");
                    break;
                }

                case "update": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Product existing = dao.findById(id).orElse(null);
                    Product p = buildProduct(req, existing);
                    p.setId(id);
                    dao.update(p);
                    resp.sendRedirect(req.getContextPath() + "/admin/products?success=updated");
                    break;
                }

                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.softDelete(id);
                    resp.sendRedirect(req.getContextPath() + "/admin/products?success=deleted");
                    break;
                }

                case "restore": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.softRestore(id);
                    resp.sendRedirect(req.getContextPath() + "/admin/products?success=restored");
                    break;
                }

                default:
                    resp.sendRedirect(req.getContextPath() + "/admin/products");
            }
        } catch (Exception e) {
            req.setAttribute("error", "Operazione non riuscita: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/view/admin/products.jsp").forward(req, resp);
        }
    }

    private Product buildProduct(HttpServletRequest req, Product existingProduct) throws IOException, ServletException {
        Product p = new Product();
        p.setName(trim(req.getParameter("name")));
        p.setDescription(trim(req.getParameter("description")));
        try { p.setPrice(new BigDecimal(req.getParameter("price"))); } catch (Exception e) { p.setPrice(BigDecimal.ZERO); }
        try { p.setStockQuantity(Integer.parseInt(req.getParameter("stockQuantity"))); } catch (Exception e) { p.setStockQuantity(0); }
        p.setCategory(trim(req.getParameter("category")));
        List<String> imagePaths = buildImagePathList(req, existingProduct, p.getName());
        p.setImageUrl(imagePaths.isEmpty() ? "" : imagePaths.get(0));
        p.setImageUrls(String.join(",", imagePaths));
        try { p.setProductionYear(Integer.parseInt(req.getParameter("productionYear"))); } catch (Exception e) { p.setProductionYear(null); }
        p.setEngine(trim(req.getParameter("engine")));
        p.setPower(trim(req.getParameter("power")));
        p.setTransmission(trim(req.getParameter("transmission")));
        p.setDrivetrain(trim(req.getParameter("drivetrain")));
        p.setAcceleration(trim(req.getParameter("acceleration")));
        p.setTopSpeed(trim(req.getParameter("topSpeed")));
        p.setFuelConsumption(trim(req.getParameter("fuelConsumption")));
        p.setDimensions(trim(req.getParameter("dimensions")));
        p.setMileage(trim(req.getParameter("mileage")));
        p.setEquipment(trim(req.getParameter("equipment")));
        return p;
    }

    private List<String> buildImagePathList(HttpServletRequest req, Product existingProduct, String productName) throws IOException, ServletException {
        List<String> imagePaths = new ArrayList<>();
        Collection<Part> parts = req.getParts();
        boolean hasNewImages = false;
        int uploadedImageCount = 0;
        for (Part part : parts) {
            if ("productImages".equals(part.getName()) && part.getSize() > 0) {
                hasNewImages = true;
                uploadedImageCount++;
            }
        }

        if (uploadedImageCount > MAX_PRODUCT_IMAGES) {
            throw new ServletException("Puoi caricare al massimo 5 immagini prodotto.");
        }

        if (!hasNewImages) {
            addImagePaths(imagePaths, trim(req.getParameter("existingImageUrls")));
            if (imagePaths.isEmpty() && existingProduct != null) {
                addImagePaths(imagePaths, existingProduct.getImageUrls());
                addImagePath(imagePaths, existingProduct.getImageUrl());
            }
        }

        for (Part part : parts) {
            if (!"productImages".equals(part.getName()) || part.getSize() == 0) {
                continue;
            }
            if (imagePaths.size() >= MAX_PRODUCT_IMAGES) {
                break;
            }
            String contentType = part.getContentType();
            if (contentType == null || !contentType.toLowerCase().startsWith("image/")) {
                continue;
            }
            addImagePath(imagePaths, saveProductImage(part));
        }

        if (imagePaths.size() < MIN_PRODUCT_IMAGES) {
            throw new ServletException("Carica almeno 3 immagini prodotto salvate in /images/products/.");
        }
        return imagePaths;
    }

    private void addImagePaths(List<String> imagePaths, String rawValue) {
        if (rawValue == null || rawValue.isBlank()) {
            return;
        }
        String cleaned = rawValue.replace("[", "")
                .replace("]", "")
                .replace("\"", "")
                .replace("'", "");
        for (String value : cleaned.split(",")) {
            addImagePath(imagePaths, value.trim());
        }
    }

    private void addImagePath(List<String> imagePaths, String path) {
        String normalizedPath = normalizeProductImagePath(path);
        if (normalizedPath != null && !imagePaths.contains(normalizedPath) && imagePaths.size() < MAX_PRODUCT_IMAGES) {
            imagePaths.add(normalizedPath);
        }
    }

    private String saveProductImage(Part part) throws IOException {
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

    private String extractExtension(String fileName) {
        int dotIndex = fileName == null ? -1 : fileName.lastIndexOf('.');
        if (dotIndex < 0 || dotIndex == fileName.length() - 1) {
            return ".jpg";
        }
        String extension = fileName.substring(dotIndex).toLowerCase();
        return extension.matches("\\.(jpg|jpeg|png|webp|gif)") ? extension : ".jpg";
    }

    private String normalizeProductImagePath(String path) {
        if (path == null || path.isBlank()) {
            return null;
        }
        String normalizedPath = path.trim().replace("\\", "/");
        if (normalizedPath.startsWith("images/products/")) {
            normalizedPath = "/" + normalizedPath;
        }
        if (!normalizedPath.startsWith(PRODUCT_IMAGE_DIR)) {
            return null;
        }
        return normalizedPath;
    }

    private String getSubmittedFileName(Part part) {
        String submittedName = part.getSubmittedFileName();
        if (submittedName == null || submittedName.isBlank()) {
            return "prodotto.jpg";
        }
        String normalizedName = submittedName.replace("\\", "/");
        int slashIndex = normalizedName.lastIndexOf('/');
        return slashIndex >= 0 ? normalizedName.substring(slashIndex + 1) : normalizedName;
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
}

