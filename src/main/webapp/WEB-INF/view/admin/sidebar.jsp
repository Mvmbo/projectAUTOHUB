<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="navActive" value="${param.active}" />
<aside class="admin-sidebar">
  <div class="admin-brand">
    <p class="admin-brand-name">AutoHUB</p>
    <p class="admin-brand-sub">Pannello Admin</p>
  </div>
  <nav class="sidebar-nav">
    <a href="${pageContext.request.contextPath}/admin/dashboard"
       class="${navActive eq 'dashboard' ? 'active' : ''}">
      <i class="bi bi-speedometer2"></i>Dashboard
    </a>
    <a href="${pageContext.request.contextPath}/admin/products"
       class="${navActive eq 'products' ? 'active' : ''}">
      <i class="bi bi-grid"></i>Prodotti
    </a>
    <a href="${pageContext.request.contextPath}/admin/orders"
       class="${navActive eq 'orders' ? 'active' : ''}">
      <i class="bi bi-bag"></i>Ordini
    </a>
    <a href="${pageContext.request.contextPath}/admin/rentals"
       class="${navActive eq 'rentals' ? 'active' : ''}">
      <i class="bi bi-car-front"></i>Veicoli Noleggiati
    </a>
    <hr class="sidebar-divider">
    <a href="${pageContext.request.contextPath}/home" target="_blank">
      <i class="bi bi-globe"></i>Vedi Sito
    </a>
    <a href="${pageContext.request.contextPath}/admin/logout" class="danger">
      <i class="bi bi-box-arrow-right"></i>Esci
    </a>
  </nav>
</aside>
