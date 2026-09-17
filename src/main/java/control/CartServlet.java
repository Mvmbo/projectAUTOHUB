package control;

import dao.ProductDAO;
import model.Cart;
import model.CartItem;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.text.NumberFormat;
import java.util.Locale;
import java.util.Optional;

/**
 * CartServlet - Gestisce le operazioni relative al carrello sia per utenti autenticati che per utenti ospiti.
 * Il carrello è memorizzato nella sessione ed è accessibile a tutti.
 * L'autenticazione è richiesta solo al momento del checkout, non per visualizzare o modificare il carrello.
 */
@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static String formatPrice(BigDecimal amount) {
        if (amount == null) {
            amount = BigDecimal.ZERO;
        }
        NumberFormat nf = NumberFormat.getNumberInstance(Locale.ITALY);
        nf.setMinimumFractionDigits(2);
        nf.setMaximumFractionDigits(2);
        return "€ " + nf.format(amount);
    }

    /**
     * Recupera o crea un carrello dalla sessione.
     */
    private Cart getOrCreateCart(HttpSession session) {
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }
        return cart;
    }

    /**
     * Rimuove le voci del carrello prive di dati del prodotto (ad es. dopo la deserializzazione della sessione).
     */
    private void sanitizeCart(Cart cart) {
        cart.getItemsMap().entrySet().removeIf(entry ->
                entry.getValue() == null || entry.getValue().getProduct() == null);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            HttpSession session = req.getSession(true);
            Cart cart = getOrCreateCart(session);
            sanitizeCart(cart);
            session.setAttribute("cart", cart);
            req.setAttribute("cart", cart);
        } catch (Exception e) {
            getServletContext().log("Errore caricamento carrello", e);
            req.setAttribute("errorMessage", "Si è verificato un errore durante il caricamento del carrello.");
            req.setAttribute("cart", new Cart());
        }

        req.getRequestDispatcher("/WEB-INF/view/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            HttpSession session = req.getSession(true);
            Cart cart = getOrCreateCart(session);
            sanitizeCart(cart);

            String action = req.getParameter("action");
            if (action == null || action.isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Azione non specificata\"}");
                return;
            }

            switch (action) {

                case "add": {
                    try {
                        int productId = Integer.parseInt(req.getParameter("productId"));
                        int qty = 1;
                        String qtyParam = req.getParameter("quantity");
                        if (qtyParam != null && !qtyParam.isEmpty()) {
                            qty = Integer.parseInt(qtyParam);
                        }
                        if (qty < 1) {
                            qty = 1;
                        }

                        ProductDAO dao = new ProductDAO();
                        Optional<Product> opt = dao.findById(productId);

                        if (opt.isEmpty() || opt.get().isDeleted()) {
                            resp.getWriter().write("{\"success\":false,\"message\":\"Prodotto non trovato\"}");
                            return;
                        }

                        Product product = opt.get();
                        int stock = product.getStockQuantity();
                        CartItem existing = cart.getCartItem(productId);
                        int alreadyInCart = existing != null ? existing.getQuantity() : 0;
                        int totalRequested = alreadyInCart + qty;
                        if (totalRequested > stock) {
                            resp.getWriter().write("{\"success\":false,\"message\":\"Quantità non disponibile in magazzino (disponibili: "
                                    + stock + ")\"}");
                            return;
                        }

                        cart.addItem(product, qty);
                        session.setAttribute("cart", cart);
                        resp.getWriter().write("{\"success\":true,\"cartCount\":" + cart.getTotalItems()
                                + ",\"message\":\"Aggiunto al carrello\"}");
                    } catch (NumberFormatException e) {
                        resp.getWriter().write("{\"success\":false,\"message\":\"ID prodotto non valido\"}");
                    }
                    break;
                }

                