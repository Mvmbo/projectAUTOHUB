<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<c:set var="pageTitle" value="Conferma Prenotazione – AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="container" style="padding: 4rem 0; min-height:70vh;">
  <div class="row justify-content-center">
    <div class="col-lg-8">

      <div class="card-dark text-center" style="padding: 3rem;">
        <!-- Success Icon -->
        <div style="width: 80px; height: 80px; background: rgba(212,175,55,0.1); border: 2px solid #D4AF37; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.5rem;">
          <i class="bi bi-check-lg" style="font-size: 2.5rem; color: #D4AF37;"></i>
        </div>

        <h1 style="font-family: 'Playfair Display', serif; color: #fff; margin-bottom: 0.5rem;">PRENOTAZIONE CONFERMATA!</h1>
        <p style="color: #888; letter-spacing: 2px; font-size: 0.8rem; margin-bottom: 2rem;">
          Il tuo noleggio è stato registrato con successo
        </p>

        <c:if test="${not empty rental}">
          <div style="background: rgba(212,175,55,0.05); border: 1px solid rgba(212,175,55,0.2); border-radius: 8px; padding: 2rem; text-align: left; margin-bottom: 2rem;">
            <h5 style="color: #D4AF37; font-size: 0.75rem; letter-spacing: 3px; margin-bottom: 1.5rem;">
              <i class="bi bi-receipt me-2"></i>DETTAGLI PRENOTAZIONE
            </h5>

            <div class="row">
              <div class="col-md-6">
                <p style="color: #888; font-size: 0.8rem; margin-bottom: 0.25rem;">Veicolo:</p>
                <p style="color: #fff; font-weight: 600; margin-bottom: 1rem;">
                  ${rental.vehicle.brand} ${rental.vehicle.name}
                </p>
              </div>
              <div class="col-md-6">
                <p style="color: #888; font-size: 0.8rem; margin-bottom: 0.25rem;">Codice Prenotazione:</p>
                <p style="color: #D4AF37; font-weight: 700; margin-bottom: 1rem;">#${rental.id}</p>
              </div>
              <div class="col-md-6">
                <p style="color: #888; font-size: 0.8rem; margin-bottom: 0.25rem;">Data Inizio:</p>
                <p style="color: #fff; margin-bottom: 1rem;">${rental.startDate}</p>
              </div>
              <div class="col-md-6">
                <p style="color: #888; font-size: 0.8rem; margin-bottom: 0.25rem;">Data Fine:</p>
                <p style="color: #fff; margin-bottom: 1rem;">${rental.endDate}</p>
              </div>
              <div class="col-md-6">
                <p style="color: #888; font-size: 0.8rem; margin-bottom: 0.25rem;">Città di Ritiro:</p>
                <p style="color: #fff; margin-bottom: 1rem;">${rental.pickupCity}</p>
              </div>
              <div class="col-md-6">
                <p style="color: #888; font-size: 0.8rem; margin-bottom: 0.25rem;">Durata:</p>
                <p style="color: #fff; margin-bottom: 1rem;">${rental.totalDays} giorni</p>
              </div>
              <div class="col-12">
                <hr style="border-color: rgba(212,175,55,0.15); margin: 1rem 0;">
              </div>
              <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                  <span style="color: #888;">Totale:</span>
                  <span style="color: #D4AF37; font-size: 1.8rem; font-weight: 700;">
                    <fmt:formatNumber value="${rental.totalAmount}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div style="background: rgba(255,193,7,0.1); border: 1px solid rgba(255,193,7,0.3); border-radius: 4px; padding: 1rem; margin-bottom: 2rem;">
            <p style="color: #ffc107; font-size: 0.85rem; margin: 0;">
              <i class="bi bi-info-circle me-2"></i>
              Un nostro operatore ti contatterà a breve per confermare il ritiro e organizzare i dettagli.
            </p>
          </div>
        </c:if>

        <div class="d-flex gap-3 justify-content-center flex-wrap">
          <a href="${pageContext.request.contextPath}/rentals" class="btn-outline-gold">
            <i class="bi bi-car-front me-2"></i>Altri Noleggi
          </a>
          <a href="${pageContext.request.contextPath}/home" class="btn-gold">
            <i class="bi bi-house me-2"></i>Torna alla Home
          </a>
        </div>
      </div>

    </div>
  </div>
</div>

<jsp:include page="footer.jsp"/>
