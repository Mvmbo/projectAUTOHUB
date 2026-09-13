package control;

import dao.UserDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Optional;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession existing = req.getSession(false);
        if (existing != null && existing.getAttribute("sessionUser") != null) {
            Object sessionUser = existing.getAttribute("sessionUser");
            if (sessionUser instanceof User) {
                resp.sendRedirect(req.getContextPath() + defaultRedirectFor((User) sessionUser));
            } else {
                existing.invalidate();
                resp.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        // Pass message and redirectUrl parameters to the login page
        String message = req.getParameter("message");
        String redirectUrl = req.getParameter("redirectUrl");
        if (message != null && !message.isBlank()) {
            req.setAttribute("infoMessage", message);
        }
        if (redirectUrl != null && !redirectUrl.isBlank()) {
            req.setAttribute("redirectUrl", redirectUrl);
        }

        req.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username") == null ? "" : req.getParameter("username").trim();
        String password = req.getParameter("password") == null ? "" : req.getParameter("password");
        String redirectUrl = req.getParameter("redirectUrl");

        try {
            UserDAO dao = new UserDAO();
            Optional<User> opt = dao.authenticate(username, password);
            if (opt.isPresent()) {
                User user = opt.get();
                HttpSession session = req.getSession(true);
                session.removeAttribute("sessionAdmin");
                session.removeAttribute("sessionDealer");
                session.setAttribute("sessionUser", user);
                if (user.isAdmin()) session.setAttribute("sessionAdmin", Boolean.TRUE);
                if (user.isDealer()) session.setAttribute("sessionDealer", Boolean.TRUE);

                String safeRedirectUrl = sanitizeRedirectUrl(redirectUrl);
                if (safeRedirectUrl != null) {
                    resp.sendRedirect(req.getContextPath() + safeRedirectUrl);
                } else {
                    resp.sendRedirect(req.getContextPath() + defaultRedirectFor(user));
                }
            } else {
                req.setAttribute("error", "Nome utente o password non validi.");
                req.setAttribute("username", username);
                req.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Errore di accesso: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/view/login.jsp").forward(req, resp);
        }
    }

    private String defaultRedirectFor(User user) {
        if (user == null) {
            return "/home";
        }
        if (user.isAdmin()) {
            return "/admin/dashboard";
        }
        if (user.isDealer()) {
            return "/dealer/dashboard";
        }
        return "/home";
    }

    private String sanitizeRedirectUrl(String redirectUrl) {
        if (redirectUrl == null || redirectUrl.isBlank()) {
            return null;
        }
        String value = redirectUrl.trim();
        if (!value.startsWith("/") || value.startsWith("//") || value.contains("://")) {
            return null;
        }
        if (value.startsWith("/admin") || value.startsWith("/dealer")) {
            return null;
        }
        return value;
    }
}
