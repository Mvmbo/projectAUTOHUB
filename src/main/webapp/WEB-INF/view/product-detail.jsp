<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<c:set var="pageTitle" value="${product.name} - AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<section class="product-detail-hero">
  <div class="container">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb product-breadcrumb mb-3">
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home">Home</a></li>
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/catalog">Catalogo</a></li>
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/catalog?category=${product.category}">${product.category}</a></li>
        <li class="breadcrumb-item active" aria-current="page">${product.name}</li>
      </ol>
    </nav>

    <div class="product-detail-heading">
      <span class="detail-eyebrow">Scheda veicolo AutoHUB</span>
      <h1>${product.name}</h1>
      <c:if test="${not empty product.dealerName}">
        <p style="color:#D4AF37; margin-bottom:0.5rem;"><i class="bi bi-shop me-1"></i>Pubblicato da ${product.dealerName}</p>
      </c:if>
      <p>Dettagli tecnici, immagini e dotazioni selezionate per valutare il prodotto con chiarezza prima dell'acquisto.</p>
    </div>
  </div>
</section>

<main class="product-detail-page">
  <div class="container">
    <div class="row g-5 align-items-start">
      <div class="col-lg-7">
        <div class="detail-gallery">
          <div id="productCarousel" class="carousel slide" data-bs-ride="false">
            <div class="carousel-inner">
              <c:choose>
                <c:when test="${not empty productImages}">
                  <c:forEach var="image" items="${productImages}" varStatus="status">
                    <div class="carousel-item ${status.first ? 'active' : ''}">
                      <img src="${pageContext.request.contextPath}${image}" class="detail-gallery-image d-block w-100" alt="${product.name} - immagine ${status.index + 1}">
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

            <c:if test="${fn:length(productImages) gt 1}">
              <button class="carousel-control-prev detail-carousel-control" type="button" data-bs-target="#productCarousel" data-bs-slide="prev">
                <span class="carousel-control-prev-icon"></span>
                <span class="visually-hidden">Immagine precedente</span>
              </button>
              <button class="carousel-control-next detail-carousel-control" type="button" data-bs-target="#productCarousel" data-bs-slide="next">
                <span class="carousel-control-next-icon"></span>
                <span class="visually-hidden">Immagine successiva</span>
              </button>
            </c:if>
          </div>

          <c:if test="${fn:length(productImages) gt 1}">
            <div class="detail-thumbnail-row" aria-label="Selezione immagini prodotto">
              <c:forEach var="image" items="${productImages}" varStatus="status">
                <button class="detail-thumbnail-btn ${status.first ? 'active' : ''}" data-slide="${status.index}" type="button">
                  <img src="${pageContext.request.contextPath}${image}" alt="Miniatura ${status.index + 1}">
                </button>
              </c:forEach>
            </div>
          </c:if>
        </div>

        <div class="detail-panel mt-4">
          <div class="detail-panel-header">
            <span>Descrizione</span>
            <i class="bi bi-stars"></i>
          </div>
          <p class="detail-description">${product.description}</p>
        </div>
      </div>

      <div class="col-lg-5">
        <aside class="detail-purchase-panel">
          <span class="badge-category">${product.category}</span>
          <c:if test="${not empty product.dealerName}">
            <p style="color:#888; font-size:0.8rem; margin:0.75rem 0 0;">
              <i class="bi bi-shop me-1"></i>Concessionario: ${product.dealerName}
            </p>
          </c:if>
          <h2>${product.name}</h2>

          <p class="detail-price">
            <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="&euro;" maxFractionDigits="2"/>
          </p>

          <div class="detail-status-row">
            <c:choose>
              <c:when test="${product.stockQuantity gt 0}">
                <span class="detail-status available"><i class="bi bi-check-circle"></i>Disponibile</span>
                <span>${product.stockQuantity} unita' in stock</span>
              </c:when>
              <c:otherwise>
                <span class="detail-status unavailable"><i class="bi bi-x-circle"></i>Esaurito</span>
                <span>Contattaci per disponibilita'</span>
              </c:otherwise>
            </c:choose>
          </div>

          <div class="detail-highlight-grid">
            <c:forEach var="item" items="${performanceHighlights}">
              <div class="detail-highlight">
                <i class="bi ${item.icon}"></i>
                <span>${item.label}</span>
                <strong>${item.value}</strong>
              </div>
            </c:forEach>
          </div>

          <c:if test="${product.stockQuantity gt 0}">
            <div class="detail-quantity">
              <label class="form-label" for="productQty">Quantita'</label>
              <div class="qty-control">
                <button class="qty-btn" id="qtyMinus" type="button" aria-label="Diminuisci quantita'"><i class="bi bi-dash"></i></button>
                <input class="qty-input" id="productQty" type="number" value="1" min="1" max="${product.stockQuantity}" readonly>
                <button class="qty-btn" id="qtyPlus" type="button" aria-label="Aumenta quantita'"><i class="bi bi-plus"></i></button>
              </div>
            </div>

            <div class="detail-actions">
              <button class="btn-add-to-cart btn-gold" data-product-id="${product.id}">
                <i class="bi bi-bag-plus me-2"></i>Aggiungi al carrello
              </button>
              <a href="${pageContext.request.contextPath}/cart" class="btn-outline-gold">
                <i class="bi bi-bag me-2"></i>Vai al carrello
              </a>
            </div>
          </c:if>

          <div class="detail-service-list">
            <span><i class="bi bi-shield-check"></i> Verifica AutoHUB inclusa</span>
            <span><i class="bi bi-file-earmark-check"></i> Documentazione controllata</span>
            <span><i class="bi bi-headset"></i> Consulenza dedicata pre-acquisto</span>
          </div>
        </aside>
      </div>
    </div>

    <section class="detail-spec-section">
      <div class="detail-section-title">
        <span>Specifiche complete</span>
        <h2>Dati tecnici e configurazione</h2>
      </div>

      <div class="row g-4">
        <div class="col-lg-6">
          <div class="detail-panel h-100">
            <div class="detail-panel-header">
              <span>Motore e prestazioni</span>
              <i class="bi bi-speedometer"></i>
            </div>
            <div class="detail-spec-list">
              <c:forEach var="spec" items="${technicalSpecs}">
                <div class="detail-spec-item">
                  <i class="bi ${spec.icon}"></i>
                  <span>${spec.label}</span>
                  <strong>${spec.value}</strong>
                </div>
              </c:forEach>
            </div>
          </div>
        </div>

        <div class="col-lg-6">
          <div class="detail-panel h-100">
            <div class="detail-panel-header">
              <span>Dimensioni e garanzie</span>
              <i class="bi bi-rulers"></i>
            </div>
            <div class="detail-spec-list">
              <c:forEach var="spec" items="${dimensionSpecs}">
                <div class="detail-spec-item">
                  <i class="bi ${spec.icon}"></i>
                  <span>${spec.label}</span>
                  <strong>${spec.value}</strong>
                </div>
              </c:forEach>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="detail-equipment-section">
      <div class="row g-4 align-items-stretch">
        <div class="col-lg-5">
          <div class="detail-section-title detail-section-title-left">
            <span>Equipaggiamento</span>
            <h2>Dotazioni principali</h2>
            <p>Una sintesi degli elementi che rendono questo prodotto coerente con lo standard AutoHUB.</p>
          </div>
        </div>
        <div class="col-lg-7">
          <div class="detail-equipment-grid">
            <c:forEach var="item" items="${equipmentItems}">
              <div class="detail-equipment-item">
                <i class="bi bi-check2"></i>
                <span>${item}</span>
              </div>
            </c:forEach>
          </div>
        </div>
      </div>
    </section>

    <section class="detail-related-cta">
      <div>
        <span>Vuoi confrontare altre proposte?</span>
        <h2>Esplora altri prodotti nella categoria ${product.category}</h2>
      </div>
      <a href="${pageContext.request.contextPath}/catalog?category=${product.category}" class="btn-outline-gold">
        <i class="bi bi-grid me-2"></i>Vedi categoria
      </a>
    </section>
  </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', function() {
  const carouselEl = document.getElementById('productCarousel');
  if (!carouselEl) return;

  document.querySelectorAll('.detail-thumbnail-btn').forEach(function(btn) {
    btn.addEventListener('click', function() {
      const carousel = bootstrap.Carousel.getOrCreateInstance(carouselEl);
      carousel.to(parseInt(btn.dataset.slide, 10));
      document.querySelectorAll('.detail-thumbnail-btn').forEach(function(item) {
        item.classList.remove('active');
      });
      btn.classList.add('active');
    });
  });

  carouselEl.addEventListener('slid.bs.carousel', function(event) {
    document.querySelectorAll('.detail-thumbnail-btn').forEach(function(btn, index) {
      btn.classList.toggle('active', index === event.to);
    });
  });
});
</script>

<jsp:include page="footer.jsp"/>
