<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="isEdit" value="${mode eq 'rental' ? not empty rentalVehicle : not empty saleVehicle}"/>
<c:set var="vehicleName" value="${mode eq 'rental' ? rentalVehicle.name : saleVehicle.name}"/>
<c:set var="vehicleDescription" value="${mode eq 'rental' ? rentalVehicle.description : saleVehicle.description}"/>
<c:set var="vehicleCategory" value="${mode eq 'rental' ? rentalVehicle.category : saleVehicle.category}"/>
<c:set var="vehicleImage" value="${mode eq 'rental' ? rentalVehicle.imageUrl : saleVehicle.imageUrl}"/>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${isEdit ? 'Modifica Veicolo' : 'Nuovo Veicolo'} - AutoHUB</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/admin.css">
</head>
<body class="admin-body">
<jsp:include page="sidebar.jsp"><jsp:param name="active" value="${mode eq 'rental' ? 'rental' : 'sale'}"/></jsp:include>
<div class="admin-main">
  <div class="admin-topbar">
    <h1 class="admin-page-title">
      ${isEdit ? 'Modifica' : 'Nuovo'} ${mode eq 'rental' ? 'Veicolo Noleggio' : 'Veicolo Vendita'}
    </h1>
    <a href="${pageContext.request.contextPath}${mode eq 'rental' ? '/dealer/rental-vehicles' : '/dealer/sale-vehicles'}" class="btn-admin-outline">
      <i class="bi bi-arrow-left"></i>Torna alla lista
    </a>
  </div>
  <div class="admin-content">
    <c:if test="${not empty error}"><div class="admin-alert admin-alert-error mb-3">${error}</div></c:if>
    <form class="admin-form" method="post" enctype="multipart/form-data" action="${pageContext.request.contextPath}${mode eq 'rental' ? '/dealer/rental-vehicles' : '/dealer/sale-vehicles'}">
      <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
      <c:if test="${isEdit}">
        <input type="hidden" name="id" value="${mode eq 'rental' ? rentalVehicle.id : saleVehicle.id}">
      </c:if>
      <div class="admin-form-section">
        <p class="admin-form-section-title"><i class="bi bi-info-circle me-2"></i>Informazioni base</p>
        <div class="row g-3">
          <c:if test="${mode eq 'rental'}">
            <div class="col-md-6"><label class="form-label">Brand</label><input class="form-control" name="brand" value="${not empty rentalVehicle ? rentalVehicle.brand : ''}" required></div>
          </c:if>
          <div class="${mode eq 'rental' ? 'col-md-6' : 'col-12'}"><label class="form-label">Nome veicolo *</label><input class="form-control" name="name" value="${vehicleName}" required></div>
          <div class="col-12"><label class="form-label">Descrizione</label><textarea class="form-control" rows="4" name="description">${vehicleDescription}</textarea></div>
          <div class="col-md-6"><label class="form-label">Categoria</label><input class="form-control" name="category" value="${vehicleCategory}"></div>
          <div class="col-md-6">
            <label class="form-label" for="vehicleImages">Immagini veicolo *</label>
            <input class="form-control" id="vehicleImages" name="vehicleImages" type="file" accept="image/*" multiple ${isEdit ? '' : 'required'}>
            <small style="display:block; color:#777; margin-top:0.45rem;">
              Carica da 3 a 5 immagini. In modifica, selezionando nuovi file sostituisci le immagini precedenti.
              Verranno salvate nella cartella del server <strong>/images/products/</strong>.
            </small>
          </div>
          <div class="col-12">
            <div id="vehicleImagePreviewGrid" class="d-flex flex-wrap gap-2 mt-2" style="min-height:96px;">
              <c:choose>
                <c:when test="${not empty vehicleImage and fn:startsWith(vehicleImage, '/images/products/')}">
                  <img src="${pageContext.request.contextPath}${vehicleImage}" alt="Immagine attuale"
                       style="width:120px; height:90px; object-fit:cover; border-radius:4px; border:1px solid rgba(212,175,55,0.18);">
                </c:when>
                <c:otherwise>
                  <span id="vehiclePreviewPlaceholder" style="display:block; color:#444; font-size:0.75rem; letter-spacing:2px; text-transform:uppercase;">
                    Anteprima immagini
                  </span>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </div>
      <div class="admin-form-section">
        <p class="admin-form-section-title"><i class="bi bi-currency-euro me-2"></i>Dati commerciali</p>
        <div class="row g-3">
          <c:choose>
            <c:when test="${mode eq 'rental'}">
              <div class="col-md-4"><label class="form-label">Prezzo al giorno *</label><input class="form-control" name="pricePerDay" type="number" step="0.01" min="0" value="${not empty rentalVehicle ? rentalVehicle.pricePerDay : ''}" required></div>
              <div class="col-md-4"><label class="form-label">Citta</label><input class="form-control" name="city" value="${not empty rentalVehicle ? rentalVehicle.city : ''}"></div>
              <div class="col-md-2"><label class="form-label">Latitudine</label><input class="form-control" name="latitude" type="number" step="0.0000001" value="${not empty rentalVehicle ? rentalVehicle.latitude : ''}"></div>
              <div class="col-md-2"><label class="form-label">Longitudine</label><input class="form-control" name="longitude" type="number" step="0.0000001" value="${not empty rentalVehicle ? rentalVehicle.longitude : ''}"></div>
            </c:when>
            <c:otherwise>
              <div class="col-md-4"><label class="form-label">Prezzo *</label><input class="form-control" name="price" type="number" step="0.01" min="0" value="${not empty saleVehicle ? saleVehicle.price : ''}" required></div>
              <div class="col-md-4"><label class="form-label">Quantita</label><input class="form-control" name="stockQuantity" type="number" min="0" value="${not empty saleVehicle ? saleVehicle.stockQuantity : '1'}"></div>
              <div class="col-md-4"><label class="form-label">Anno</label><input class="form-control" name="productionYear" type="number" min="1900" value="${not empty saleVehicle ? saleVehicle.productionYear : ''}"></div>
              <div class="col-md-4"><label class="form-label">Motore</label><input class="form-control" name="engine" value="${not empty saleVehicle ? saleVehicle.engine : ''}"></div>
              <div class="col-md-4"><label class="form-label">Potenza</label><input class="form-control" name="power" value="${not empty saleVehicle ? saleVehicle.power : ''}"></div>
              <div class="col-md-4"><label class="form-label">Chilometraggio</label><input class="form-control" name="mileage" value="${not empty saleVehicle ? saleVehicle.mileage : ''}"></div>
              <div class="col-md-6"><label class="form-label">Cambio</label><input class="form-control" name="transmission" value="${not empty saleVehicle ? saleVehicle.transmission : ''}"></div>
              <div class="col-md-6"><label class="form-label">Trazione</label><input class="form-control" name="drivetrain" value="${not empty saleVehicle ? saleVehicle.drivetrain : ''}"></div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
      <button type="submit" class="btn-admin"><i class="bi bi-check-lg"></i>${isEdit ? 'Aggiorna veicolo' : 'Pubblica veicolo'}</button>
    </form>
  </div>
