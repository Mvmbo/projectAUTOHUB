<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<c:set var="pageTitle" value="I Miei Noleggi - AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-header">
  <div class="container">
    <h1>I MIEI NOLEGGI</h1>
    <p style="color:#888; font-size:0.75rem; letter-spacing:2px; text-transform:uppercase;">
      Storico prenotazioni e noleggi
    </p>
  </div>
</div>

<div class="container mb-5">
  <c:if test="${not empty error}">
    <div class="alert-error-block mb-4">${error}</div>
  </c:if>

  <c:choose>
    <c:when test="${empty rentals}">
      <div class="empty-state">
        <div class="empty-state-icon"><i class="bi bi-car-front"></i></div>
        <h3>Nessun noleggio ancora</h3>
        <p>Le tue prenotazioni appariranno qui dopo il primo noleggio.</p>
        <a href="${pageContext.request.contextPath}/rentals" class="btn-gold mt-3">Scopri i Noleggi</a>
      </div>
    </c:when>
    <c:otherwise>
      <div class="card-dark" style="overflow:hidden;">
        <div style="overflow-x:auto;">
          <table class="order-table">
            <thead>
              <tr>
                <th>Noleggio #</th>
                <th>Veicolo</th>
                <th>Periodo</th>
                <th>Ritiro</th>
                <th>Totale</th>
                <th>Stato</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="r" items="${rentals}">
                <tr>
                  <td style="color:#D4AF37; font-weight:600;">#${r.id}</td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty r.vehicle}">
                        ${r.vehicle.brand} ${r.vehicle.name}
                      </c:when>
                      <c:otherwise>Veicolo non disponibile</c:otherwise>
                    </c:choose>
                  </td>
                  <td>${r.startDate} - ${r.endDate}</td>
                  <td>${not empty r.pickupCity ? r.pickupCity : 'Non indicato'}</td>
                  <td style="color:#D4AF37; font-weight:600;">
                    <fmt:formatNumber value="${empty r.totalAmount ? 0 : r.totalAmount}" type="currency" currencySymbol="EUR " maxFractionDigits="2"/>
                  </td>
                  <td><span class="badge-pending">${not empty r.status ? r.status : 'pending'}</span></td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<jsp:include page="footer.jsp"/>
