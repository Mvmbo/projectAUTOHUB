<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Accesso Admin – AutoHUB</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Montserrat:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/admin.css">
</head>
<body class="admin-login-page" data-ctx="${pageContext.request.contextPath}">

<div class="admin-login-card">
  <div class="admin-login-logo">
    <h2>AUTOHUB</h2>
    <p>PANNELLO DI CONTROLLO ADMIN</p>
  </div>

  <c:if test="${not empty error}">
    <div class="admin-alert admin-alert-error mb-4">${error}</div>
  </c:if>

  <form id="adminLoginForm" action="${pageContext.request.contextPath}/admin/login" method="post" novalidate>

    <div class="mb-3">
      <label class="form-label" for="username" style="color:#888; font-size:0.72rem; letter-spacing:1px; text-transform:uppercase;">Username</label>
      <input type="text" id="username" name="username" class="form-control"
             placeholder="Username admin" autocomplete="username">
      <div class="field-error" id="username-error"></div>
    </div>

    <div class="mb-4">
      <label class="form-label" for="password" style="color:#888; font-size:0.72rem; letter-spacing:1px; text-transform:uppercase;">Password</label>
      <input type="password" id="password" name="password" class="form-control"
             placeholder="Password admin" autocomplete="current-password">
      <div class="field-error" id="password-error"></div>
    </div>

    <button type="submit" class="btn-admin w-100" style="justify-content:center;">
      <i class="bi bi-shield-lock me-2"></i>Accedi al Pannello
    </button>

  </form>

  <div class="text-center mt-4">
    <a href="${pageContext.request.contextPath}/home" style="font-size:0.75rem; color:#555; letter-spacing:1px;">
      <i class="bi bi-arrow-left me-1"></i>Torna al Sito
    </a>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/scripts/validation.js"></script>
</body>
</html>
