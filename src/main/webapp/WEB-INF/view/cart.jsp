<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<c:set var="pageTitle" value="Carrello – AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-header">
  <div class="container">
    <h1>IL TUO CARRELLO</h1>
    <p style="color:#888; font-size:0.75rem; letter-spacing:2px; text-transform:uppercase;">
      <c:choose>
        <c:when test="${not empty cart}">
          ${cart.totalItems} articoli
        </c:when>
        <c:otherwise>
          0 articoli
        </c:otherwise>
      </c:choose>
    </p>
  </div>
</div>

<div class="container mb-5">

  <!-- Error Message Display -->
  <c:if test="${not empty errorMessage}">
    <div class="alert alert-danger" style="background:rgba(220,53,69,0.15); border:1px solid rgba(220,53,69,0.3); color:#ff6b6b; padding:1.5rem; border-radius:4px; margin-bottom:2rem;">
      <div style="display:flex; align-items:center; gap:1rem;">
        <i class="bi bi-exclamation-triangle-fill" style="font-size:1.5rem;"></i>
        <div>
          <h5 style="margin:0 0 0.5rem 0; color:#ff6b6b;">Si è verificato un errore</h5>
          <p style="margin:0; color:#ccc;">${errorMessage}</p>
        </div>
      </div>
      <div style="margin-top:1rem;">
        <a href="${pageContext.request.contextPath}/catalog" class="btn-gold" style="display:inline-block; padding:0.5rem 1.5rem;">
          <i class="bi bi-arrow-left me-2"></i>Vai al Catalogo
        </a>
      </div>
    </div>
  </c:if>

  <c:choose>
    <c:when test="${empty cart.items}">
      <!-- Empty Cart State -->
      <div id="cartEmpty" class="empty-state">
        <div class="empty-state-icon"><i class="bi bi-bag"></i></div>
        <h3>Il tuo carrello è vuoto</h3>
        <p>Scopri la nostra collezione di supercar di lusso.</p>
        <a href="${pageContext.request.contextPath}/catalog" class="btn-gold mt-3">
          <i class="bi bi-arrow-right me-2"></i>Continua lo Shopping
        </a>
      </div>
    </c:when>
    <c:otherwise>
      <!-- Cart with items -->
      <div id="cartEmpty" style="display:none;" class="empty-state">
        <div class="empty-state-icon"><i class="bi bi-bag"></i></div>
        <h3>Il tuo carrello è vuoto</h3>
        <p>Tutti i prodotti sono stati rimossi.</p>
        <a href="${pageContext.request.contextPath}/catalog" class="btn-gold mt-3">
          <i class="bi bi-arrow-right me-2"></i>Continua lo Shopping
        </a>
      </div>

      <div id="cartTable">
        <div class="row g-4">
          <div class="col-lg-8">
            <!-- Cart Items Table -->
            <div class="card-dark p-0" style="overflow:hidden;">
              <table class="cart-table" style="width:100%;">
                <thead>
                  <tr>
                    <th colspan="2">Prodotto</th>
                    <th>Prezzo Unitario</th>
                    <th>Quantità</th>
                    <th>Subtotale</th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="item" items="${cart.items}">
                    <c:if test="${not empty item and not empty item.product}">
                      <tr data-cart-row="${item.product.id}">
                        <td data-label="Immagine" style="width:90px; padding:1rem;">
                          <c:choose>
                            <c:when test="${not empty item.product.imageUrl and fn:startsWith(item.product.imageUrl, '/images/products/')}">
                              <img src="${pageContext.request.contextPath}${item.product.imageUrl}" alt="${item.product.name}" class="cart-item-img">
                            </c:when>
                            <c:otherwise>
                              <div class="cart-item-img d-flex align-items-center justify-content-center" style="background:#111; color:#666; font-size:0.65rem;">N/D</div>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td data-label="Prodotto">
                          <a href="${pageContext.request.contextPath}/product?id=${item.product.id}" class="cart-item-name">${item.product.name}</a>
                          <div class="cart-item-category">${item.product.category}</div>
                        </td>
                        <td data-label="Prezzo Unitario" style="white-space:nowrap;">
                          <span style="color:#D4AF37; font-weight:600;">
                            <c:choose>
                              <c:when test="${not empty item.product.price}">
                                <fmt:formatNumber value="${item.product.price}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                              </c:when>
                              <c:otherwise>€ 0,00</c:otherwise>
                            </c:choose>
                          </span>
                        </td>
                        <td data-label="Quantità">
                          <div class="qty-control">
                            <button class="qty-btn btn-qty-minus" data-product-id="${item.product.id}" type="button"><i class="bi bi-dash"></i></button>
                            <input class="qty-input" type="number" value="${item.quantity}" min="0" data-product-id="${item.product.id}">
                            <button class="qty-btn btn-qty-plus" data-product-id="${item.product.id}" type="button"><i class="bi bi-plus"></i></button>
                          </div>
                        </td>
                        <td data-label="Subtotale">
                          <span data-subtotal="${item.product.id}" style="color:#D4AF37; font-weight:700; font-size:1.05rem;">
                            <fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                          </span>
                        </td>
                        <td data-label="">
                          <button class="btn-danger-outline btn-remove-item" data-product-id="${item.product.id}" title="Rimuovi">
                            <i class="bi bi-trash"></i>
                          </button>
                        </td>
                      </tr>
                    </c:if>
                  </c:forEach>
                </tbody>
              </table>
            </div>

            <!-- Cart actions -->
            <div id="cartActions" class="d-flex justify-content-between align-items-center mt-3">
              <a href="${pageContext.request.contextPath}/catalog" class="btn-dark-outline">
                <i class="bi bi-arrow-left me-1"></i>Continua gli Acquisti
              </a>
              <button id="btnClearCart" class="btn-danger-outline">
                <i class="bi bi-trash me-1"></i>Svuota Carrello
              </button>
            </div>
          </div>

          <!-- Order Summary -->
          <div class="col-lg-4">
            <div class="cart-total-section">
              <h5 style="font-size:0.7rem; letter-spacing:3px; text-transform:uppercase; color:#888; margin-bottom:1.5rem;">Riepilogo Ordine</h5>

              <c:forEach var="item" items="${cart.items}">
                <c:if test="${not empty item and not empty item.product}">
                  <div class="d-flex justify-content-between mb-2" style="font-size:0.82rem;">
                    <span style="color:#aaa;">${item.product.name} &times; ${item.quantity}</span>
                    <span style="color:#fff;">
                      <fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                    </span>
                  </div>
                </c:if>
              </c:forEach>

              <hr style="border-color:rgba(212,175,55,0.15); margin:1rem 0;">

              <div class="d-flex justify-content-between align-items-end">
                <span class="cart-total-label">Totale</span>
                <span class="cart-total-value" id="cartGrandTotal">
                  <fmt:formatNumber value="${cart.totalAmount}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                </span>
              </div>

              <div class="mt-4">
                <c:choose>
                  <c:when test="${not empty sessionScope.sessionUser}">
                    <a href="${pageContext.request.contextPath}/checkout" class="btn-gold w-100 text-center d-block">
                      <i class="bi bi-lock me-2"></i>Procedi al Pagamento
                    </a>
                  </c:when>
                  <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login?redirectUrl=/checkout" class="btn-gold w-100 text-center d-block">
                      <i class="bi bi-person me-2"></i>Accedi per Pagare
                    </a>
                    <p style="font-size:0.72rem; color:#666; text-align:center; margin-top:0.5rem; letter-spacing:1px;">
                      Accedi o registrati per completare l'ordine
                    </p>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="mt-3 text-center" style="font-size:0.72rem; color:#555; letter-spacing:1px;">
                <i class="bi bi-shield-check me-1" style="color:#D4AF37"></i>Pagamento sicuro
              </div>
            </div>
          </div>
        </div>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<jsp:include page="footer.jsp"/>
