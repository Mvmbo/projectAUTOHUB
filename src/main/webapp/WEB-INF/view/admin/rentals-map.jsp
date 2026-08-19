<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Veicoli Noleggiati – AutoHUB Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Montserrat:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/admin.css">
  <style>
    #map { background: #0D0D0D; }
    .car-marker { transition: transform 1.8s linear; }
    .car-marker-inner { animation: pulse 2s infinite; }
    .dealer-marker { filter: drop-shadow(0 2px 8px rgba(212,175,55,0.45)); }
    @keyframes pulse { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.2); } }
    .leaflet-popup-content-wrapper { background: #1A1A1A !important; color: #fff !important; border-radius: 8px !important; }
    .leaflet-popup-tip { background: #1A1A1A !important; }
  </style>
</head>
<body class="admin-body" data-ctx="${pageContext.request.contextPath}">

<jsp:include page="sidebar.jsp"><jsp:param name="active" value="rentals"/></jsp:include>

<!-- Main -->
<div class="admin-main">
  <div class="admin-topbar">
    <h1 class="admin-page-title"><i class="bi bi-map me-2"></i>Veicoli Noleggiati</h1>
    <span class="badge" style="background:rgba(212,175,55,0.2); color:#D4AF37; padding:8px 16px;">
      <i class="bi bi-car-front me-2"></i>${activeRentalsCount} attivi
    </span>
  </div>

  <div class="admin-content">

    <c:if test="${not empty error}">
      <div class="admin-alert admin-alert-error mb-3">${error}</div>
    </c:if>
    <c:if test="${param.success eq 'deleted'}">
      <div class="admin-alert admin-alert-success mb-3">Veicolo a noleggio eliminato con successo.</div>
    </c:if>

    <!-- Map Section -->
    <div style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.15); border-radius:4px; overflow:hidden; margin-bottom:1.5rem;">
      <div id="map" style="height: 450px; width: 100%;"></div>
    </div>

    <!-- Vehicles Table -->
    <div style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.15); border-radius:4px; padding:1.5rem;">
      <h5 style="color:#D4AF37; font-size:0.75rem; letter-spacing:3px; margin-bottom:1.5rem;">
        <i class="bi bi-list-ul me-2"></i>POSIZIONI VEICOLI
      </h5>

      <div class="table-responsive">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Veicolo</th>
              <th>Marca</th>
              <th>Città</th>
              <th>Coordinate</th>
              <th>Stato</th>
              <th>Azioni</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="v" items="${vehicles}">
              <tr>
                <td>
                  <div class="d-flex align-items-center gap-2">
                    <c:choose>
                      <c:when test="${not empty v.imageUrl and fn:startsWith(v.imageUrl, '/images/products/')}">
                        <img src="${pageContext.request.contextPath}${v.imageUrl}"
                             alt="${v.name}" style="width: 50px; height: 35px; object-fit: cover; border-radius: 4px;">
                      </c:when>
                      <c:otherwise>
                        <div class="d-flex align-items-center justify-content-center" style="width:50px; height:35px; background:#111; color:#666; border-radius:4px; font-size:0.62rem;">N/D</div>
                      </c:otherwise>
                    </c:choose>
                    <span style="color:#fff;">${v.name}</span>
                  </div>
                </td>
                <td>${v.brand}</td>
                <td><span style="color:#D4AF37;"><i class="bi bi-geo-alt me-1"></i>${v.city}</span></td>
                <td style="font-size:0.75rem; color:#888;">
                  <c:choose>
                    <c:when test="${not empty v.latitude}">${v.latitude}, ${v.longitude}</c:when>
                    <c:otherwise>N/A</c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${v.available}"><span class="status-active">Disponibile</span></c:when>
                    <c:otherwise><span class="status-deleted">Noleggiato</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <button class="btn-admin-outline btn-admin-sm"
                          onclick="focusVehicle(${v.id}, ${not empty v.latitude ? v.latitude : 'null'}, ${not empty v.longitude ? v.longitude : 'null'})">
                    <i class="bi bi-crosshair"></i>
                  </button>
                  <form method="post" action="${pageContext.request.contextPath}/admin/rentals" style="display:inline; margin-left:0.4rem;">
                    <input type="hidden" name="action" value="deleteVehicle">
                    <input type="hidden" name="id" value="${v.id}">
                    <button type="submit" class="btn-admin-danger btn-admin-sm" onclick="return confirm('Eliminare questo veicolo a noleggio?');">
                      <i class="bi bi-trash"></i>
                    </button>
                  </form>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Active Rentals -->
    <div style="background:#1A1A1A; border:1px solid rgba(212,175,55,0.15); border-radius:4px; padding:1.5rem; margin-top:1.5rem;">
      <h5 style="color:#D4AF37; font-size:0.75rem; letter-spacing:3px; margin-bottom:1.5rem;">
        <i class="bi bi-calendar-check me-2"></i>NOLEGGI ATTIVI
      </h5>

      <c:choose>
        <c:when test="${not empty activeRentals}">
          <div class="row g-3">
            <c:forEach var="r" items="${activeRentals}">
              <div class="col-md-6 col-lg-4">
                <div style="background:rgba(212,175,55,0.05); border:1px solid rgba(212,175,55,0.15); border-radius:8px; padding:1rem;">
                  <div class="d-flex justify-content-between align-items-start mb-2">
                    <div>
                      <h6 style="color:#fff; margin-bottom:0.25rem;">${r.vehicle.name}</h6>
                      <span style="color:#888; font-size:0.75rem;">${r.vehicle.brand}</span>
                    </div>
                    <span style="background:rgba(255,193,7,0.2); color:#ffc107; font-size:0.7rem; padding:2px 8px; border-radius:4px;">Attivo</span>
                  </div>
                  <div style="font-size:0.75rem; color:#888;">
                    <p style="margin-bottom:0.25rem;"><i class="bi bi-person me-1"></i>${r.userName}</p>
                    <p style="margin-bottom:0.25rem;"><i class="bi bi-shop me-1"></i>${r.vehicle.dealerName}</p>
                    <p style="margin-bottom:0.25rem;"><i class="bi bi-calendar me-1"></i>${r.startDate} - ${r.endDate}</p>
                    <p style="margin-bottom:0.25rem;"><i class="bi bi-geo-alt me-1"></i>${r.pickupCity}</p>
                    <p style="margin-bottom:0;"><i class="bi bi-currency-euro me-1"></i>
                      <fmt:formatNumber value="${r.totalAmount}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                    </p>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <div style="text-align:center; padding:3rem; color:#666;">
            <i class="bi bi-calendar-x" style="font-size:3rem; color:#333;"></i>
            <p style="margin-top:1rem;">Nessun noleggio attivo al momento</p>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
