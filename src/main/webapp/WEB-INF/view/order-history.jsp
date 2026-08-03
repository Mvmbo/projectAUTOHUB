<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<c:set var="pageTitle" value="I Miei Ordini - AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-header">
  <div class="container">
    <h1>I MIEI ORDINI</h1>
    <p style="color:#888; font-size:0.75rem; letter-spacing:2px; text-transform:uppercase;">
      Storico ordini di ${not empty sessionScope.sessionUser.fullName ? sessionScope.sessionUser.fullName : sessionScope.sessionUser.username}
    </p>
  </div>
</div>

<div class="container mb-5">

  <c:if test="${not empty error}">
    <div class="alert-error-block mb-4">${error}</div>
  </c:if>

  <c:choose>
    <c:when test="${empty orders}">
      <div class="empty-state">
        <div class="empty-state-icon"><i class="bi bi-bag-x"></i></div>
        <h3>Nessun ordine ancora</h3>
        <p>Il tuo storico ordini apparira' qui dopo il primo acquisto.</p>
        <a href="${pageContext.request.contextPath}/catalog" class="btn-gold mt-3">Inizia ad Acquistare</a>
      </div>
    </c:when>
    <c:otherwise>
      <div class="card-dark" style="overflow:hidden;">
        <div style="overflow-x:auto;">
          <table class="order-table">
            <thead>
              <tr>
                <th>Ordine #</th>
                <th>Data</th>
                <th>Pagamento</th>
                <th>Totale</th>
                <th>Stato</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="o" items="${orders}">
                <tr>
                  <td style="color:#D4AF37; font-weight:600;">#${o.id}</td>
                  <td>${o.createdAtFormatted}</td>
                  <td>${not empty o.paymentMethod ? o.paymentMethod : 'Non indicato'}</td>
                  <td style="color:#D4AF37; font-weight:600;">
                    <fmt:formatNumber value="${empty o.totalAmount ? 0 : o.totalAmount}" type="currency" currencySymbol="EUR " maxFractionDigits="2"/>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${o.status eq 'confirmed' or o.status eq 'CONFIRMED'}">
                        <span class="badge-confirmed">Confermato</span>
                      </c:when>
                      <c:when test="${o.status eq 'shipped' or o.status eq 'SHIPPED'}">
                        <span class="badge-shipped">Spedito</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge-pending">In Attesa</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <a href="${pageContext.request.contextPath}/order-detail?id=${o.id}" class="btn-outline-gold" style="font-size:0.7rem; padding:6px 16px;">
                      Vedi Dettagli
                    </a>
                  </td>
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
