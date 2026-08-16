<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ordini – AutoHUB Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Montserrat:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/admin.css">
</head>
<body class="admin-body" data-ctx="${pageContext.request.contextPath}">

<jsp:include page="sidebar.jsp"><jsp:param name="active" value="orders"/></jsp:include>

<div class="admin-main">
  <div class="admin-topbar">
    <h1 class="admin-page-title">Gestione Ordini</h1>
    <div class="admin-user-info">Totale: <span>${not empty orders ? orders.size() : 0}</span> ordini</div>
  </div>

  <div class="admin-content">

    <c:if test="${not empty error}">
      <div class="admin-alert admin-alert-error mb-4">${error}</div>
    </c:if>

    <div style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.15); border-radius:4px; padding:1.5rem; margin-bottom:1.5rem;">
      <p style="font-size:0.65rem; letter-spacing:3px; text-transform:uppercase; color:#888; margin-bottom:1rem;"><i class="bi bi-funnel me-2"></i>Filtra Ordini</p>
      <form id="adminOrderFilterForm" action="${pageContext.request.contextPath}/admin/orders" method="get">
        <div class="row g-3 align-items-end">
          <div class="col-md-3">
            <label class="form-label" style="color:#888; font-size:0.7rem; letter-spacing:1px; text-transform:uppercase;">Da Data</label>
            <input type="date" name="fromDate" class="form-control"
                   value="${not empty fromDate ? fromDate : ''}">
          </div>
          <div class="col-md-3">
            <label class="form-label" style="color:#888; font-size:0.7rem; letter-spacing:1px; text-transform:uppercase;">A Data</label>
            <input type="date" name="toDate" class="form-control"
                   value="${not empty toDate ? toDate : ''}">
          </div>
          <div class="col-md-3">
            <label class="form-label" style="color:#888; font-size:0.7rem; letter-spacing:1px; text-transform:uppercase;">Cliente</label>
            <select name="userId" class="form-select">
              <option value="">Tutti i clienti</option>
              <c:forEach var="u" items="${users}">
                <option value="${u.id}" ${not empty filterUserId and filterUserId eq u.id ? 'selected' : ''}>
                  ${u.fullName != null ? u.fullName : u.username} (#${u.id})
                </option>
              </c:forEach>
            </select>
          </div>
          <div class="col-md-3">
            <div class="d-flex gap-2">
              <button type="submit" class="btn-admin" style="flex:1; justify-content:center;">
                <i class="bi bi-search"></i>Applica
              </button>
              <button type="button" id="btnResetFilter" class="btn-admin-outline">
                <i class="bi bi-x-lg"></i>
              </button>
            </div>
          </div>
        </div>
      </form>

      <c:if test="${not empty fromDate or not empty toDate or not empty filterUserId}">
        <div class="d-flex gap-2 flex-wrap mt-3 align-items-center">
          <span style="font-size:0.65rem; letter-spacing:2px; color:#666; text-transform:uppercase;">Filtri attivi:</span>
          <c:if test="${not empty fromDate}">
            <span style="background:rgba(212,175,55,0.1); color:#D4AF37; border:1px solid rgba(212,175,55,0.2); font-size:0.65rem; letter-spacing:1px; padding:4px 10px; border-radius:2px;">Da: ${fromDate}</span>
          </c:if>
          <c:if test="${not empty toDate}">
            <span style="background:rgba(212,175,55,0.1); color:#D4AF37; border:1px solid rgba(212,175,55,0.2); font-size:0.65rem; letter-spacing:1px; padding:4px 10px; border-radius:2px;">A: ${toDate}</span>
          </c:if>
          <c:if test="${not empty filterUserId}">
            <span style="background:rgba(212,175,55,0.1); color:#D4AF37; border:1px solid rgba(212,175,55,0.2); font-size:0.65rem; letter-spacing:1px; padding:4px 10px; border-radius:2px;">Utente: #${filterUserId}</span>
          </c:if>
        </div>
      </c:if>
    </div>

    <div style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.15); border-radius:4px; overflow:hidden;">
      <div style="overflow-x:auto;">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Ordine #</th>
              <th>ID Cliente</th>
              <th>Data</th>
              <th>Destinazione</th>
              <th>Pagamento</th>
              <th>Totale</th>
              <th>Stato</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${not empty orders}">
                <c:forEach var="o" items="${orders}">
                  <tr>
                    <td style="color:#D4AF37; font-weight:600;">#${o.id}</td>
                    <td style="color:#888;">Utente #${o.userId}</td>
                    <td><fmt:formatDate value="${o.createdAtAsDate}" pattern="dd/MM/yyyy" type="date"/></td>
                    <td style="color:#aaa; font-size:0.82rem;">${o.shippingCity}, ${o.shippingCountry}</td>
                    <td style="color:#888; font-size:0.82rem;">${o.paymentMethod}</td>
                    <td style="color:#D4AF37; font-weight:600;">
                      <fmt:formatNumber value="${o.totalAmount}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                    </td>
                    <td><span class="status-${o.status}">${o.status}</span></td>
                    <td>
                      <a href="${pageContext.request.contextPath}/order-detail?id=${o.id}" class="btn-admin-outline btn-admin-sm">
                        <i class="bi bi-eye"></i>Dettagli
                      </a>
                    </td>
                  </tr>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <tr><td colspan="8" style="text-align:center; color:#555; padding:2.5rem;">Nessun ordine con i filtri selezionati.</td></tr>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </div>

  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/scripts/catalog.js"></script>
</body>
</html>
