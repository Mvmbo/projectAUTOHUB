<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard - AutoHUB Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Montserrat:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/admin.css">
</head>
<body class="admin-body">

<jsp:include page="sidebar.jsp"><jsp:param name="active" value="dashboard"/></jsp:include>

<div class="admin-main">
  <div class="admin-topbar">
    <h1 class="admin-page-title">Dashboard</h1>
    <div class="admin-user-info">
      Accesso come <span>${not empty sessionScope.sessionUser.username ? sessionScope.sessionUser.username : 'Admin'}</span>
    </div>
  </div>

  <div class="admin-content">
    <c:if test="${not empty error}">
      <div class="admin-alert admin-alert-error mb-4">${error}</div>
    </c:if>

    <div class="row g-4 mb-4">
      <div class="col-lg-4 col-md-6">
        <div class="stat-card">
          <div class="stat-icon"><i class="bi bi-car-front"></i></div>
          <div>
            <div class="stat-value">${empty productCount ? 0 : productCount}</div>
            <div class="stat-label">Prodotti Attivi</div>
          </div>
        </div>
      </div>
      <div class="col-lg-4 col-md-6">
        <div class="stat-card">
          <div class="stat-icon"><i class="bi bi-bag-check"></i></div>
          <div>
            <div class="stat-value">${empty todayOrders ? 0 : todayOrders}</div>
            <div class="stat-label">Ordini Oggi</div>
          </div>
        </div>
      </div>
      <div class="col-lg-4 col-md-6">
        <div class="stat-card">
          <div class="stat-icon"><i class="bi bi-people"></i></div>
          <div>
            <div class="stat-value">${empty userCount ? 0 : userCount}</div>
            <div class="stat-label">Utenti Registrati</div>
          </div>
        </div>
      </div>
    </div>

    <div style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.15); border-radius:4px; overflow:hidden;">
      <div style="padding:1.25rem 1.5rem; border-bottom:1px solid rgba(212,175,55,0.1); display:flex; justify-content:space-between; align-items:center;">
        <span style="font-size:0.65rem; letter-spacing:3px; text-transform:uppercase; color:#888;">Ordini Recenti</span>
        <a href="${pageContext.request.contextPath}/admin/orders" class="btn-admin btn-admin-sm">Vedi Tutti</a>
      </div>
      <div style="overflow-x:auto;">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Ordine #</th>
              <th>ID Utente</th>
              <th>Data</th>
              <th>Totale</th>
              <th>Stato</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${not empty recentOrders}">
                <c:forEach var="o" items="${recentOrders}">
                  <tr>
                    <td style="color:#D4AF37;">#${o.id}</td>
                    <td>#${o.userId}</td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty o.createdAtAsDate}">
                          <fmt:formatDate value="${o.createdAtAsDate}" pattern="dd/MM/yyyy" type="date"/>
                        </c:when>
                        <c:otherwise>N/D</c:otherwise>
                      </c:choose>
                    </td>
                    <td style="color:#D4AF37;">
                      <fmt:formatNumber value="${empty o.totalAmount ? 0 : o.totalAmount}" type="currency" currencySymbol="&euro;" maxFractionDigits="2"/>
                    </td>
                    <td><span class="status-${empty o.status ? 'pending' : o.status}">${empty o.status ? 'pending' : o.status}</span></td>
                    <td><a href="${pageContext.request.contextPath}/order-detail?id=${o.id}" class="btn-admin-outline btn-admin-sm">Dettagli</a></td>
                  </tr>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <tr><td colspan="6" style="text-align:center; color:#555; padding:2rem;">Nessun ordine</td></tr>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
