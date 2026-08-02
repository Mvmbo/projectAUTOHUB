<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<c:set var="pageTitle" value="Pagamento – AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="page-header">
  <div class="container">
    <h1>CHECKOUT</h1>
    <p style="color:#888; font-size:0.75rem; letter-spacing:2px; text-transform:uppercase;">Transazione Sicura &amp; Privata</p>
  </div>
</div>

<div class="container mb-5">

  <c:if test="${not empty error}">
    <div class="alert-error-block mb-4">${error}</div>
  </c:if>

  <form id="checkoutForm" action="${pageContext.request.contextPath}/checkout" method="post" novalidate>
    <div class="row g-5">

      <!-- ===== Left: Shipping + Payment ===== -->
      <div class="col-lg-7">

        <!-- Shipping -->
        <div class="card-dark p-4 mb-4">
          <h5 class="checkout-section-title"><i class="bi bi-geo-alt me-2"></i>Informazioni di Spedizione</h5>

          <div class="mb-3">
            <label class="form-label" for="shippingName">Nome Completo *</label>
            <input type="text" id="shippingName" name="shippingName" class="form-control ${not empty errors.shippingName ? 'error-field' : ''}"
                   value="${not empty formData.shippingName ? formData.shippingName : (not empty sessionScope.sessionUser.fullName ? sessionScope.sessionUser.fullName : '')}"
                   placeholder="Nome completo del destinatario">
            <div class="field-error" id="shippingName-error">${errors.shippingName}</div>
          </div>

          <div class="mb-3">
            <label class="form-label" for="shippingAddress">Indirizzo *</label>
            <input type="text" id="shippingAddress" name="shippingAddress" class="form-control ${not empty errors.shippingAddress ? 'error-field' : ''}"
                   value="${not empty formData.shippingAddress ? formData.shippingAddress : (not empty sessionScope.sessionUser.address ? sessionScope.sessionUser.address : '')}"
                   placeholder="Via, numero civico, piano">
            <div class="field-error" id="shippingAddress-error">${errors.shippingAddress}</div>
          </div>

          <div class="row g-3 mb-3">
            <div class="col-md-5">
              <label class="form-label" for="shippingCity">Città *</label>
              <input type="text" id="shippingCity" name="shippingCity" class="form-control ${not empty errors.shippingCity ? 'error-field' : ''}"
                     value="${not empty formData.shippingCity ? formData.shippingCity : (not empty sessionScope.sessionUser.city ? sessionScope.sessionUser.city : '')}"
                     placeholder="Milano">
              <div class="field-error" id="shippingCity-error">${errors.shippingCity}</div>
            </div>
            <div class="col-md-3">
              <label class="form-label" for="shippingPostal">CAP *</label>
              <input type="text" id="shippingPostal" name="shippingPostal" class="form-control ${not empty errors.shippingPostal ? 'error-field' : ''}"
                     value="${not empty formData.shippingPostal ? formData.shippingPostal : ''}"
                     placeholder="20100">
              <div class="field-error" id="shippingPostal-error">${errors.shippingPostal}</div>
            </div>
            <div class="col-md-4">
              <label class="form-label" for="shippingCountry">Paese *</label>
              <input type="text" id="shippingCountry" name="shippingCountry" class="form-control ${not empty errors.shippingCountry ? 'error-field' : ''}"
                     value="${not empty formData.shippingCountry ? formData.shippingCountry : (not empty sessionScope.sessionUser.country ? sessionScope.sessionUser.country : '')}"
                     placeholder="Italia">
              <div class="field-error" id="shippingCountry-error">${errors.shippingCountry}</div>
            </div>
          </div>
        </div>

        <!-- Payment -->
        <div class="card-dark p-4">
          <h5 class="checkout-section-title"><i class="bi bi-credit-card me-2"></i>Metodo di Pagamento</h5>
          <div class="field-error" id="paymentMethod-error">${errors.paymentMethod}</div>

          <label class="payment-option">
            <input type="radio" name="paymentMethod" value="Credit Card"
                   ${empty formData.paymentMethod or formData.paymentMethod eq 'Credit Card' ? 'checked' : ''}>
            <i class="bi bi-credit-card" style="color:#D4AF37; font-size:1.3rem;"></i>
            <div>
              <div style="font-size:0.85rem; color:#fff;">Carta di Credito / Debito</div>
              <div style="font-size:0.72rem; color:#666;">Visa, Mastercard, Amex</div>
            </div>
          </label>

          <label class="payment-option">
            <input type="radio" name="paymentMethod" value="Bank Transfer"
                   ${formData.paymentMethod eq 'Bank Transfer' ? 'checked' : ''}>
            <i class="bi bi-bank" style="color:#D4AF37; font-size:1.3rem;"></i>
            <div>
              <div style="font-size:0.85rem; color:#fff;">Bonifico Bancario</div>
              <div style="font-size:0.72rem; color:#666;">Bonifico SEPA / SWIFT</div>
            </div>
          </label>

          <label class="payment-option">
            <input type="radio" name="paymentMethod" value="Cryptocurrency"
                   ${formData.paymentMethod eq 'Cryptocurrency' ? 'checked' : ''}>
            <i class="bi bi-currency-bitcoin" style="color:#D4AF37; font-size:1.3rem;"></i>
            <div>
              <div style="font-size:0.85rem; color:#fff;">Criptovalute</div>
              <div style="font-size:0.72rem; color:#666;">BTC, ETH, USDC</div>
            </div>
          </label>

          <!-- Credit Card Fields -->
          <div id="creditCardFields" class="mt-3" style="display:block;">
            <div class="mb-3">
              <label class="form-label" for="cardNumber">Numero Carta</label>
              <input type="text" id="cardNumber" name="cardNumber" class="form-control"
                     placeholder="1234 5678 9012 3456" maxlength="19">
              <div class="field-error" id="cardNumber-error"></div>
            </div>
            <div class="row g-3">
              <div class="col-6">
                <label class="form-label" for="cardExpiry">Data Scadenza</label>
                <input type="text" id="cardExpiry" name="cardExpiry" class="form-control"
                       placeholder="MM/AA" maxlength="5">
                <div class="field-error" id="cardExpiry-error"></div>
              </div>
              <div class="col-6">
                <label class="form-label" for="cardCvv">CVV</label>
                <input type="text" id="cardCvv" name="cardCvv" class="form-control"
                       placeholder="123" maxlength="4">
                <div class="field-error" id="cardCvv-error"></div>
              </div>
            </div>
            <p style="font-size:0.72rem; color:#555; margin-top:0.5rem; letter-spacing:1px;">
              <i class="bi bi-lock me-1" style="color:#D4AF37"></i>Simulazione pagamento – nessun addebito reale
            </p>
          </div>

          <div id="bankTransferFields" class="mt-3" style="display:none;">
            <div style="background:rgba(212,175,55,0.06); border:1px solid rgba(212,175,55,0.18); border-radius:4px; padding:1rem;">
              <p style="font-size:0.72rem; color:#D4AF37; letter-spacing:2px; text-transform:uppercase; margin-bottom:0.75rem;">
                <i class="bi bi-bank me-1"></i>Dati Bonifico
              </p>
              <div class="mb-3">
                <label class="form-label" for="bankAccountHolder">Intestatario Conto</label>
                <input type="text" id="bankAccountHolder" name="bankAccountHolder" class="form-control" placeholder="Nome intestatario">
              </div>
              <div class="row g-3">
                <div class="col-md-7">
                  <label class="form-label" for="bankIban">IBAN</label>
                  <input type="text" id="bankIban" name="bankIban" class="form-control" placeholder="IT60 X054 2811 1010 0000 0123 456">
                </div>
                <div class="col-md-5">
                  <label class="form-label" for="bankReference">Causale</label>
                  <input type="text" id="bankReference" name="bankReference" class="form-control" placeholder="Ordine AutoHUB">
                </div>
              </div>
              <p style="font-size:0.72rem; color:#666; margin:0.75rem 0 0;">Riceverai le coordinate AutoHUB nella conferma ordine.</p>
            </div>
          </div>

          <div id="cryptoFields" class="mt-3" style="display:none;">
            <div style="background:rgba(212,175,55,0.06); border:1px solid rgba(212,175,55,0.18); border-radius:4px; padding:1rem;">
              <p style="font-size:0.72rem; color:#D4AF37; letter-spacing:2px; text-transform:uppercase; margin-bottom:0.75rem;">
                <i class="bi bi-currency-bitcoin me-1"></i>Pagamento Crypto
              </p>
              <div class="row g-3">
                <div class="col-md-5">
                  <label class="form-label" for="cryptoCurrency">Valuta</label>
                  <select id="cryptoCurrency" name="cryptoCurrency" class="form-select">
                    <option value="BTC">Bitcoin (BTC)</option>
                    <option value="ETH">Ethereum (ETH)</option>
                    <option value="USDC">USD Coin (USDC)</option>
                  </select>
                </div>
                <div class="col-md-7">
                  <label class="form-label" for="cryptoWallet">Wallet Mittente</label>
                  <input type="text" id="cryptoWallet" name="cryptoWallet" class="form-control" placeholder="Indirizzo wallet">
                </div>
              </div>
              <p style="font-size:0.72rem; color:#666; margin:0.75rem 0 0;">Il wallet di destinazione e il QR code saranno mostrati nella conferma ordine.</p>
            </div>
          </div>

        </div>
      </div>

      <!-- ===== Right: Order Summary ===== -->
      <div class="col-lg-5">
        <div class="cart-total-section" style="position:sticky; top:100px;">
          <h5 style="font-size:0.7rem; letter-spacing:3px; text-transform:uppercase; color:#888; margin-bottom:1.5rem;">Riepilogo Ordine</h5>

          <c:forEach var="item" items="${cart.items}">
            <div class="d-flex justify-content-between align-items-start mb-3">
              <div style="flex:1; padding-right:1rem;">
                <div style="font-size:0.85rem; color:#ccc; line-height:1.4;">${item.product.name}</div>
                <div style="font-size:0.72rem; color:#666; letter-spacing:1px;">Qtà: ${item.quantity}</div>
              </div>
              <span style="color:#D4AF37; font-weight:600; white-space:nowrap; font-size:0.9rem;">
                <fmt:formatNumber value="${item.quantity * item.product.price}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
              </span>
            </div>
          </c:forEach>

          <hr style="border-color:rgba(212,175,55,0.15);">

          <div class="d-flex justify-content-between align-items-end mb-4">
            <span class="cart-total-label">Totale</span>
            <span class="cart-total-value">
              <fmt:formatNumber value="${cart.totalAmount}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
            </span>
          </div>

          <div id="paymentSuccessNotice" class="admin-alert admin-alert-success mb-3" style="display:none;">
            Pagamento effettuato. Sto confermando l'ordine...
          </div>

          <button type="submit" id="checkoutSubmitButton" class="btn-gold w-100" style="font-size:0.85rem;">
            <i class="bi bi-check-circle me-2"></i>Procedi al Pagamento
          </button>

          <a href="${pageContext.request.contextPath}/cart" class="btn-dark-outline w-100 text-center d-block mt-3">
            <i class="bi bi-arrow-left me-1"></i>Torna al Carrello
          </a>

          <div class="text-center mt-3" style="font-size:0.7rem; color:#555; letter-spacing:1px;">
            <i class="bi bi-shield-lock me-1" style="color:#D4AF37"></i>Crittografia SSL 256-bit &bull; Dati mai condivisi
          </div>
        </div>
      </div>

    </div>
  </form>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
  var form = document.getElementById('checkoutForm');
  var submitButton = document.getElementById('checkoutSubmitButton');
  var successNotice = document.getElementById('paymentSuccessNotice');
  var panels = {
    'Credit Card': document.getElementById('creditCardFields'),
    'Bank Transfer': document.getElementById('bankTransferFields'),
    'Cryptocurrency': document.getElementById('cryptoFields')
  };

  function selectedPaymentMethod() {
    var checked = document.querySelector('input[name="paymentMethod"]:checked');
    return checked ? checked.value : 'Credit Card';
  }

  function syncPaymentFields() {
    var selected = selectedPaymentMethod();
    Object.keys(panels).forEach(function(method) {
      if (panels[method]) {
        panels[method].style.display = method === selected ? 'block' : 'none';
      }
    });
  }

  function fieldValue(id) {
    var field = document.getElementById(id);
    return field ? field.value.trim() : '';
  }

  function creditCardDataLooksValid() {
    var cardNumber = fieldValue('cardNumber').replace(/\s/g, '');
    return fieldValue('shippingName') !== ''
      && fieldValue('shippingAddress') !== ''
      && fieldValue('shippingCity') !== ''
      && /^[A-Z0-9\s-]{3,10}$/i.test(fieldValue('shippingPostal'))
      && fieldValue('shippingCountry') !== ''
      && /^\d{16}$/.test(cardNumber)
      && /^(0[1-9]|1[0-2])\/\d{2}$/.test(fieldValue('cardExpiry'))
      && /^\d{3,4}$/.test(fieldValue('cardCvv'));
  }

  document.querySelectorAll('input[name="paymentMethod"]').forEach(function(input) {
    input.addEventListener('change', syncPaymentFields);
  });
  syncPaymentFields();

  if (form) {
    form.addEventListener('submit', function(event) {
      if (form.dataset.submitting === 'true') {
        return;
      }

      if (selectedPaymentMethod() === 'Credit Card' && creditCardDataLooksValid()) {
        event.preventDefault();
        if (successNotice) {
          successNotice.style.display = 'block';
        }
        if (submitButton) {
          submitButton.disabled = true;
          submitButton.innerHTML = '<i class="bi bi-check-circle me-2"></i>Pagamento effettuato';
        }
        form.dataset.submitting = 'true';
        window.setTimeout(function() {
          form.submit();
        }, 900);
      }
    });
  }
});
</script>

<jsp:include page="footer.jsp"/>
