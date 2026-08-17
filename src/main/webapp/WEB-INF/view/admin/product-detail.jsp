<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Prodotto #${product.id} - AutoHUB Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Montserrat:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/admin.css">
</head>
<body class="admin-body">

<jsp:include page="sidebar.jsp"><jsp:param name="active" value="products"/></jsp:include>

<div class="admin-main">
  <div class="admin-topbar">
    <h1 class="admin-page-title">Dettagli Prodotto</h1>
    <div class="d-flex gap-2">
      <c:if test="${not product.deleted}">
        <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${product.id}" class="btn-admin">
          <i class="bi bi-pencil"></i>Modifica
        </a>
      </c:if>
      <a href="${pageContext.request.contextPath}/admin/products" class="btn-admin-outline">
        <i class="bi bi-arrow-left"></i>Indietro
      </a>
    </div>
  </div>

  <div class="admin-content">
    <div class="row g-4">
      <div class="col-lg-5">
        <div style="border:1px solid rgba(212,175,55,0.15); border-radius:4px; overflow:hidden; aspect-ratio:4/3; background:#111;">
          <c:choose>
            <c:when test="${not empty product.imageUrl and fn:startsWith(product.imageUrl, '/images/products/')}">
              <img src="${pageContext.request.contextPath}${product.imageUrl}"
                   alt="${product.name}" style="width:100%; height:100%; object-fit:cover;">
            </c:when>
            <c:otherwise>
              <div class="d-flex align-items-center justify-content-center" style="width:100%; height:100%; color:#666; font-size:0.72rem; letter-spacing:2px; text-transform:uppercase;">
                Nessuna immagine
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <div class="col-lg-7">
        <div style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.15); border-radius:4px; padding:1.5rem;">
          <div class="d-flex justify-content-between align-items-start mb-3">
            <h3 style="font-family:'Playfair Display',serif; color:#fff; font-size:1.3rem; margin:0;">${product.name}</h3>
            <span class="${product.deleted ? 'status-deleted' : 'status-active'}">${product.deleted ? 'Eliminato' : 'Attivo'}</span>
          </div>

          <table style="width:100%; font-size:0.85rem; border-collapse:collapse;">
            <tr>
              <td style="color:#666; padding:0.5rem 0; width:40%; letter-spacing:1px;">Categoria</td>
              <td style="color:#ccc;">${product.category}</td>
            </tr>
            <tr>
              <td style="color:#666; padding:0.5rem 0; border-top:1px solid rgba(255,255,255,0.04);">Prezzo</td>
              <td style="color:#D4AF37; font-weight:700; border-top:1px solid rgba(255,255,255,0.04);">
                <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="&euro;" maxFractionDigits="2"/>
              </td>
            </tr>
            <tr>
              <td style="color:#666; padding:0.5rem 0; border-top:1px solid rgba(255,255,255,0.04);">Stock</td>
              <td style="color:${product.stockQuantity gt 0 ? '#5cb85c' : '#ff6b6b'}; border-top:1px solid rgba(255,255,255,0.04);">${product.stockQuantity} unit&agrave;</td>
            </tr>
            <tr>
              <td style="color:#666; padding:0.5rem 0; border-top:1px solid rgba(255,255,255,0.04);">ID Prodotto</td>
              <td style="color:#555; border-top:1px solid rgba(255,255,255,0.04);">#${product.id}</td>
            </tr>
            <tr>
              <td style="color:#666; padding:0.5rem 0; border-top:1px solid rgba(255,255,255,0.04);">Creato</td>
              <td style="color:#888; border-top:1px solid rgba(255,255,255,0.04);">
                <c:choose>
                  <c:when test="${not empty product.createdAtAsDate}">
                    <fmt:formatDate value="${product.createdAtAsDate}" pattern="dd/MM/yyyy HH:mm"/>
                  </c:when>
                  <c:otherwise>N/D</c:otherwise>
                </c:choose>
              </td>
            </tr>
            <tr>
              <td style="color:#666; padding:0.5rem 0; border-top:1px solid rgba(255,255,255,0.04);">Aggiornato</td>
              <td style="color:#888; border-top:1px solid rgba(255,255,255,0.04);">
                <c:choose>
                  <c:when test="${not empty product.updatedAtAsDate}">
                    <fmt:formatDate value="${product.updatedAtAsDate}" pattern="dd/MM/yyyy HH:mm"/>
                  </c:when>
                  <c:otherwise>N/D</c:otherwise>
                </c:choose>
              </td>
            </tr>
          </table>

          <c:if test="${not empty product.description}">
            <div style="margin-top:1rem; padding-top:1rem; border-top:1px solid rgba(212,175,55,0.1);">
              <p style="color:#666; font-size:0.7rem; letter-spacing:2px; text-transform:uppercase; margin-bottom:0.5rem;">Descrizione</p>
              <p style="color:#aaa; font-size:0.88rem; line-height:1.7; margin:0;">${product.description}</p>
            </div>
          </c:if>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
