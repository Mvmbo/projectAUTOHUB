<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<c:set var="pageTitle" value="AutoHUB – Il Tuo Marketplace Automobilistico" scope="request"/>
<jsp:include page="header.jsp"/>

<!-- ======== HERO WITH VIDEO BACKGROUND ======== -->
<section class="hero-section hero-video-container">
  <!-- Video Background (muted, autoplay, loop) -->
  <video class="hero-video" autoplay muted loop playsinline poster="${pageContext.request.contextPath}/images/static/LamboStaticHome.avif">
    <source src="${pageContext.request.contextPath}/videos/hero-cars.mp4" type="video/mp4">
    <!-- Fallback to image if video not available -->
  </video>
  <!-- Fallback background image -->
  <div class="hero-bg" style="background-image: url('${pageContext.request.contextPath}/images/static/LamboStaticHome.avif');"></div>
  <div class="hero-overlay"></div>
  <div class="hero-content">
    <p class="hero-eyebrow">Veicoli, Ricambi &amp; Accessori</p>
    <h1 class="hero-title">IL TUO HUB <span class="gold">AUTOMOTIVE</span></h1>
    <p class="hero-subtitle">Acquista Veicoli &bull; Ricambi Performanti &bull; Accessori Esclusivi</p>
    <div class="d-flex gap-3 justify-content-center flex-wrap">
      <a href="${pageContext.request.contextPath}/catalog" class="btn-gold">Esplora la Collezione</a>
      <a href="${pageContext.request.contextPath}/rentals" class="btn-outline-gold">Noleggia Auto</a>
    </div>
  </div>
  <!-- Scroll indicator -->
  <div class="scroll-indicator">
    <i class="bi bi-chevron-double-down"></i>
  </div>
</section>

<!-- ======== VIDEO PRESENTATION SECTION ======== -->
<section class="video-presentation-section">
  <div class="container">
    <div class="video-intro">
      <p class="section-subtitle">Esperienza AutoHUB</p>
      <h2 class="section-title">IL LUSSO AUTOMOTIVE IN MOVIMENTO</h2>
      <div class="section-divider"></div>
      <p class="video-lead">
        Una selezione esclusiva di vetture, ricambi premium e servizi su misura:
        AutoHUB nasce per chi cerca prestazioni, eleganza e affidabilita' in ogni dettaglio.
      </p>
    </div>

    <div class="video-showcase">
      <div class="video-frame">
        <iframe class="promo-video"
                src="https://www.youtube.com/embed/O8G1Sanw7Ls?autoplay=1&mute=1&loop=1&controls=0&showinfo=0&rel=0&iv_load_policy=3&playlist=O8G1Sanw7Ls"
                title="Presentazione AutoHUB"
                frameborder="0"
                allow="autoplay; encrypted-media; picture-in-picture"
                allowfullscreen>
        </iframe>
        <div class="video-luxury-overlay" aria-hidden="true">
          <span class="video-overlay-line"></span>
          <span class="video-overlay-label">AutoHUB Selection</span>
        </div>
      </div>
    </div>

    <p class="video-caption">
      Dalla ricerca del veicolo ideale alla scelta di componenti e accessori di alta gamma,
      accompagniamo ogni cliente con un'esperienza digitale raffinata, chiara e sicura.
    </p>
  </div>
</section>

<!-- ======== FEATURED PRODUCTS ======== -->
<section class="section" id="featured">
  <div class="container">
    <p class="section-subtitle">Selezione Curata</p>
    <h2 class="section-title">MODELLI IN EVIDENZA</h2>
    <div class="section-divider"></div>

    <div class="row g-4">
      <c:choose>
        <c:when test="${not empty featuredProducts}">
          <c:forEach var="p" items="${featuredProducts}">
            <div class="col-lg-3 col-md-6">
              <div class="product-card h-100">
                <div class="card-img-wrap">
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
                </div>
                <div class="product-card-body">
                  <p class="product-category">${p.category}</p>
                  <h5 class="product-name">${p.name}</h5>
                  <p class="product-price">
                    <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="€" maxFractionDigits="2"/>
                  </p>
                  <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/product?id=${p.id}" class="btn-outline-gold" style="font-size:0.7rem; padding:9px 20px; flex:1; text-align:center;">Vedi Dettagli</a>
                    <button class="btn-add-to-cart btn-gold" style="font-size:0.7rem; padding:9px 14px;" data-product-id="${p.id}" title="Aggiungi al Carrello">
                      <i class="bi bi-bag-plus"></i>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <div class="col-12 empty-state">
            <div class="empty-state-icon"><i class="bi bi-car-front"></i></div>
            <h3>Catalogo in caricamento</h3>
            <p>La nostra collezione esclusiva verrà caricata a breve.</p>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <div class="text-center mt-5">
      <a href="${pageContext.request.contextPath}/catalog" class="btn-outline-gold">Vedi Collezione Completa</a>
    </div>
  </div>
