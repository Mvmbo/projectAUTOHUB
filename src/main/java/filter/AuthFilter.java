package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebFilter(urlPatterns = {"/checkout", "/orders", "/order-detail", "/my-rentals", "/rental-booking", "/rental-confirmation"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);

        if (session == null || session.getAttribute("sessionUser") == null) {
            String target = httpRequest.getServletPath();
            if (httpRequest.getPathInfo() != null) {
                target += httpRequest.getPathInfo();
            }
            if (httpRequest.getQueryString() != null) {
                target += "?" + httpRequest.getQueryString();
            }
            String loginUrl = httpRequest.getContextPath() + "/login?redirectUrl=" +
                    URLEncoder.encode(target, StandardCharsets.UTF_8) +
                    "&message=Devi effettuare l'accesso per accedere a questa pagina";
            httpResponse.sendRedirect(loginUrl);
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