const map = L.map('map').setView([42.5, 12.5], 6);

L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', {
  attribution: '&copy; OpenStreetMap &copy; CARTO',
  subdomains: 'abcd',
  maxZoom: 19
}).addTo(map);

const carIcon = L.divIcon({
  className: 'car-marker',
  html: '<div class="car-marker-inner" style="background:#D4AF37; width:24px; height:24px; border-radius:50%; display:flex; align-items:center; justify-content:center; box-shadow:0 2px 8px rgba(212,175,55,0.5);"><i class="bi bi-car-front" style="color:#000; font-size:12px;"></i></div>',
  iconSize: [24, 24],
  iconAnchor: [12, 12]
});

const dealerIcon = L.divIcon({
  className: 'dealer-marker',
  html: '<div style="background:#111; border:2px solid #D4AF37; width:28px; height:28px; border-radius:50%; display:flex; align-items:center; justify-content:center;"><i class="bi bi-shop" style="color:#D4AF37; font-size:13px;"></i></div>',
  iconSize: [28, 28],
  iconAnchor: [14, 14]
});

const activeRentalCars = ${not empty activeRentalCarsJson ? activeRentalCarsJson : '[]'};
const dealers = ${not empty dealersJson ? dealersJson : '[]'};

const markers = {};
const dealerMarkers = {};
const carMarkers = [];
const routeBounds = [];

