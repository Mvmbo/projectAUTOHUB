package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*"})
public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String relativePath = path.substring(contextPath.length());

        if (relativePath.equals("/admin/login") || relativePath.equals("/admin/logout")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);

        Object sessionUser = session == null ? null : session.getAttribute("sessionUser");
        boolean isAdmin = session != null && Boolean.TRUE.equals(session.getAttribute("sessionAdmin"));
        boolean isDealer = session != null && Boolean.TRUE.equals(session.getAttribute("sessionDealer"));
        if (sessionUser instanceof User) {
            User user = (User) sessionUser;
            isAdmin = isAdmin || user.isAdmin();
            isDealer = isDealer || user.isDealer();
            if (isAdmin) {
                session.setAttribute("sessionAdmin", Boolean.TRUE);
            }
            if (isDealer) {
                session.setAttribute("sessionDealer", Boolean.TRUE);
            }
        }

        if (isDealer && !isAdmin) {
            httpResponse.sendRedirect(contextPath + "/dealer/dashboard");
            return;
        }

        if (!isAdmin) {
            httpResponse.sendRedirect(contextPath + "/admin/login");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
