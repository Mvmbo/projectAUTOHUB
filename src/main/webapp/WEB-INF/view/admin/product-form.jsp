<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${not empty product ? 'Modifica Prodotto' : 'Nuovo Prodotto'} - AutoHUB Admin</title>
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
    <h1 class="admin-page-title">${not empty product ? 'Modifica Prodotto' : 'Nuovo Prodotto'}</h1>
    <a href="${pageContext.request.contextPath}/admin/products" class="btn-admin-outline">
      <i class="bi bi-arrow-left"></i>Torna alla Lista
    </a>
  </div>

  <div class="admin-content">
    <div class="row g-4">
      <div class="col-lg-8">
        <form id="productForm" action="${pageContext.request.contextPath}/admin/products" method="post" class="admin-form" enctype="multipart/form-data" novalidate>
          <input type="hidden" name="action" value="${not empty product ? 'update' : 'create'}">
          <c:set var="currentImage" value="${not empty product and not empty product.imageUrl and fn:startsWith(product.imageUrl, '/images/products/') ? product.imageUrl : ''}"/>
          <c:if test="${not empty product}">
            <input type="hidden" name="id" value="${product.id}">
            <input type="hidden" name="existingImageUrls" value="${not empty product.imageUrls ? product.imageUrls : product.imageUrl}">
          </c:if>

          <div class="admin-form-section">
            <p class="admin-form-section-title"><i class="bi bi-info-circle me-2"></i>Informazioni Base</p>

            <div class="mb-3">
              <label class="form-label" for="name">Nome Prodotto *</label>
              <input type="text" id="name" name="name" class="form-control"
                     value="${not empty product ? product.name : ''}"
                     placeholder="es. Lamborghini Huracan Evo - Custom Build">
              <div class="field-error" id="name-error"></div>
            </div>

            <div class="mb-3">
              <label class="form-label" for="description">Descrizione</label>
              <textarea id="description" name="description" class="form-control" rows="5"
                        placeholder="Descrizione dettagliata del prodotto...">${not empty product ? product.description : ''}</textarea>
            </div>

            <div class="mb-3">
              <label class="form-label" for="category">Categoria *</label>
              <select id="category" name="category" class="form-select">
                <option value="">Seleziona una categoria...</option>
                <c:set var="cats" value="Supercars,Performance Parts,Merchandise,Accessories,Other"/>
                <c:forTokens var="cat" items="${cats}" delims=",">
                  <option value="${cat}" ${not empty product and product.category eq cat ? 'selected' : ''}>${cat}</option>
                </c:forTokens>
              </select>
              <div class="field-error" id="category-error"></div>
            </div>
          </div>

          <div class="admin-form-section">
            <p class="admin-form-section-title"><i class="bi bi-currency-euro me-2"></i>Prezzo e Inventario</p>
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label" for="price">Prezzo (&euro;) *</label>
                <input type="number" id="price" name="price" class="form-control"
                       step="0.01" min="0.01"
                       value="${not empty product ? product.price : ''}"
                       placeholder="0.00">
                <div class="field-error" id="price-error"></div>
              </div>
              <div class="col-md-6">
                <label class="form-label" for="stockQuantity">Quantit&agrave; in Stock *</label>
                <input type="number" id="stockQuantity" name="stockQuantity" class="form-control"
                       min="0"
                       value="${not empty product ? product.stockQuantity : '0'}"
                       placeholder="0">
              </div>
            </div>
          </div>

          <div class="admin-form-section">
            <p class="admin-form-section-title"><i class="bi bi-image me-2"></i>Media</p>
            <div class="mb-3">
              <label class="form-label" for="productImages">Immagini prodotto *</label>
              <input type="file" id="productImages" name="productImages" class="form-control"
                     accept="image/*" multiple ${empty product ? 'required' : ''}>
              <div class="field-error" id="productImages-error"></div>
              <small style="display:block; color:#777; margin-top:0.45rem;">
                Carica da 3 a 5 immagini. Verranno salvate nella cartella del server <strong>/images/products/</strong>.
              </small>

              <div class="img-preview-wrap mt-3" style="min-height:150px;">
                <div id="imagePreviewGrid" class="d-flex flex-wrap gap-2">
                  <c:if test="${not empty currentImage}">
                    <img src="${pageContext.request.contextPath}${currentImage}" alt="Immagine attuale"
                         style="display:block; width:120px; height:90px; object-fit:cover; border-radius:4px;">
                  </c:if>
                </div>
                <span id="previewPlaceholder" style="${not empty currentImage ? 'display:none' : 'display:block; color:#444; font-size:0.75rem; letter-spacing:2px;'}">
                  ANTEPRIMA IMMAGINI
                </span>
              </div>
            </div>
          </div>

          <div class="d-flex gap-3">
            <button type="submit" class="btn-admin">
              <i class="bi bi-check-lg me-1"></i>
              ${not empty product ? 'Aggiorna Prodotto' : 'Crea Prodotto'}
            </button>
            <a href="${pageContext.request.contextPath}/admin/products" class="btn-admin-outline">Annulla</a>
          </div>
        </form>
      </div>

      <div class="col-lg-4">
        <c:if test="${not empty product}">
          <div style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.15); border-radius:4px; padding:1.5rem;">
            <p style="font-size:0.65rem; letter-spacing:3px; text-transform:uppercase; color:#888; margin-bottom:1rem; border-bottom:1px solid rgba(212,175,55,0.1); padding-bottom:0.75rem;">Info Prodotto</p>
            <p style="font-size:0.82rem; color:#888; line-height:2.2; margin:0;">
              ID: <span style="color:#ccc;">#${product.id}</span><br>
              Stato: <span class="${product.deleted ? 'status-deleted' : 'status-active'}">${product.deleted ? 'Eliminato' : 'Attivo'}</span><br>
              Creato:
              <span style="color:#ccc;">
                <c:choose>
                  <c:when test="${not empty product.createdAtAsDate}">
                    <fmt:formatDate value="${product.createdAtAsDate}" pattern="dd/MM/yyyy"/>
                  </c:when>
                  <c:otherwise>N/D</c:otherwise>
                </c:choose>
              </span><br>
              Aggiornato:
              <span style="color:#ccc;">
                <c:choose>
                  <c:when test="${not empty product.updatedAtAsDate}">
                    <fmt:formatDate value="${product.updatedAtAsDate}" pattern="dd/MM/yyyy"/>
                  </c:when>
                  <c:otherwise>N/D</c:otherwise>
                </c:choose>
              </span>
            </p>
          </div>
        </c:if>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/scripts/validation.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    var imageInput = document.getElementById('productImages');
    var previewGrid = document.getElementById('imagePreviewGrid');
    var placeholder = document.getElementById('previewPlaceholder');
    if (imageInput && previewGrid) {
      imageInput.addEventListener('change', function() {
        previewGrid.innerHTML = '';
        Array.from(imageInput.files).slice(0, 5).forEach(function(file) {
          var img = document.createElement('img');
          img.src = URL.createObjectURL(file);
          img.alt = file.name;
          img.style.width = '120px';
          img.style.height = '90px';
          img.style.objectFit = 'cover';
          img.style.borderRadius = '4px';
          img.onload = function() { URL.revokeObjectURL(img.src); };
          previewGrid.appendChild(img);
        });
        if (placeholder) {
          placeholder.style.display = previewGrid.children.length ? 'none' : 'block';
        }
      });
    }
  });
</script>
</body>
</html>
