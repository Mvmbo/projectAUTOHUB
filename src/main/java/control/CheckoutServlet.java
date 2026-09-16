package control;

import dao.OrderDAO;
import dao.ProductDAO;
import model.Cart;
import model.CartItem;
import model.Order;
import model.Product;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login?redirectUrl=/checkout");
            return;
        }
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null || cart.getTotalItems() == 0) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }
        req.setAttribute("cart", cart);
        req.getRequestDispatcher("/WEB-INF/view/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("sessionUser");
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null || cart.getTotalItems() == 0) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        String shippingName    = trim(req.getParameter("shippingName"));
        String shippingAddress = trim(req.getParameter("shippingAddress"));
        String shippingCity    = trim(req.getParameter("shippingCity"));
        String shippingPostal  = trim(req.getParameter("shippingPostal"));
        String shippingCountry = trim(req.getParameter("shippingCountry"));
        String paymentMethod   = trim(req.getParameter("paymentMethod"));

        Map<String, String> errors = new HashMap<>();
        if (shippingName.isEmpty())    errors.put("shippingName", "Nome completo obbligatorio.");
        if (shippingAddress.isEmpty()) errors.put("shippingAddress", "Indirizzo obbligatorio.");
        if (shippingCity.isEmpty())    errors.put("shippingCity", "Città obbligatoria.");
        if (shippingPostal.isEmpty())  errors.put("shippingPostal", "CAP obbligatorio.");
        if (shippingCountry.isEmpty()) errors.put("shippingCountry", "Paese obbligatorio.");
        if (paymentMethod.isEmpty())   errors.put("paymentMethod", "Metodo di pagamento obbligatorio.");

        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            req.setAttribute("cart", cart);
            req.setAttribute("formData", buildFormData(shippingName, shippingAddress, shippingCity, shippingPostal, shippingCountry, paymentMethod));
            req.getRequestDispatcher("/WEB-INF/view/checkout.jsp").forward(req, resp);
            return;
        }

        try {
            ProductDAO productDAO = new ProductDAO();
            for (CartItem item : cart.getItems()) {
                if (item == null || item.getProduct() == null) {
                    continue;
                }
                Optional<Product> live = productDAO.findById(item.getProduct().getId());
                if (live.isEmpty() || live.get().isDeleted()) {
                    req.setAttribute("error", "Un prodotto nel carrello non è più disponibile.");
                    req.setAttribute("cart", cart);
                    req.setAttribute("formData", buildFormData(shippingName, shippingAddress, shippingCity, shippingPostal, shippingCountry, paymentMethod));
                    req.getRequestDispatcher("/WEB-INF/view/checkout.jsp").forward(req, resp);
                    return;
                }
                int available = live.get().getStockQuantity();
                if (item.getQuantity() > available) {
                    req.setAttribute("error", "Quantità non disponibile per \"" + live.get().getName()
                            + "\" (disponibili: " + available + ").");
                    req.setAttribute("cart", cart);
                    req.setAttribute("formData", buildFormData(shippingName, shippingAddress, shippingCity, shippingPostal, shippingCountry, paymentMethod));
                    req.getRequestDispatcher("/WEB-INF/view/checkout.jsp").forward(req, resp);
                    return;
                }
            }

            Order order = new Order();
            order.setUserId(user.getId());
            order.setStatus("confirmed");
            order.setShippingName(shippingName);
            order.setShippingAddress(shippingAddress);
            order.setShippingCity(shippingCity);
            order.setShippingPostal(shippingPostal);
            order.setShippingCountry(shippingCountry);
            order.setPaymentMethod(paymentMethod);
            order.setTotalAmount(cart.getTotalAmount());

            OrderDAO orderDAO = new OrderDAO();
            orderDAO.createOrder(order, cart.getItems());

            // Empty cart and store order id
            cart.clear();
            session.setAttribute("cart", cart);
            session.setAttribute("lastOrderId", order.getId());

            resp.sendRedirect(req.getContextPath() + "/order-confirmation");
        } catch (Exception e) {
            req.setAttribute("error", "Ordine non riuscito: " + e.getMessage());
            req.setAttribute("cart", cart);
            req.getRequestDispatcher("/WEB-INF/view/checkout.jsp").forward(req, resp);
        }
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }

    private Map<String, String> buildFormData(String name, String addr, String city, String postal, String country, String payment) {
        Map<String, String> m = new HashMap<>();
        m.put("shippingName", name); m.put("shippingAddress", addr);
        m.put("shippingCity", city); m.put("shippingPostal", postal);
        m.put("shippingCountry", country); m.put("paymentMethod", payment);
        return m;
    }
}
