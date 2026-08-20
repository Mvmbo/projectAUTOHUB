<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Veicoli Noleggio - AutoHUB</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/admin.css">
</head>
<body class="admin-body">
<jsp:include page="sidebar.jsp"><jsp:param name="active" value="rental"/></jsp:include>
<div class="admin-main">
  <div class="admin-topbar">
    <h1 class="admin-page-title">Veicoli a Noleggio</h1>
    <a href="${pageContext.request.contextPath}/dealer/rental-vehicles?action=new" class="btn-admin"><i class="bi bi-plus-lg"></i>Nuovo Veicolo</a>
  </div>
  <div class="admin-content">
    <c:if test="${param.success eq 'created'}"><div class="admin-alert admin-alert-success mb-3">Veicolo creato con successo.</div></c:if>
    <c:if test="${param.success eq 'updated'}"><div class="admin-alert admin-alert-success mb-3">Veicolo aggiornato con successo.</div></c:if>
    <c:if test="${param.success eq 'deleted'}"><div class="admin-alert admin-alert-success mb-3">Veicolo eliminato con successo.</div></c:if>
    <c:if test="${param.success eq 'not-owned'}"><div class="admin-alert admin-alert-error mb-3">Non puoi eliminare un veicolo di un altro concessionario.</div></c:if>
    <c:if test="${not empty error}"><div class="admin-alert admin-alert-error mb-3">${error}</div></c:if>
    <div style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.15); border-radius:4px; overflow:hidden;">
      <table class="admin-table">
        <thead><tr><th>ID</th><th>Nome</th><th>Brand</th><th>Citta</th><th>Prezzo/giorno</th><th>Stato</th><th>Azioni</th></tr></thead>
        <tbody>
          <c:forEach var="v" items="${rentalVehicles}">
            <tr>
              <td>#${v.id}</td><td>${v.name}</td><td>${v.brand}</td><td>${v.city}</td>
              <td><fmt:formatNumber value="${v.pricePerDay}" type="currency" currencySymbol="EUR "/></td>
              <td>${v.available ? 'Disponibile' : 'Non disponibile'}</td>
              <td>
                <c:if test="${v.available}">
                  <div class="d-flex gap-1 flex-wrap">
                    <a href="${pageContext.request.contextPath}/dealer/rental-vehicles?action=edit&id=${v.id}" class="btn-admin btn-admin-sm">
                      <i class="bi bi-pencil"></i> Modifica
                    </a>
                    <form method="post" action="${pageContext.request.contextPath}/dealer/rental-vehicles" style="margin:0;">
                      <input type="hidden" name="action" value="delete">
                      <input type="hidden" name="id" value="${v.id}">
                      <button type="submit" class="btn-admin-danger btn-admin-sm" onclick="return confirm('Eliminare questo veicolo a noleggio?');">
                        <i class="bi bi-trash"></i> Elimina
                      </button>
                    </form>
                  </div>
                </c:if>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty rentalVehicles}"><tr><td colspan="7" style="text-align:center; padding:2rem;">Nessun veicolo a noleggio pubblicato.</td></tr></c:if>
        </tbody>
      </table>
    </div>
  </div>
</div>
</body>
</html>
