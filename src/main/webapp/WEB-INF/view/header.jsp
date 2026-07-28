<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${not empty pageTitle ? pageTitle : 'AutoHUB'}</title>

  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&family=Montserrat:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <!-- Bootstrap 5 -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <!-- Leaflet CSS for maps -->
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">

  <!-- Custom Styles -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/main.css">
</head>
<body data-ctx="${pageContext.request.contextPath}">

<nav class="navbar navbar-expand-lg">
  <div class="container">
    <a class="navbar-brand" href="${pageContext.request.contextPath}/home">
      AUTO<span>HUB</span>
    </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navMenu">
      <ul class="navbar-nav ms-auto align-items-center gap-1">

        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/home">Home</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/catalog">Acquista</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/rentals">Noleggi</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/cart">
            <i class="bi bi-bag"></i>
            Carrello
            <c:choose>
              <c:when test="${not empty sessionScope.cart and sessionScope.cart.totalItems > 0}">
                <span class="cart-badge" id="cartBadge">${sessionScope.cart.totalItems}</span>
              </c:when>
              <c:otherwise>
                <span class="cart-badge" id="cartBadge" style="display:none">0</span>
              </c:otherwise>
            </c:choose>
          </a>
        </li>

        <c:choose>
          <c:when test="${not empty sessionScope.sessionUser}">
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                <i class="bi bi-person-circle"></i>
                ${not empty sessionScope.sessionUser.fullName ? sessionScope.sessionUser.fullName : sessionScope.sessionUser.username}
              </a>
              <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-end" style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.2);">
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/orders" style="color:#ccc; font-size:0.8rem; letter-spacing:1px;">I Miei Ordini</a></li>
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/my-rentals" style="color:#ccc; font-size:0.8rem; letter-spacing:1px;">I Miei Noleggi</a></li>
                <c:if test="${sessionScope.sessionAdmin eq true}">
                  <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard" style="color:#D4AF37; font-size:0.8rem; letter-spacing:1px;">Pannello Admin</a></li>
                </c:if>
                <c:if test="${sessionScope.sessionDealer eq true}">
                  <li><a class="dropdown-item" href="${pageContext.request.contextPath}/dealer/dashboard" style="color:#D4AF37; font-size:0.8rem; letter-spacing:1px;">Area Concessionario</a></li>
                </c:if>
                <li><hr class="dropdown-divider" style="border-color:rgba(212,175,55,0.15)"></li>
                <li>
                  <form action="${pageContext.request.contextPath}/logout" method="post" style="margin:0">
                    <button type="submit" class="dropdown-item" style="color:#ff6b6b; font-size:0.8rem; letter-spacing:1px; background:none; border:none; width:100%; text-align:left; padding:0.4rem 1rem; cursor:pointer;">
                      <i class="bi bi-box-arrow-right me-1"></i>Esci
                    </button>
                  </form>
                </li>
              </ul>
            </li>
          </c:when>
          <c:otherwise>
            <li class="nav-item">
              <a class="nav-link" href="${pageContext.request.contextPath}/login">Accedi</a>
            </li>
            <li class="nav-item">
              <a class="btn-gold ms-2" href="${pageContext.request.contextPath}/register" style="font-size:0.72rem; padding:10px 24px;">Registrati</a>
            </li>
          </c:otherwise>
        </c:choose>
      </ul>
    </div>
  </div>
</nav>
