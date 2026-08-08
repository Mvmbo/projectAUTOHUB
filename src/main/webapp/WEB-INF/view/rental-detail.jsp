<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<c:set var="pageTitle" value="${vehicle.name} - Noleggio AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<section class="product-detail-hero">
  <div class="container">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb product-breadcrumb mb-3">
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home">Home</a></li>
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/rentals">Noleggi</a></li>
        <li class="breadcrumb-item active" aria-current="page">${vehicle.name}</li>
      </ol>
    </nav>

    <div class="product-detail-heading">
      <span class="detail-eyebrow">Scheda noleggio AutoHUB</span>
      <h1>${vehicle.name}</h1>
      <c:if test="${not empty vehicle.dealerName}">
        <p style="color:#D4AF37; margin-bottom:0.5rem;"><i class="bi bi-shop me-1"></i>Concessionario ${vehicle.dealerName}</p>
      </c:if>
      <p>Dettagli, posizione e tariffa giornaliera per prenotare il veicolo con chiarezza.</p>
    </div>
  </div>
</section>

<main class="product-detail-page">
  <div class="container">
    <div class="row g-5 align-items-start">
      <div class="col-lg-7">
        <div class="detail-gallery">
          <div id="rentalVehicleCarousel" class="carousel slide" data-bs-ride="false">
            <div class="carousel-inner">
              <c:choose>
                <c:when test="${not empty vehicle.imageUrls}">
                  <c:forEach var="image" items="${vehicle.imageUrls}" varStatus="status">
                    <div class="carousel-item ${status.first ? 'active' : ''}">
                      <img src="${pageContext.request.contextPath}${image}" class="detail-gallery-image d-block w-100" alt="${vehicle.name} - immagine ${status.index + 1}">
                    </div>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <div class="carousel-item active">
                    <div class="detail-gallery-image d-flex align-items-center justify-content-center" style="background:#111; border:1px solid rgba(212,175,55,0.18); color:#777; min-height:420px; text-transform:uppercase; letter-spacing:3px; font-size:0.78rem;">
                      Nessuna immagine caricata
                    </div>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>

            <c:if test="${fn:length(vehicle.imageUrls) gt 1}">
              <button class="carousel-control-prev detail-carousel-control" type="button" data-bs-target="#rentalVehicleCarousel" data-bs-slide="prev">
                <span class="carousel-control-prev-icon"></span>
                <span class="visually-hidden">Immagine precedente</span>
              </button>
              <button class="carousel-control-next detail-carousel-control" type="button" data-bs-target="#rentalVehicleCarousel" data-bs-slide="next">
                <span class="carousel-control-next-icon"></span>
                <span class="visually-hidden">Immagine successiva</span>
              </button>
            </c:if>
          </div>
        </div>

        <div class="detail-panel mt-4">
          <div class="detail-panel-header">
            <span>Descrizione</span>
            <i class="bi bi-stars"></i>
          </div>
          <p class="detail-description">${vehicle.description}</p>
        </div>
      </div>

      <div class="col-lg-5">
        <aside class="detail-purchase-panel">
          <span class="badge-category">${vehicle.category}</span>
          <h2>${vehicle.brand} ${vehicle.name}</h2>

          <p class="detail-price">
            <fmt:formatNumber value="${vehicle.pricePerDay}" type="currency" currencySymbol="&euro;" maxFractionDigits="0"/>
            <span style="font-size:0.9rem; color:#888;">/giorno</span>
          </p>

          <div class="detail-status-row">
            <span class="detail-status available"><i class="bi bi-check-circle"></i>Disponibile</span>
            <span><i class="bi bi-geo-alt me-1"></i>${vehicle.city}</span>
          </div>

          <div class="detail-highlight-grid">
            <div class="detail-highlight">
              <i class="bi bi-car-front"></i>
              <span>Marca</span>
              <strong>${vehicle.brand}</strong>
            </div>
            <div class="detail-highlight">
              <i class="bi bi-tags"></i>
              <span>Categoria</span>
              <strong>${vehicle.category}</strong>
            </div>
            <div class="detail-highlight">
              <i class="bi bi-geo-alt"></i>
              <span>Partenza</span>
              <strong>${vehicle.city}</strong>
            </div>
            <div class="detail-highlight">
              <i class="bi bi-shield-check"></i>
              <span>Standard</span>
              <strong>AutoHUB</strong>
            </div>
          </div>

          <div class="detail-actions">
            <c:choose>
              <c:when test="${not empty sessionScope.sessionUser}">
                <a href="${pageContext.request.contextPath}/rental-booking?vehicleId=${vehicle.id}" class="btn-gold">
                  <i class="bi bi-calendar-plus me-2"></i>Prenota Noleggio
                </a>
              </c:when>
              <c:otherwise>
                <a href="${pageContext.request.contextPath}/login?redirectUrl=/rental-detail?id=${vehicle.id}" class="btn-gold">
                  <i class="bi bi-person me-2"></i>Accedi per Prenotare
                </a>
              </c:otherwise>
            </c:choose>
            <a href="${pageContext.request.contextPath}/rentals" class="btn-outline-gold">
              <i class="bi bi-arrow-left me-2"></i>Torna ai Noleggi
            </a>
          </div>

          <div class="detail-service-list">
            <span><i class="bi bi-compass"></i> Coordinate partenza: ${vehicle.latitude}, ${vehicle.longitude}</span>
            <span><i class="bi bi-headset"></i> Assistenza AutoHUB per ritiro e consegna</span>
            <span><i class="bi bi-file-earmark-check"></i> Prenotazione verificata prima della conferma finale</span>
          </div>
        </aside>
      </div>
    </div>
  </div>
</main>

<jsp:include page="footer.jsp"/>