</section>

<!-- ======== ABOUT / VALUES ======== -->
<section class="section" id="about" style="background: linear-gradient(180deg, #0A0A0A 0%, #111 50%, #0A0A0A 100%);">
  <div class="container">
    <p class="section-subtitle">Il Vantaggio AutoHUB</p>
    <h2 class="section-title">PERCHÉ SCEGLIERE AUTOHUB</h2>
    <div class="section-divider"></div>

    <div class="row g-5 justify-content-center">

      <div class="col-lg-4 col-md-6 feature-box text-center">
        <div class="feature-icon-wrap"><i class="bi bi-gem"></i></div>
        <h4 class="feature-title">Vasta Selezione</h4>
        <p class="feature-text">Dalle supercar ai ricambi performanti e accessori, AutoHUB ti offre un catalogo curato di cui puoi fidarti.</p>
      </div>

      <div class="col-lg-4 col-md-6 feature-box text-center">
        <div class="feature-icon-wrap"><i class="bi bi-lightning-charge"></i></div>
        <h4 class="feature-title">Prestazioni Leggendarie</h4>
        <p class="feature-text">Da impianti di scarico in titanio a centraline ECU personalizzate, ogni componente è progettato per le massime prestazioni.</p>
      </div>

      <div class="col-lg-4 col-md-6 feature-box text-center">
        <div class="feature-icon-wrap"><i class="bi bi-shield-check"></i></div>
        <h4 class="feature-title">Acquisti Sicuri</h4>
        <p class="feature-text">Storico ordini completo, prezzi storici preservati e checkout trasparente per ogni transazione AutoHUB.</p>
      </div>

    </div>
  </div>
</section>

<!-- ======== RENTALS CTA ======== -->
<section class="rentals-cta-section">
  <div class="container">
    <div class="row align-items-center">
      <div class="col-lg-6">
        <p class="section-subtitle" style="text-align:left;">Nuovo Servizio</p>
        <h2 style="font-family:'Playfair Display',serif; color:#fff; font-size:2.5rem; letter-spacing:2px; margin-bottom:1rem;">
          NOLEGGIO <span style="color:#D4AF37;">AUTO DI LUSSO</span>
        </h2>
        <p style="color:#aaa; font-size:0.95rem; line-height:1.7; margin-bottom:1.5rem;">
          Scopri la nostra flotta di supercar disponibili a noleggio. Dal Ferrari 488 alla Lamborghini Huracan,
          vivi l'emozione di guidare i migliori veicoli sportivi italiani.
        </p>
        <a href="${pageContext.request.contextPath}/rentals" class="btn-gold">
          <i class="bi bi-car-front me-2"></i>Esplora Noleggi
        </a>
      </div>
      <div class="col-lg-6 text-center mt-4 mt-lg-0">
        <img src="${pageContext.request.contextPath}/images/static/FerrariLogoStaticHome.jpg"
             alt="Noleggio Auto di Lusso"
             class="img-fluid rounded"
             style="max-height:320px; object-fit:cover; border:1px solid rgba(212,175,55,0.18); box-shadow:0 20px 60px rgba(0,0,0,0.5);">
      </div>
    </div>
  </div>
</section>

<!-- ======== CTA BANNER ======== -->
<section style="padding: 5rem 0; background: linear-gradient(135deg, #0D0D0D, #1A1A1A); border-top: 1px solid rgba(212,175,55,0.1); border-bottom: 1px solid rgba(212,175,55,0.1);">
  <div class="container text-center">
    <h2 style="font-family:'Playfair Display',serif; color:#fff; font-size:2rem; letter-spacing:3px; margin-bottom:1rem;">
      Pronto a <span style="color:#D4AF37;">Iniziare il Tuo Progetto?</span>
    </h2>
    <p style="color:#888; letter-spacing:2px; text-transform:uppercase; font-size:0.8rem; margin-bottom:2rem;">
      Esplora il nostro catalogo o crea un account per salvare le tue configurazioni
    </p>
    <div class="d-flex gap-3 justify-content-center flex-wrap">
      <a href="${pageContext.request.contextPath}/catalog" class="btn-gold">Sfoglia Catalogo</a>
      <c:if test="${empty sessionScope.sessionUser}">
        <a href="${pageContext.request.contextPath}/register" class="btn-outline-gold">Crea Account</a>
      </c:if>
    </div>
  </div>
</section>

<jsp:include page="footer.jsp"/>