</div>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    var imageInput = document.getElementById('vehicleImages');
    var previewGrid = document.getElementById('vehicleImagePreviewGrid');
    var placeholder = document.getElementById('vehiclePreviewPlaceholder');
    if (!imageInput || !previewGrid) return;

    imageInput.addEventListener('change', function() {
      previewGrid.innerHTML = '';
      if (imageInput.files.length === 0) {
        if (placeholder) {
          previewGrid.appendChild(placeholder);
        }
        return;
      }

      Array.from(imageInput.files).slice(0, 5).forEach(function(file) {
        var img = document.createElement('img');
        img.src = URL.createObjectURL(file);
        img.alt = file.name;
        img.style.width = '120px';
        img.style.height = '90px';
        img.style.objectFit = 'cover';
        img.style.borderRadius = '4px';
        img.style.border = '1px solid rgba(212,175,55,0.18)';
        img.onload = function() { URL.revokeObjectURL(img.src); };
        previewGrid.appendChild(img);
      });

      if (imageInput.files.length < 3 || imageInput.files.length > 5) {
        var warning = document.createElement('span');
        warning.style.color = '#D4AF37';
        warning.style.fontSize = '0.78rem';
        warning.style.alignSelf = 'center';
        warning.textContent = 'Seleziona da 3 a 5 immagini.';
        previewGrid.appendChild(warning);
      }

    });
  });
</script>
</body>
</html>
