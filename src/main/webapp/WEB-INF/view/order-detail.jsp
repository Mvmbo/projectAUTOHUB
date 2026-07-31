<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<c:set var="pageTitle" value="Ordine #${order.id} – AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-header">
  <div class="container">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb mb-2">
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home">Home</a></li>
        <c:choose>
          <c:when test="${sessionScope.sessionAdmin eq true}">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/orders">Ordini Admin</a></li>
          </c:when>
          <c:otherwise>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/orders">I Miei Ordini</a></li>
          </c:otherwise>
        </c:choose>
        <li class="breadcrumb-item active">Ordine #${order.id}</li>
      </ol>
    </nav>
    <h1>ORDINE #${order.id}</h1>
    <c:choose>
      <c:when test="${order.status eq 'confirmed'}">
        <span class="badge-confirmed">Confermato</span>
      </c:when>
      <c:when test="${order.status eq 'shipped'}">
        <span class="badge-shipped">Spedito</span>
      </c:when>
      <c:otherwise>
        <span class="badge-pending">In Attesa</span>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<div class="container mb-5">

  <div class="row g-4">

    <!-- Items Table -->
    <div class="col-lg-7">
      <div class="card-dark p-4">
        <h5 style="font-size:0.65rem; letter-spacing:3px; text-transform:uppercase; color:#888; margin-bottom:1.5rem; border-bottom:1px solid rgba(212,175,55,0.1); padding-bottom:0.75rem;">
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
                <td style="color:#ccc;">${item.productName}</td>
                <td>
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
              <td colspan="3" style="text-align:right; font-size:0.7rem; letter-spacing:2px; text-transform:uppercase; color:#888; padding-top:1rem;">Totale Ordine</td>
              <td style="color:#D4AF37; font-weight:700; font-size:1.2rem; padding-top:1rem;">
                <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>

    <!-- Info Cards -->
    <div class="col-lg-5">
      <!-- Shipping -->
      <div class="card-dark p-4 mb-4">
        <h5 style="font-size:0.65rem; letter-spacing:3px; text-transform:uppercase; color:#888; margin-bottom:1rem;"><i class="bi bi-geo-alt me-2"></i>Indirizzo di Spedizione</h5>
        <p style="color:#ccc; font-size:0.9rem; line-height:2; margin:0;">
          ${order.shippingName}<br>
          ${order.shippingAddress}<br>
          ${order.shippingCity}<c:if test="${not empty order.shippingPostal}">, ${order.shippingPostal}</c:if><br>
          ${order.shippingCountry}
        </p>
      </div>

      <!-- Payment -->
      <div class="card-dark p-4 mb-4">
        <h5 style="font-size:0.65rem; letter-spacing:3px; text-transform:uppercase; color:#888; margin-bottom:1rem;"><i class="bi bi-credit-card me-2"></i>Pagamento</h5>
        <p style="margin:0; line-height:2.2; font-size:0.88rem; color:#888;">
          Metodo: <span style="color:#ccc;">${order.paymentMethod}</span><br>
          Data:
          <span style="color:#ccc;">
            <c:choose>
              <c:when test="${not empty order.createdAtAsDate}">
                <fmt:formatDate value="${order.createdAtAsDate}" pattern="dd MMM yyyy HH:mm"/>
              </c:when>
              <c:otherwise>N/D</c:otherwise>
            </c:choose>
          </span><br>
          Stato:
          <c:choose>
            <c:when test="${order.status eq 'confirmed'}">
              <span class="badge-confirmed">Confermato</span>
            </c:when>
            <c:when test="${order.status eq 'shipped'}">
              <span class="badge-shipped">Spedito</span>
            </c:when>
            <c:otherwise>
              <span class="badge-pending">In Attesa</span>
            </c:otherwise>
          </c:choose>
        </p>
      </div>

      <!-- Back button -->
      <c:choose>
        <c:when test="${sessionScope.sessionAdmin eq true}">
          <a href="${pageContext.request.contextPath}/admin/orders" class="btn-dark-outline d-block text-center">
            <i class="bi bi-arrow-left me-1"></i>Torna agli Ordini
          </a>
        </c:when>
        <c:otherwise>
          <a href="${pageContext.request.contextPath}/orders" class="btn-dark-outline d-block text-center">
            <i class="bi bi-arrow-left me-1"></i>Torna ai Miei Ordini
          </a>
        </c:otherwise>
      </c:choose>
    </div>

  </div>
</div>

<jsp:include page="footer.jsp"/>
