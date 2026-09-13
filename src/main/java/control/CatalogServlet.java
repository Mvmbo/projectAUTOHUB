package control;

import dao.ProductDAO;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/catalog")
public class CatalogServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String category = req.getParameter("category");
        String keyword  = req.getParameter("keyword");
        String sortBy   = req.getParameter("sortBy");
        BigDecimal minPrice = null;
        BigDecimal maxPrice = null;
        try {
            String min = req.getParameter("minPrice");
            if (min != null && !min.isBlank()) minPrice = new BigDecimal(min);
        } catch (NumberFormatException ignored) {}
        try {
            String max = req.getParameter("maxPrice");
            if (max != null && !max.isBlank()) maxPrice = new BigDecimal(max);
        } catch (NumberFormatException ignored) {}

        try {
            ProductDAO productDAO = new ProductDAO();
            List<Product> products = productDAO.findWithFilters(category, keyword, minPrice, maxPrice, sortBy);
            List<String> categories = productDAO.findAllCategories();

            req.setAttribute("products", products);
            req.setAttribute("categories", categories);
            req.setAttribute("selectedCategory", category);
            req.setAttribute("keyword", keyword);
            req.setAttribute("sortBy", sortBy);
            req.setAttribute("minPrice", minPrice);
            req.setAttribute("maxPrice", maxPrice);
        } catch (Exception e) {
            req.setAttribute("error", "Unable to load catalog: " + e.getMessage());
        }

        req.getRequestDispatcher("/WEB-INF/view/catalog.jsp").forward(req, resp);
    }
}
