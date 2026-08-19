<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard Concessionario - AutoHUB</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/admin.css">
</head>
<body class="admin-body">
<jsp:include page="sidebar.jsp"><jsp:param name="active" value="dashboard"/></jsp:include>
<div class="admin-main">
  <div class="admin-topbar">
    <h1 class="admin-page-title">Dashboard Concessionario</h1>
    <div class="admin-user-info">Accesso come <span>${sessionScope.sessionUser.username}</span></div>
  </div>
  <div class="admin-content">
    <c:if test="${not empty error}"><div class="admin-alert admin-alert-error mb-4">${error}</div></c:if>
    <c:if test="${param.success eq 'profile'}"><div class="admin-alert admin-alert-success mb-4">Sede concessionario aggiornata con coordinate geografiche.</div></c:if>
    <div class="stats-grid">
      <div class="stat-card"><p>Veicoli in vendita</p><h2>${not empty saleVehicles ? fn:length(saleVehicles) : 0}</h2></div>
      <div class="stat-card"><p>Veicoli a noleggio</p><h2>${not empty rentalVehicles ? fn:length(rentalVehicles) : 0}</h2></div>
    </div>
    <div style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.15); border-radius:4px; padding:1.5rem; margin-top:1.5rem;">
      <h5 style="color:#D4AF37; font-size:0.75rem; letter-spacing:3px; margin-bottom:1.5rem;">
        <i class="bi bi-geo-alt me-2"></i>SEDE CONCESSIONARIO
      </h5>
      <form method="post" action="${pageContext.request.contextPath}/dealer/dashboard">
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label" for="address">Indirizzo</label>
            <input class="form-control" id="address" name="address" value="${sessionScope.sessionUser.address}" placeholder="Via Roma 1">
          </div>
          <div class="col-md-3">
            <label class="form-label" for="city">Citta</label>
            <input class="form-control" id="city" name="city" value="${sessionScope.sessionUser.city}" placeholder="Milano">
          </div>
          <div class="col-md-3">
            <label class="form-label" for="postalCode">CAP</label>
            <input class="form-control" id="postalCode" name="postalCode" value="${sessionScope.sessionUser.postalCode}" placeholder="20100">
          </div>
          <div class="col-md-4">
            <label class="form-label" for="country">Paese</label>
            <input class="form-control" id="country" name="country" value="${empty sessionScope.sessionUser.country ? 'Italia' : sessionScope.sessionUser.country}">
          </div>
          <div class="col-md-4">
            <label class="form-label" for="phone">Telefono</label>
            <input class="form-control" id="phone" name="phone" value="${sessionScope.sessionUser.phone}" placeholder="+39 333 1234567">
          </div>
          <div class="col-md-4">
            <label class="form-label">Coordinate</label>
            <div class="form-control" style="background:#111; color:#D4AF37;">
              <c:choose>
                <c:when test="${not empty sessionScope.sessionUser.latitude}">
                  ${sessionScope.sessionUser.latitude}, ${sessionScope.sessionUser.longitude}
                </c:when>
                <c:otherwise>Non ancora calcolate</c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
        <button type="submit" class="btn-admin mt-3"><i class="bi bi-save"></i>Salva sede e coordinate</button>
      </form>
    </div>
    <div class="d-flex gap-3 flex-wrap mt-4">
      <a href="${pageContext.request.contextPath}/dealer/sale-vehicles?action=new" class="btn-admin"><i class="bi bi-plus-lg"></i>Aggiungi veicolo vendita</a>
      <a href="${pageContext.request.contextPath}/dealer/rental-vehicles?action=new" class="btn-admin-outline"><i class="bi bi-plus-lg"></i>Aggiungi veicolo noleggio</a>
    </div>
  </div>
</div>
</body>
</html>
