<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<footer>
  <div class="container">
    <div class="row g-4">

      <div class="col-lg-4 col-md-6">
        <h5>AUTO<small style="font-size:0.7rem; letter-spacing:4px; opacity:0.8;">HUB</small></h5>
        <p class="mt-2" style="font-size:0.85rem; line-height:1.9;">
          La piattaforma definitiva per veicoli, ricambi performance e accessori automotive. Guida la tua passione.
        </p>
        <p style="font-size:0.75rem; color:#555; letter-spacing:2px; text-transform:uppercase; margin-top:1rem;">
          Italia &middot; Germania &middot; Spagna &middot; Francia
        </p>
      </div>

      <div class="col-lg-2 col-md-6">
        <h5 style="font-size:0.7rem; letter-spacing:3px; text-transform:uppercase; color:#888; font-family:'Montserrat',sans-serif; margin-bottom:1rem;">Navigazione</h5>
        <ul class="list-unstyled">
          <li><a href="${pageContext.request.contextPath}/home">Home</a></li>
          <li><a href="${pageContext.request.contextPath}/catalog">Catalogo</a></li>
          <li><a href="${pageContext.request.contextPath}/cart">Carrello</a></li>
          <li><a href="${pageContext.request.contextPath}/orders">I Miei Ordini</a></li>
        </ul>
      </div>

      <div class="col-lg-2 col-md-6">
        <h5 style="font-size:0.7rem; letter-spacing:3px; text-transform:uppercase; color:#888; font-family:'Montserrat',sans-serif; margin-bottom:1rem;">Categorie</h5>
        <ul class="list-unstyled">
          <li><a href="${pageContext.request.contextPath}/catalog?category=Supercars">Supercar</a></li>
          <li><a href="${pageContext.request.contextPath}/catalog?category=Performance+Parts">Ricambi Performance</a></li>
          <li><a href="${pageContext.request.contextPath}/catalog?category=Accessories">Accessori</a></li>
          <li><a href="${pageContext.request.contextPath}/catalog?category=Merchandise">Merchandising</a></li>
        </ul>
      </div>

      <div class="col-lg-4 col-md-6">
        <h5 style="font-size:0.7rem; letter-spacing:3px; text-transform:uppercase; color:#888; font-family:'Montserrat',sans-serif; margin-bottom:1rem;">Contatti</h5>
        <p style="font-size:0.82rem; line-height:2; color:#666;">
          <i class="bi bi-envelope me-2" style="color:#D4AF37"></i>info@autohub.it<br>
          <i class="bi bi-telephone me-2" style="color:#D4AF37"></i>+39 089 1234 567<br>
          <i class="bi bi-geo-alt me-2" style="color:#D4AF37"></i>Via Roma 1, Salerno
        </p>
      </div>

    </div>

    <hr class="footer-divider">

    <p class="footer-copyright">
      &copy; 2026 AutoHUB &nbsp;&bull;&nbsp; Tutti i diritti riservati &nbsp;&bull;&nbsp;
      <a href="#" style="color:#444;">Privacy</a> &nbsp;&bull;&nbsp; <a href="#" style="color:#444;">Termini</a>
    </p>
  </div>
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<!-- Cart & Catalog JS -->
<script src="${pageContext.request.contextPath}/scripts/cart.js"></script>
<script src="${pageContext.request.contextPath}/scripts/catalog.js"></script>
<script src="${pageContext.request.contextPath}/scripts/validation.js"></script>
</body>
</html>
