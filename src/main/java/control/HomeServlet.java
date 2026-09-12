package control;

import dao.ProductDAO;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/home", ""})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            ProductDAO productDAO = new ProductDAO();
            List<Product> featured = productDAO.findNewest(4);
            req.setAttribute("featuredProducts", featured);
        } catch (Exception e) {
            req.setAttribute("featuredProducts", java.util.Collections.emptyList());
        }
        req.getRequestDispatcher("/WEB-INF/view/home.jsp").forward(req, resp);
    }
}
