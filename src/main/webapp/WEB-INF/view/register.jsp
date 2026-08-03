<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<c:set var="pageTitle" value="Registrati – AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="auth-page" style="min-height:calc(100vh - 80px); padding:3rem 0;">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-lg-8 col-md-10">
        <div class="auth-card">

          <h1 class="auth-title">UNISCITI AD AUTOHUB</h1>
          <p class="auth-subtitle">Crea il tuo account esclusivo</p>

          <c:if test="${not empty errors.general}">
            <div class="alert-error-block">${errors.general}</div>
          </c:if>

          <form id="registerForm" action="${pageContext.request.contextPath}/register" method="post" novalidate>

            <!-- Account Details -->
            <p style="font-size:0.65rem; letter-spacing:3px; text-transform:uppercase; color:#D4AF37; border-bottom:1px solid rgba(212,175,55,0.15); padding-bottom:0.5rem; margin-bottom:1.25rem;">Dati Account</p>
            <div class="account-type-selector mb-4">
              <label class="account-type-option">
                <input type="radio" name="accountType" value="customer" ${empty formData.accountType or formData.accountType eq 'customer' ? 'checked' : ''}>
                <span>
                  <strong>Cliente</strong>
                  <small>Acquista veicoli, ricambi e prenota noleggi.</small>
                </span>
              </label>
              <label class="account-type-option">
                <input type="radio" name="accountType" value="dealer" ${formData.accountType eq 'dealer' ? 'checked' : ''}>
                <span>
                  <strong>Concessionario</strong>
                  <small>Pubblica veicoli in vendita e nella sezione noleggio.</small>
                </span>
              </label>
            </div>

            <div class="row g-3 mb-3">
              <div class="col-md-6">
                <label class="form-label" for="username">Nome Utente *</label>
                <input type="text" id="username" name="username" class="form-control ${not empty errors.username ? 'error-field' : ''}"
                       value="${not empty formData.username ? formData.username : ''}"
                       placeholder="es. mario_rossi" autocomplete="username">
                <div class="field-error" id="username-error">${errors.username}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label" for="email">Indirizzo Email *</label>
                <input type="email" id="email" name="email" class="form-control ${not empty errors.email ? 'error-field' : ''}"
                       value="${not empty formData.email ? formData.email : ''}"
                       placeholder="tu@esempio.com" autocomplete="email">
                <div class="field-error" id="email-error">${errors.email}</div>
              </div>
            </div>

            <div class="row g-3 mb-4">
              <div class="col-md-6">
                <label class="form-label" for="password">Password *</label>
                <input type="password" id="password" name="password" class="form-control ${not empty errors.password ? 'error-field' : ''}"
                       placeholder="Min. 8 caratteri" autocomplete="new-password">
                <div class="field-error" id="password-error">${errors.password}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label" for="confirmPassword">Conferma Password *</label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control ${not empty errors.confirmPassword ? 'error-field' : ''}"
                       placeholder="Ripeti la password" autocomplete="new-password">
                <div class="field-error" id="confirmPassword-error">${errors.confirmPassword}</div>
              </div>
            </div>

            <!-- Personal Info -->
            <p style="font-size:0.65rem; letter-spacing:3px; text-transform:uppercase; color:#D4AF37; border-bottom:1px solid rgba(212,175,55,0.15); padding-bottom:0.5rem; margin-bottom:1.25rem;">Informazioni Personali</p>
            <div class="row g-3 mb-3">
              <div class="col-md-6">
                <label class="form-label" for="fullName">Nome Completo *</label>
                <input type="text" id="fullName" name="fullName" class="form-control ${not empty errors.fullName ? 'error-field' : ''}"
                       value="${not empty formData.fullName ? formData.fullName : ''}"
                       placeholder="Il tuo nome completo" autocomplete="name">
                <div class="field-error" id="fullName-error">${errors.fullName}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label" for="phone">Numero di Telefono</label>
                <input type="tel" id="phone" name="phone" class="form-control"
                       value="${not empty formData.phone ? formData.phone : ''}"
                       placeholder="+39 333 1234567" autocomplete="tel">
                <div class="field-error" id="phone-error"></div>
              </div>
            </div>

            <!-- Address -->
            <p style="font-size:0.65rem; letter-spacing:3px; text-transform:uppercase; color:#D4AF37; border-bottom:1px solid rgba(212,175,55,0.15); padding-bottom:0.5rem; margin-bottom:1.25rem;">Indirizzo di Spedizione (Opzionale)</p>
            <div class="mb-3">
              <label class="form-label" for="address">Indirizzo</label>
              <input type="text" id="address" name="address" class="form-control"
                     value="${not empty formData.address ? formData.address : ''}"
                     placeholder="Via Roma 1" autocomplete="street-address">
            </div>
            <div class="row g-3 mb-4">
              <div class="col-md-5">
                <label class="form-label" for="city">Città</label>
                <input type="text" id="city" name="city" class="form-control"
                       value="${not empty formData.city ? formData.city : ''}"
                       placeholder="Milano" autocomplete="address-level2">
              </div>
              <div class="col-md-3">
                <label class="form-label" for="postalCode">CAP</label>
                <input type="text" id="postalCode" name="postalCode" class="form-control"
                       value="${not empty formData.postalCode ? formData.postalCode : ''}"
                       placeholder="20100" autocomplete="postal-code">
              </div>
              <div class="col-md-4">
                <label class="form-label" for="country">Paese</label>
                <input type="text" id="country" name="country" class="form-control"
                       value="${not empty formData.country ? formData.country : ''}"
                       placeholder="Italia" autocomplete="country-name">
              </div>
            </div>

            <button type="submit" class="btn-gold w-100">
              <i class="bi bi-person-plus me-2"></i>Crea Account
            </button>

            <hr style="border-color:rgba(212,175,55,0.1); margin:1.5rem 0;">

            <p style="text-align:center; font-size:0.82rem; color:#888;">
              Già registrato? <a href="${pageContext.request.contextPath}/login" style="color:#D4AF37;">Accedi</a>
            </p>
          </form>

        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="footer.jsp"/>