function safeText(value) {
  return String(value == null ? '' : value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function hasValidDealerPosition(vehicle) {
  return vehicle.hasDealerCoordinates === true &&
    Number.isFinite(Number(vehicle.dealerLat)) &&
    Number.isFinite(Number(vehicle.dealerLng));
}

dealers.forEach(dealer => {
  const lat = Number(dealer.lat);
  const lng = Number(dealer.lng);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    return;
  }

  const marker = L.marker([lat, lng], {icon: dealerIcon, title: dealer.name}).addTo(map);
  marker.bindPopup(
    '<div style="padding:0.5rem;">' +
      '<strong style="color:#D4AF37;">' + safeText(dealer.name || 'Concessionario') + '</strong><br>' +
      '<span>' + safeText(dealer.address || 'Indirizzo non indicato') + '</span><br>' +
      '<span>' + safeText(dealer.city || 'Citta non indicata') + '</span>' +
    '</div>'
  );
  dealerMarkers[dealer.id] = marker;
  routeBounds.push([lat, lng]);
});

activeRentalCars.forEach(v => {
  if (!hasValidDealerPosition(v)) {
    return;
  }
  routeBounds.push([Number(v.dealerLat), Number(v.dealerLng)]);
});

if (routeBounds.length > 0) {
  map.fitBounds(routeBounds, {padding: [40, 40], maxZoom: 13});
}

function posizionaAuto(lat, lng, vehicle) {
  const marker = L.marker([lat, lng], {icon: carIcon, title: vehicle.name}).addTo(map);
  marker.bindPopup(
    '<div style="padding:0.5rem;">' +
      '<strong style="color:#D4AF37;">' + safeText(vehicle.brand) + ' ' + safeText(vehicle.name) + '</strong><br>' +
      '<span>Cliente: ' + safeText(vehicle.userName || 'N/D') + '</span><br>' +
      '<span>Concessionario: ' + safeText(vehicle.dealerName || 'N/D') + '</span><br>' +
      '<span>Citta: ' + safeText(vehicle.city || 'N/D') + '</span><br>' +
      '<span>Periodo: ' + safeText(vehicle.startDate || 'N/D') + ' - ' + safeText(vehicle.endDate || 'N/D') + '</span><br>' +
      '<span>Noleggio #' + safeText(vehicle.rentalId) + '</span>' +
    '</div>'
  );
  marker.vehicleId = vehicle.vehicleId;
  carMarkers.push(marker);
  markers[vehicle.vehicleId] = marker;
}

// Simula il movimento delle auto partendo dalla posizione del concessionario
function simulaMovimento() {
  function movimento() {
    if (carMarkers.length === 0) {
      // Posiziona tutte le auto alla posizione del concessionario di partenza
      activeRentalCars.forEach(function(vehicle) {
        if (!hasValidDealerPosition(vehicle)) {
          return;
        }
        posizionaAuto(Number(vehicle.dealerLat), Number(vehicle.dealerLng), vehicle);
      });
    } else {
      carMarkers.forEach(function(carMarker) {
        var nuovaLatitudine = carMarker.getLatLng().lat + (Math.random() - 0.5) * 0.005;
        var nuovaLongitudine = carMarker.getLatLng().lng + (Math.random() - 0.5) * 0.005;
        carMarker.setLatLng([nuovaLatitudine, nuovaLongitudine]);
      });
    }
    setTimeout(movimento, 2000); // ogni 2 secondi
  }
  movimento();
}
simulaMovimento();

function focusVehicle(id, lat, lng) {
  const marker = markers[id];
  if (marker) {
    map.flyTo(marker.getLatLng(), 13, {duration: 1});
    marker.openPopup();
    return;
  }

  if (lat && lng) {
    map.flyTo([lat, lng], 13, {duration: 1});
  }
}
</script>
</body>
</html>
