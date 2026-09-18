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

@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && Boolean.TRUE.equals(session.getAttribute("sessionAdmin"))) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }
        Object sessionUser = session == null ? null : session.getAttribute("sessionUser");
        boolean dealerLoggedIn = Boolean.TRUE.equals(session == null ? null : session.getAttribute("sessionDealer"))
                || (sessionUser instanceof User && ((User) sessionUser).isDealer());
        if (dealerLoggedIn) {
            resp.sendRedirect(req.getContextPath() + "/dealer/dashboard");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/view/admin/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String username = req.getParameter("username") == null ? "" : req.getParameter("username").trim();
        String password = req.getParameter("password") == null ? "" : req.getParameter("password");

        try {
            UserDAO dao = new UserDAO();
            Optional<User> opt = dao.authenticate(username, password);
            if (opt.isPresent() && opt.get().isAdmin()) {
                HttpSession session = req.getSession(true);
                session.removeAttribute("sessionDealer");
                session.setAttribute("sessionUser", opt.get());
                session.setAttribute("sessionAdmin", Boolean.TRUE);
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else if (opt.isPresent() && opt.get().isDealer()) {
                HttpSession session = req.getSession(true);
                session.removeAttribute("sessionAdmin");
                session.setAttribute("sessionUser", opt.get());
                session.setAttribute("sessionDealer", Boolean.TRUE);
                resp.sendRedirect(req.getContextPath() + "/dealer/dashboard");
            } else {
                req.setAttribute("error", "Credenziali non valide o privilegi insufficienti.");
                req.getRequestDispatcher("/WEB-INF/view/admin/login.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Errore di accesso: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/view/admin/login.jsp").forward(req, resp);
        }
    }
}
