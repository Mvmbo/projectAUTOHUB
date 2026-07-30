<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<c:set var="pageTitle" value="Accedi – AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<div class="auth-page" style="min-height:calc(100vh - 80px);">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-md-5 col-sm-10">
        <div class="auth-card">

          <h1 class="auth-title">ACCESSO MEMBRI</h1>
          <p class="auth-subtitle">Accedi al tuo account AutoHUB</p>

          <c:if test="${not empty infoMessage}">
            <div class="alert alert-info" style="background:rgba(212,175,55,0.1); border:1px solid rgba(212,175,55,0.3); color:#D4AF37; padding:1rem; border-radius:4px; margin-bottom:1.5rem; text-align:center;">
              <i class="bi bi-info-circle me-2"></i>${infoMessage}
            </div>
          </c:if>

          <c:if test="${not empty error}">
            <div class="alert-error-block">${error}</div>
          </c:if>

          <form id="loginForm" action="${pageContext.request.contextPath}/login" method="post" novalidate>
            <c:if test="${not empty redirectUrl}">
              <input type="hidden" name="redirectUrl" value="${redirectUrl}">
            </c:if>
            <c:if test="${empty redirectUrl and not empty param.redirectUrl}">
              <input type="hidden" name="redirectUrl" value="${param.redirectUrl}">
            </c:if>

            <div class="mb-3">
              <label class="form-label" for="username">Nome Utente</label>
              <input type="text" id="username" name="username" class="form-control"
                     value="${not empty username ? username : ''}"
                     placeholder="Inserisci il tuo username" autocomplete="username">
              <div class="field-error" id="username-error"></div>
            </div>

            <div class="mb-4">
              <label class="form-label" for="password">Password</label>
              <input type="password" id="password" name="password" class="form-control"
                     placeholder="Inserisci la password" autocomplete="current-password">
              <div class="field-error" id="password-error"></div>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-4">
              <label style="display:flex; align-items:center; gap:0.5rem; font-size:0.8rem; color:#888; cursor:pointer;">
                <input type="checkbox" style="accent-color:#D4AF37;"> Ricordami
              </label>
            </div>

            <button type="submit" class="btn-gold w-100">
              <i class="bi bi-box-arrow-in-right me-2"></i>Accedi
            </button>

            <hr style="border-color:rgba(212,175,55,0.1); margin:1.5rem 0;">

            <p style="text-align:center; font-size:0.82rem; color:#888;">
              Non hai un account?
              <a href="${pageContext.request.contextPath}/register" style="color:#D4AF37;">Registrati</a>
            </p>
          </form>

        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="footer.jsp"/>
