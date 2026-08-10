<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<c:set var="pageTitle" value="Prenota Noleggio – AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-header">
  <div class="container">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb mb-2">
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home">Home</a></li>
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/rentals">Noleggi</a></li>
        <li class="breadcrumb-item active">Prenotazione</li>
      </ol>
    </nav>
    <h1>PRENOTA IL TUO NOLEGGIO</h1>
  </div>
</div>

<div class="container mb-5">

  <c:if test="${not empty error}">
    <div class="alert-error-block mb-4">${error}</div>
  </c:if>

  <c:if test="${not empty vehicle}">
    <div class="row g-4">
      <!-- Vehicle Info -->
      <div class="col-lg-5">
        <div class="card-dark">
          <c:choose>
            <c:when test="${not empty vehicle.imageUrl and fn:startsWith(vehicle.imageUrl, '/images/products/')}">
              <img src="${pageContext.request.contextPath}${vehicle.imageUrl}" alt="${vehicle.name}" style="width:100%; border-radius:4px;">
            </c:when>
            <c:otherwise>
              <div class="d-flex align-items-center justify-content-center" style="width:100%; min-height:260px; border-radius:4px; background:#111; color:#666; font-size:0.72rem; letter-spacing:2px; text-transform:uppercase;">
                Nessuna immagine
              </div>
            </c:otherwise>
          </c:choose>
          <div style="padding:1.5rem;">
            <p style="color:#D4AF37; font-size:0.75rem; letter-spacing:2px; margin-bottom:0.5rem;">${vehicle.brand}</p>
            <h3 style="color:#fff; font-family:'Playfair Display',serif; margin-bottom:1rem;">${vehicle.name}</h3>
            <p style="color:#888; font-size:0.85rem; line-height:1.6;">${vehicle.description}</p>
            <hr style="border-color:rgba(212,175,55,0.15); margin:1.5rem 0;">
            <div class="d-flex justify-content-between align-items-center">
              <span style="color:#888; font-size:0.8rem;">Prezzo per giorno:</span>
              <span style="color:#D4AF37; font-size:1.4rem; font-weight:700;">
                <fmt:formatNumber value="${vehicle.pricePerDay}" type="currency" currencySymbol="€" maxFractionDigits="0"/>
              </span>
            </div>
            <p style="color:#666; font-size:0.8rem; margin-top:0.5rem;">
              <i class="bi bi-geo-alt me-1"></i>Ritiro presso:
              <c:choose>
                <c:when test="${not empty vehicle.dealerName}">${vehicle.dealerName}</c:when>
                <c:otherwise>${vehicle.city}</c:otherwise>
              </c:choose>
            </p>
          </div>
        </div>
      </div>

      <!-- Booking Form -->
      <div class="col-lg-7">
        <div class="card-dark">
          <h4 style="color:#D4AF37; font-size:0.8rem; letter-spacing:3px; margin-bottom:1.5rem;">
            <i class="bi bi-calendar-event me-2"></i>DETTAGLI PRENOTAZIONE
          </h4>

          <form action="${pageContext.request.contextPath}/rental-booking" method="post" id="rentalForm">
            <input type="hidden" name="vehicleId" value="${vehicle.id}">

            <div class="row g-3">
              <!-- Start Date -->
              <div class="col-md-6">
                <label class="form-label" style="color:#aaa; font-size:0.75rem; letter-spacing:1px;">Data Inizio *</label>
                <input type="date" name="startDate" class="form-control" required
                       min="<%= java.time.LocalDate.now().toString() %>"
                       value="${not empty formData.startDate ? formData.startDate : ''}">
                <c:if test="${not empty errors.startDate}">
                  <div class="validation-message" style="color:#ff6b6b; font-size:0.75rem; margin-top:4px;">${errors.startDate}</div>
                </c:if>
              </div>

              <!-- End Date -->
              <div class="col-md-6">
                <label class="form-label" style="color:#aaa; font-size:0.75rem; letter-spacing:1px;">Data Fine *</label>
                <input type="date" name="endDate" class="form-control" required
                       min="<%= java.time.LocalDate.now().toString() %>"
                       value="${not empty formData.endDate ? formData.endDate : ''}">
                <c:if test="${not empty errors.endDate}">
                  <div class="validation-message" style="color:#ff6b6b; font-size:0.75rem; margin-top:4px;">${errors.endDate}</div>
                </c:if>
              </div>

              <!-- Pickup Location -->
              <div class="col-12">
                <div style="background:rgba(255,255,255,0.04); border:1px solid rgba(212,175,55,0.16); border-radius:4px; padding:1rem;">
                  <p style="color:#D4AF37; font-size:0.7rem; letter-spacing:3px; margin-bottom:0.75rem;">
                    <i class="bi bi-geo-alt me-2"></i>RITIRO IN CONCESSIONARIA
                  </p>
                  <p style="color:#fff; font-weight:600; margin-bottom:0.35rem;">
                    <c:choose>
                      <c:when test="${not empty vehicle.dealerName}">${vehicle.dealerName}</c:when>
                      <c:otherwise>Sede associata al veicolo</c:otherwise>
                    </c:choose>
                  </p>
                  <p style="color:#888; font-size:0.85rem; margin-bottom:0;">
                    <c:choose>
                      <c:when test="${not empty vehicle.dealerAddress}">
                        ${vehicle.dealerAddress}<c:if test="${not empty vehicle.dealerCity}">, ${vehicle.dealerCity}</c:if>
                      </c:when>
                      <c:otherwise>
                        Posizione attuale del veicolo<c:if test="${not empty vehicle.city}">, ${vehicle.city}</c:if>
                      </c:otherwise>
                    </c:choose>
                  </p>
                </div>
              </div>
              <!-- Notes -->
              <div class="col-12">
                <label class="form-label" style="color:#aaa; font-size:0.75rem; letter-spacing:1px;">Note Aggiuntive</label>
                <textarea name="notes" class="form-control" rows="3" placeholder="Eventuali richieste o note...">${not empty formData.notes ? formData.notes : ''}</textarea>
              </div>
            </div>

            <!-- Price Summary -->
            <div id="priceSummary" style="background:rgba(212,175,55,0.08); padding:1.25rem; border-radius:4px; margin-top:1.5rem;">
              <h5 style="color:#D4AF37; font-size:0.7rem; letter-spacing:3px; margin-bottom:1rem;">RIEPILOGO COSTI</h5>
              <div class="d-flex justify-content-between mb-2" style="color:#888; font-size:0.85rem;">
                <span>Giorni:</span>
                <span id="totalDays">0</span>
              </div>
              <div class="d-flex justify-content-between mb-2" style="color:#888; font-size:0.85rem;">
                <span>Prezzo per giorno:</span>
                <span><fmt:formatNumber value="${vehicle.pricePerDay}" type="currency" currencySymbol="€" maxFractionDigits="0"/></span>
              </div>
              <hr style="border-color:rgba(212,175,55,0.2); margin:1rem 0;">
              <div class="d-flex justify-content-between align-items-center">
                <span style="color:#fff; font-weight:600;">Totale Stimato:</span>
                <span id="totalAmount" style="color:#D4AF37; font-size:1.5rem; font-weight:700;">€ 0</span>
              </div>
            </div>

            <div class="mt-4 d-flex gap-3">
              <a href="${pageContext.request.contextPath}/rentals" class="btn-dark-outline">
                <i class="bi bi-arrow-left me-1"></i>Annulla
              </a>
              <button type="submit" class="btn-gold flex-grow-1">
                <i class="bi bi-check-circle me-2"></i>Conferma Prenotazione
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </c:if>
</div>

<script>
const pricePerDay = ${vehicle.pricePerDay};
const startDateInput = document.querySelector('input[name="startDate"]');
const endDateInput = document.querySelector('input[name="endDate"]');

function updatePrice() {
  const start = new Date(startDateInput.value);
  const end = new Date(endDateInput.value);
  if (start && end && end >= start) {
    const days = Math.ceil((end - start) / (1000 * 60 * 60 * 24)) + 1;
    const total = days * pricePerDay;
    document.getElementById('totalDays').textContent = days;
    document.getElementById('totalAmount').textContent = '€ ' + total.toLocaleString('it-IT');
  }
}

startDateInput.addEventListener('change', function() {
  endDateInput.min = this.value;
  updatePrice();
});
endDateInput.addEventListener('change', updatePrice);
</script>

<jsp:include page="footer.jsp"/>
