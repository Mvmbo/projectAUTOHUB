<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<c:set var="pageTitle" value="Catalogo – AutoHUB" scope="request"/>
<jsp:include page="header.jsp"/>

<!-- Page Header -->
<div class="page-header">
  <div class="container">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb mb-2">
        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home">Home</a></li>
        <li class="breadcrumb-item active">Catalogo</li>
      </ol>
    </nav>
    <h1>LA COLLEZIONE</h1>
    <p style="color:#888; letter-spacing:2px; font-size:0.75rem; text-transform:uppercase;">
      <c:choose>
        <c:when test="${not empty products}">${products.size()} veicoli e componenti</c:when>
        <c:otherwise>Nessun risultato</c:otherwise>
      </c:choose>
    </p>
  </div>
</div>

<div class="container mb-5">

  <c:if test="${not empty error}">
    <div class="alert-error-block mb-4">${error}</div>
  </c:if>

  <div class="row g-4">

    <!-- ===== Sidebar Filters ===== -->
    <div class="col-lg-3">
      <div class="catalog-sidebar">
        <form id="catalogFilterForm" action="${pageContext.request.contextPath}/catalog" method="get">

          <!-- Search -->
          <div class="filter-group">
            <span class="filter-heading"><i class="bi bi-search me-2"></i>Cerca</span>
            <input type="text" id="keywordInput" name="keyword" class="form-control"
                   placeholder="Cerca prodotti..." value="${not empty keyword ? keyword : ''}">
          </div>

          <!-- Category -->
          <div class="filter-group">
            <span class="filter-heading"><i class="bi bi-tag me-2"></i>Categoria</span>
            <div>
              <label class="d-flex align-items-center gap-2 mb-2" style="cursor:pointer;">
                <input type="radio" name="category" value="" class="filter-category-radio"
                       ${empty selectedCategory ? 'checked' : ''} style="accent-color:#D4AF37;">
                <span class="filter-label mb-0">Tutte le Categorie</span>
              </label>
              <c:forEach var="cat" items="${categories}">
                <label class="d-flex align-items-center gap-2 mb-2" style="cursor:pointer;">
                  <input type="radio" name="category" value="${cat}" class="filter-category-radio"
                         ${selectedCategory eq cat ? 'checked' : ''} style="accent-color:#D4AF37;">
                  <span class="filter-label mb-0">${cat}</span>
                </label>
              </c:forEach>
            </div>
          </div>

          <!-- Price Range -->
          <div class="filter-group">
            <span class="filter-heading"><i class="bi bi-currency-euro me-2"></i>Fascia di Prezzo</span>
            <div class="d-flex gap-2">
              <input type="number" name="minPrice" class="form-control" placeholder="Min"
                     value="${not empty minPrice ? minPrice : ''}" min="0" step="100">
              <input type="number" name="maxPrice" class="form-control" placeholder="Max"
                     value="${not empty maxPrice ? maxPrice : ''}" min="0" step="100">
            </div>
          </div>

          <!-- Sort By -->
          <div class="filter-group">
            <span class="filter-heading"><i class="bi bi-sort-down me-2"></i>Ordina Per</span>
            <select id="sortBy" name="sortBy" class="form-select">
              <option value=""     ${empty sortBy       ? 'selected' : ''}>Più Recenti</option>
              <option value="price_asc"  ${sortBy eq 'price_asc'  ? 'selected' : ''}>Prezzo: Dal Basso</option>
              <option value="price_desc" ${sortBy eq 'price_desc' ? 'selected' : ''}>Prezzo: Dall'Alto</option>
              <option value="name_asc"   ${sortBy eq 'name_asc'   ? 'selected' : ''}>Nome: A–Z</option>
            </select>
          </div>

          <button type="submit" class="btn-gold w-100">Applica Filtri</button>
          <a href="${pageContext.request.contextPath}/catalog" class="btn-dark-outline w-100 mt-2 text-center d-block">Resetta</a>

        </form>
      </div>
    </div>

    <!-- ===== Product Grid ===== -->
    <div class="col-lg-9">

      <!-- Active filters display -->
      <c:if test="${not empty selectedCategory or not empty keyword}">
        <div class="d-flex flex-wrap gap-2 mb-3 align-items-center">
          <span style="font-size:0.7rem; letter-spacing:2px; color:#666; text-transform:uppercase;">Filtri attivi:</span>
          <c:if test="${not empty selectedCategory}">
            <span class="badge-category">${selectedCategory} <a href="${pageContext.request.contextPath}/catalog" style="color:inherit; margin-left:4px;">&times;</a></span>
          </c:if>
          <c:if test="${not empty keyword}">
            <span class="badge-category">"${keyword}"</span>
          </c:if>
        </div>
      </c:if>

      <c:choose>
        <c:when test="${not empty products}">
          <div class="row g-4">
            <c:forEach var="p" items="${products}">
              <div class="col-lg-4 col-md-6">
                <div class="product-card h-100">
                  <div class="card-img-wrap">
                    <a href="${pageContext.request.contextPath}/product?id=${p.id}">
                      <c:choose>
                        <c:when test="${not empty p.imageUrl and fn:startsWith(p.imageUrl, '/images/products/')}">
                          <img src="${pageContext.request.contextPath}${p.imageUrl}" alt="${p.name}" loading="lazy">
                        </c:when>
                        <c:otherwise>
                          <div class="d-flex align-items-center justify-content-center" style="height:100%; min-height:220px; background:#111; color:#666; font-size:0.72rem; letter-spacing:2px; text-transform:uppercase;">
                            Nessuna immagine
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </a>
                  </div>
                  <div class="product-card-body">
                    <p class="product-category">${p.category}</p>
                    <c:if test="${not empty p.dealerName}">
                      <p style="color:#888; font-size:0.72rem; margin-bottom:0.35rem;">
                        <i class="bi bi-shop me-1"></i>${p.dealerName}
                      </p>
                    </c:if>
                    <h5 class="product-name">${p.name}</h5>
                    <p class="product-price">
                      <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                    </p>
                    <div class="d-flex gap-2">
                      <a href="${pageContext.request.contextPath}/product?id=${p.id}" class="btn-outline-gold" style="font-size:0.7rem; padding:9px 16px; flex:1; text-align:center;">Dettagli</a>
                      <button class="btn-add-to-cart btn-gold" style="font-size:0.7rem; padding:9px 14px;"
                              data-product-id="${p.id}" title="Aggiungi al Carrello">
                        <i class="bi bi-bag-plus"></i>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <div class="empty-state">
            <div class="empty-state-icon"><i class="bi bi-search"></i></div>
            <h3>Nessun prodotto trovato</h3>
            <p>Prova a modificare i filtri di ricerca o <a href="${pageContext.request.contextPath}/catalog">sfoglia tutti i prodotti</a>.</p>
          </div>
        </c:otherwise>
      </c:choose>

    </div>
  </div>
</div>

<jsp:include page="footer.jsp"/>
