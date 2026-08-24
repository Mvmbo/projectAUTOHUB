<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="navActive" value="${param.active}" />
<aside class="admin-sidebar">
  <div class="admin-brand">
    <p class="admin-brand-name">AutoHUB</p>
    <p class="admin-brand-sub">Area Concessionario</p>
  </div>
  <nav class="sidebar-nav">
    <a href="${pageContext.request.contextPath}/dealer/dashboard" class="${navActive eq 'dashboard' ? 'active' : ''}">
      <i class="bi bi-speedometer2"></i>Dashboard
    </a>
    <a href="${pageContext.request.contextPath}/dealer/sale-vehicles" class="${navActive eq 'sale' ? 'active' : ''}">
      <i class="bi bi-tags"></i>Veicoli Vendita
    </a>
    <a href="${pageContext.request.contextPath}/dealer/rental-vehicles" class="${navActive eq 'rental' ? 'active' : ''}">
      <i class="bi bi-car-front"></i>Veicoli Noleggio
    </a>
    <hr class="sidebar-divider">
    <a href="${pageContext.request.contextPath}/home" target="_blank">
      <i class="bi bi-globe"></i>Vedi Sito
    </a>
    <a href="${pageContext.request.contextPath}/logout" class="danger">
      <i class="bi bi-box-arrow-right"></i>Esci
    </a>
  </nav>
</aside>
