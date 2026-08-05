<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<c:set var="pageTitle" value="Noleggio Auto – AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-header">
  <div class="container">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb mb-2">
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home">Home</a></li>
        <li class="breadcrumb-item active">Noleggi</li>
      </ol>
    </nav>
    <h1>NOLEGGIO AUTO DI LUSSO</h1>
    <p style="color:#888; letter-spacing:2px; font-size:0.75rem; text-transform:uppercase;">
      <c:choose>
        <c:when test="${not empty vehicles}">${vehicles.size()} supercar disponibili</c:when>
        <c:otherwise>Nessun veicolo disponibile</c:otherwise>
      </c:choose>
    </p>
  </div>
</div>

<div class="container mb-5">

  <c:if test="${not empty error}">
    <div class="alert-error-block mb-4">${error}</div>
  </c:if>

  <!-- Info banner -->
  <div class="rental-info-banner mb-4" style="background: linear-gradient(135deg, rgba(212,175,55,0.1), rgba(212,175,55,0.05)); border: 1px solid rgba(212,175,55,0.2); border-radius: 8px; padding: 1.5rem;">
    <div class="row align-items-center">
      <div class="col-md-8">
        <h4 style="color:#D4AF37; margin-bottom: 0.5rem;"><i class="bi bi-info-circle me-2"></i> Come Funziona</h4>
        <p style="color:#aaa; margin:0; font-size:0.9rem;">
          Scegli la supercar dei tuoi sogni e seleziona le date del noleggio.
          Il ritiro avviene presso il concessionario che possiede l'auto.
        </p>
      </div>
      <div class="col-md-4 text-md-end mt-3 mt-md-0">
        <c:if test="${not empty sessionScope.sessionUser}">
          <a href="${pageContext.request.contextPath}/my-rentals" class="btn-outline-gold">
            <i class="bi bi-calendar-check me-2"></i>I Miei Noleggi
          </a>
        </c:if>
      </div>
    </div>
  </div>

  <!-- City filter -->
  <c:if test="${not empty cities}">
    <div class="d-flex flex-wrap gap-2 mb-4 align-items-center">
      <span style="font-size:0.75rem; letter-spacing:2px; color:#666; text-transform:uppercase;">Filtra per città:</span>
      <button type="button" class="badge-category active" onclick="filterByCity('')">Tutte</button>
      <c:forEach var="city" items="${cities}">
        <button type="button" class="badge-category" onclick="filterByCity('${city}')">${city}</button>
      </c:forEach>
    </div>
  </c:if>

  <c:choose>
    <c:when test="${not empty vehicles}">
      <div class="row g-4" id="vehiclesGrid">
        <c:forEach var="v" items="${vehicles}">
          <div class="col-lg-4 col-md-6 vehicle-card" data-city="${v.city}">
            <div class="product-card h-100">
              <div class="card-img-wrap">
                <c:choose>
                  <c:when test="${not empty v.imageUrl and fn:startsWith(v.imageUrl, '/images/products/')}">
                    <img src="${pageContext.request.contextPath}${v.imageUrl}" alt="${v.name}" loading="lazy">
                  </c:when>
                  <c:otherwise>
                    <div class="d-flex align-items-center justify-content-center" style="height:100%; min-height:220px; background:#111; color:#666; font-size:0.72rem; letter-spacing:2px; text-transform:uppercase;">
                      Nessuna immagine
                    </div>
                  </c:otherwise>
                </c:choose>
                <div class="rental-badge">
                  <i class="bi bi-geo-alt-fill me-1"></i>${v.city}
                </div>
              </div>
              <div class="product-card-body">
                <p class="product-category">${v.brand}</p>
                <c:if test="${not empty v.dealerName}">
                  <p style="color:#888; font-size:0.72rem; margin-bottom:0.35rem;">
                    <i class="bi bi-shop me-1"></i>${v.dealerName}
                  </p>
                </c:if>
                <h5 class="product-name">${v.name}</h5>
                <p class="product-description" style="color:#666; font-size:0.8rem; margin-bottom:1rem;">
                  ${v.description != null && v.description.length() > 100 ? v.description.substring(0, 100).concat('...') : v.description}
                </p>
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span style="color:#888; font-size:0.75rem;">A partire da</span>
                  <span class="rental-price">
                    <fmt:formatNumber value="${v.pricePerDay}" type="currency" currencySymbol="€" maxFractionDigits="0"/>
                    <span style="font-size:0.7rem; color:#888;">/giorno</span>
                  </span>
                </div>
                <div class="d-flex">
                  <c:choose>
                    <c:when test="${not empty sessionScope.sessionUser}">
                      <a href="${pageContext.request.contextPath}/rental-booking?vehicleId=${v.id}"
                         class="btn-gold text-center w-100" style="font-size:0.75rem; padding:10px; text-decoration:none;">
                        <i class="bi bi-calendar-plus me-1"></i>Noleggia
                      </a>
                    </c:when>
                    <c:otherwise>
                      <a href="${pageContext.request.contextPath}/login?redirectUrl=/rentals"
                         class="btn-gold text-center w-100" style="font-size:0.75rem; padding:10px; text-decoration:none;">
                        <i class="bi bi-person me-1"></i>Accedi
                      </a>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:when>
    <c:otherwise>
      <div class="empty-state">
        <div class="empty-state-icon"><i class="bi bi-car-front"></i></div>
        <h3>Nessun veicolo disponibile</h3>
        <p>Al momento non ci sono supercar disponibili per il noleggio. Riprova più tardi.</p>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<script>
function filterByCity(city) {
  const cards = document.querySelectorAll('.vehicle-card');
  cards.forEach(card => {
    if (city === '' || card.dataset.city === city) {
      card.style.display = '';
    } else {
      card.style.display = 'none';
    }
  });
  // Update active badge
  document.querySelectorAll('.badge-category').forEach(b => b.classList.remove('active'));
}

</script>

<style>
.rental-badge {
  position: absolute;
  top: 10px;
  left: 10px;
  background: rgba(0,0,0,0.7);
  color: #D4AF37;
  padding: 4px 12px;
  border-radius: 4px;
  font-size: 0.7rem;
  letter-spacing: 1px;
}
.rental-price {
  color: #D4AF37;
  font-size: 1.3rem;
  font-weight: 700;
}
.badge-category {
  cursor: pointer;
  transition: all 0.2s;
}
.badge-category.active,
.badge-category:hover {
  background: rgba(212,175,55,0.3);
  border-color: #D4AF37;
}
</style>

<jsp:include page="footer.jsp"/>
