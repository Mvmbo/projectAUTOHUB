<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<c:set var="pageTitle" value="Ordine Confermato – AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="container" style="padding:4rem 0 5rem;">

  <!-- Success Banner -->
  <div class="text-center mb-5">
    <div class="confirm-icon">&#10003;</div>
    <h1 style="font-family:'Playfair Display',serif; font-size:2.5rem; letter-spacing:4px; color:#fff; margin-bottom:0.5rem;">ORDINE CONFERMATO</h1>
    <p style="color:#888; letter-spacing:2px; font-size:0.8rem; text-transform:uppercase;">
      Grazie, ${sessionScope.sessionUser.fullName != null ? sessionScope.sessionUser.fullName : sessionScope.sessionUser.username}
    </p>
    <p style="color:#D4AF37; font-size:1.1rem; margin-top:0.5rem;">
      Ordine #${order.id}
    </p>
    <div class="admin-alert admin-alert-success" style="max-width:520px; margin:1.25rem auto 0;">
      <i class="bi bi-check-circle me-2"></i>Acquisto eseguito con successo!
    </div>
  </div>

  <div class="row g-4 justify-content-center">
    <div class="col-lg-8">

      <!-- Order Items -->
      <div class="card-dark p-4 mb-4">
        <h5 style="font-size:0.7rem; letter-spacing:3px; text-transform:uppercase; color:#888; margin-bottom:1.5rem; border-bottom:1px solid rgba(212,175,55,0.1); padding-bottom:0.75rem;">
          <i class="bi bi-bag me-2"></i>Articoli Ordinati
        </h5>
        <table class="order-table">
          <thead>
            <tr>
              <th>Prodotto</th>
              <th>Prezzo Unit.</th>
              <th>Qtà</th>
              <th>Subtotale</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="item" items="${order.items}">
              <tr>
                <td>${item.productName}</td>
                <td style="color:#D4AF37;">
                  <fmt:formatNumber value="${item.productPrice}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                </td>
                <td>${item.quantity}</td>
                <td style="color:#D4AF37; font-weight:600;">
                  <fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                </td>
              </tr>
            </c:forEach>
          </tbody>
          <tfoot>
            <tr>
              <td colspan="3" style="text-align:right; font-size:0.7rem; letter-spacing:2px; text-transform:uppercase; color:#888;">Totale</td>
              <td style="color:#D4AF37; font-weight:700; font-size:1.2rem;">
                <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
              </td>
            </tr>
          </tfoot>
        </table>
      </div>

      <!-- Shipping + Payment -->
      <div class="row g-4">
        <div class="col-md-6">
          <div class="card-dark p-4 h-100">
            <h5 style="font-size:0.65rem; letter-spacing:3px; text-transform:uppercase; color:#888; margin-bottom:1rem;"><i class="bi bi-geo-alt me-2"></i>Indirizzo di Spedizione</h5>
            <p style="color:#ccc; font-size:0.9rem; line-height:2; margin:0;">
              ${order.shippingName}<br>
              ${order.shippingAddress}<br>
              ${order.shippingCity}, ${order.shippingPostal}<br>
              ${order.shippingCountry}
            </p>
          </div>
        </div>
        <div class="col-md-6">
          <div class="card-dark p-4 h-100">
            <h5 style="font-size:0.65rem; letter-spacing:3px; text-transform:uppercase; color:#888; margin-bottom:1rem;"><i class="bi bi-credit-card me-2"></i>Pagamento &amp; Stato</h5>
            <p style="margin:0; line-height:2; font-size:0.9rem;">
              <span style="color:#888; display:block;">Metodo: <span style="color:#ccc;">${order.paymentMethod}</span></span>
              <span style="color:#888; display:block;">Stato: <span class="badge-confirmed">Confermato</span></span>
              <span style="color:#888; display:block;">Data:
                <span style="color:#ccc;">
                  <c:choose>
                    <c:when test="${not empty order.createdAtAsDate}">
                      <fmt:formatDate value="${order.createdAtAsDate}" pattern="dd MMM yyyy"/>
                    </c:when>
                    <c:otherwise>N/D</c:otherwise>
                  </c:choose>
                </span>
              </span>
            </p>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="d-flex gap-3 flex-wrap justify-content-center mt-4">
        <a href="${pageContext.request.contextPath}/orders" class="btn-outline-gold">
          <i class="bi bi-clock-history me-2"></i>Vedi Tutti gli Ordini
        </a>
        <a href="${pageContext.request.contextPath}/catalog" class="btn-gold">
          <i class="bi bi-bag me-2"></i>Continua gli Acquisti
        </a>
      </div>

    </div>
  </div>
</div>

<jsp:include page="footer.jsp"/>
