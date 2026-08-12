<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Prodotti – AutoHUB Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Montserrat:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/admin.css">
</head>
<body class="admin-body" data-ctx="${pageContext.request.contextPath}">

<jsp:include page="sidebar.jsp"><jsp:param name="active" value="products"/></jsp:include>

<div class="admin-main">
  <div class="admin-topbar">
    <h1 class="admin-page-title">Catalogo Prodotti</h1>
    <a href="${pageContext.request.contextPath}/admin/products?action=new" class="btn-admin">
      <i class="bi bi-plus-lg"></i>Nuovo Prodotto
    </a>
  </div>

  <div class="admin-content">

    <c:if test="${not empty param.success}">
      <div class="admin-alert admin-alert-success mb-3">
        Prodotto
        <c:choose>
          <c:when test="${param.success eq 'created'}">creato con successo.</c:when>
          <c:when test="${param.success eq 'updated'}">aggiornato con successo.</c:when>
          <c:when test="${param.success eq 'deleted'}">eliminato (soft delete).</c:when>
        </c:choose>
      </div>
    </c:if>

    <c:if test="${not empty error}">
      <div class="admin-alert admin-alert-error mb-3">${error}</div>
    </c:if>

    <div class="filter-bar">
      <i class="bi bi-search" style="color:#666;"></i>
      <input type="text" id="adminProductSearch" placeholder="Cerca prodotti..." style="background:#111; border:1px solid rgba(255,255,255,0.08); color:#ccc; padding:8px 14px; border-radius:3px; font-size:0.82rem; flex:1; min-width:200px; outline:none;">

      <select id="adminCatFilter" style="background:#111; border:1px solid rgba(255,255,255,0.08); color:#ccc; padding:8px 14px; border-radius:3px; font-size:0.82rem; outline:none;">
        <option value="">Tutte le categorie</option>
        <c:forEach var="cat" items="${categories}">
          <option value="${cat}">${cat}</option>
        </c:forEach>
      </select>
    </div>

    <div style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.15); border-radius:4px; overflow:hidden;">
      <div style="overflow-x:auto;">
        <table class="admin-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Immagine</th>
              <th>Nome</th>
              <th>Categoria</th>
              <th>Prezzo</th>
              <th>Stock</th>
              <th>Stato</th>
              <th>Azioni</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${not empty products}">
                <c:forEach var="p" items="${products}">
                  <tr data-product-row="true"
                      data-product-name="${p.name}"
                      data-product-cat="${p.category}"
                      class="${p.deleted ? 'deleted-row' : ''}">
                    <td style="color:#555;">#${p.id}</td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty p.imageUrl and fn:startsWith(p.imageUrl, '/images/products/')}">
                          <img src="${pageContext.request.contextPath}${p.imageUrl}" alt="${p.name}" class="table-thumb">
                        </c:when>
                        <c:otherwise>
                          <div class="table-thumb d-flex align-items-center justify-content-center" style="background:#111; color:#666; font-size:0.65rem; letter-spacing:1px;">N/D</div>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td style="max-width:220px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                      <a href="${pageContext.request.contextPath}/admin/products?action=view&id=${p.id}"
                         style="color:#ccc; text-decoration:none;">${p.name}</a>
                    </td>
                    <td><span style="font-size:0.72rem; letter-spacing:1px; color:#888;">${p.category}</span></td>
                    <td style="color:#D4AF37; font-weight:600; white-space:nowrap;">
                      <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                    </td>
                    <td style="color:${p.stockQuantity gt 0 ? '#5cb85c' : '#ff6b6b'};">${p.stockQuantity}</td>
                    <td>
                      <c:choose>
                        <c:when test="${p.deleted}"><span class="status-deleted">Eliminato</span></c:when>
                        <c:otherwise><span class="status-active">Attivo</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <div class="d-flex gap-1 flex-wrap">
                        <a href="${pageContext.request.contextPath}/admin/products?action=view&id=${p.id}" class="btn-admin-outline btn-admin-sm">
                          <i class="bi bi-eye"></i>
                        </a>
                        <c:if test="${!p.deleted}">
                          <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${p.id}" class="btn-admin btn-admin-sm">
                            <i class="bi bi-pencil"></i>
                          </a>
                          <button type="button" class="btn-admin-danger btn-admin-sm"
                                  onclick="confirmDelete(${p.id}, '${p.name}')">
                            <i class="bi bi-trash"></i>
                          </button>
                        </c:if>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <tr><td colspan="8" style="text-align:center; color:#555; padding:2rem;">Nessun prodotto trovato.</td></tr>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </div>

  </div>
</div>

<div class="modal fade" id="deleteModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered" style="max-width:400px;">
    <div class="modal-content" style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.2); border-radius:4px;">
      <div class="modal-header" style="border-bottom:1px solid rgba(212,175,55,0.1);">
        <h5 class="modal-title" style="font-family:'Playfair Display',serif; color:#D4AF37; font-size:1rem; letter-spacing:2px;">CONFERMA ELIMINAZIONE</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body" style="color:#888; font-size:0.88rem; padding:1.5rem;">
        <p>Vuoi eliminare <strong id="deleteProductName" style="color:#ccc;"></strong>?</p>
        <p style="font-size:0.78rem; color:#555;">Eliminazione soft: il prodotto sarà nascosto dal catalogo ma conservato negli ordini.</p>
      </div>
      <div class="modal-footer" style="border-top:1px solid rgba(212,175,55,0.1); gap:0.5rem;">
        <button type="button" class="btn-admin-outline" data-bs-dismiss="modal">Annulla</button>
        <form id="deleteForm" action="${pageContext.request.contextPath}/admin/products" method="post" style="margin:0;">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="id" id="deleteProductId">
          <button type="submit" class="btn-admin-danger">Elimina Prodotto</button>
        </form>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/scripts/catalog.js"></script>
<script>
  function confirmDelete(id, name) {
    document.getElementById('deleteProductId').value = id;
    document.getElementById('deleteProductName').textContent = name;
    var modal = new bootstrap.Modal(document.getElementById('deleteModal'));
    modal.show();
  }
</script>
</body>
</html>
