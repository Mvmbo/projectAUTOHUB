# AutoHUB – Website Design Document
## Tecnologie Software per il Web – A.A. 2025/2026
### Prof. Simone Romano – Università degli Studi di Salerno

---

## 1. Obiettivo del Progetto

**AutoHUB** è una piattaforma di e-commerce dedicata al settore automobilistico. L'obiettivo principale è offrire a privati e appassionati un unico ambiente digitale dove acquistare veicoli, componenti di performance e accessori per auto di lusso e sportive.

Il sistema centralizza servizi oggi frammentati su piattaforme diverse, eliminando la necessità di visitare più siti per trovare prodotti automobilistici. Il pubblico di riferimento comprende appassionati di auto sportive, collezionisti e professionisti del settore che cercano prodotti di qualità in un contesto visivamente premium.

**Obiettivi specifici:**
- Permettere la navigazione del catalogo a utenti non registrati
- Consentire ad utenti registrati di aggiungere prodotti al carrello, completare ordini con dati di spedizione e pagamento, e consultare lo storico ordini
- Fornire all'amministratore una pannello di gestione per il CRUD del catalogo e la visualizzazione degli ordini per data e per cliente

---

## 2. Analisi dei Competitor

### AutoScout24 (https://www.autoscout24.it)

Piattaforma specializzata nella compravendita di veicoli nuovi e usati. Consente ricerche tramite filtri avanzati (prezzo, chilometraggio, alimentazione, localit\u00e0) e mette in contatto acquirenti con venditori privati e concessionari.

**Punti di forza:** vasta gamma di veicoli, filtri avanzati, comparazione.
**Limitazioni rispetto ad AutoHUB:** non vende componenti o accessori; nessuna gestione del carrello integrata.

### Autodoc (https://www.auto-doc.it)

E-commerce specializzato nella vendita di ricambi e componenti per automobili. Compatibilit\u00e0 per modello di veicolo, schede tecniche dettagliate, prezzi competitivi.

**Punti di forza:** catalogo ricambi molto ampio, ricerca per targa/modello.
**Limitazioni rispetto ad AutoHUB:** solo ricambi, no veicoli completi; interfaccia poco premium.

### Turo (https://www.turo.com)

Piattaforma online per il noleggio di auto tra privati. Gli utenti prenotano veicoli per periodi variabili; i proprietari gestiscono disponibilit\u00e0 e prezzi.

**Punti di forza:** model\u00f f di sharing economy, flessibilit\u00e0 di prenotazione.
**Limitazioni rispetto ad AutoHUB:** solo noleggio, nessun acquisto di prodotti fisici.

**Posizionamento di AutoHUB:** AutoHUB si distingue combinando vendita di veicoli e componenti in un design visivamente lussuoso e un'esperienza d'acquisto completa (carrello, ordini, storico).

---

## 3. Funzionalit\u00e0 del Sito

Le funzionalit\u00e0 sono organizzate per tipo di utente:

### Utente Non Registrato
- Navigazione del catalogo prodotti (veicoli, componenti, accessori)
- Ricerca per categoria, parola chiave, fascia di prezzo
- Visualizzazione scheda prodotto dettagliata
- Aggiunta prodotti al carrello (il carrello \u00e8 mantenuto in sessione)
- Registrazione di un nuovo account

### Utente Registrato
- Tutte le funzionalit\u00e0 dell'utente non registrato
- Login e Logout
- Checkout con inserimento dati di spedizione e metodo di pagamento
- Conferma ordine e svuotamento automatico del carrello
- Visualizzazione storico ordini
- Visualizzazione dettaglio singolo ordine

### Amministratore
- Login e Logout separato (pannello `/admin`)
- Dashboard con statistiche (prodotti attivi, ordini odierni, utenti registrati)
- Creazione, visualizzazione, modifica e cancellazione (soft-delete) prodotti
- Visualizzazione elenco ordini con filtro per data (da/a) e per cliente
- Visualizzazione dettaglio ordine

---

## 4. Layout

Il layout adotta un design a **colonna intera** con navigazione orizzontale fissa in alto per le pagine cliente, e un layout **sidebar + contenuto principale** per il pannello admin.

**Pagine Cliente:**
```
+--------------------------------------------------+
|  NAVBAR: [AutoHUB] [Home] [Catalog] [Cart] [User]|
+--------------------------------------------------+
|                                                  |
|   HERO SECTION (full-width, immagine sfondo)     |
|                                                  |
+--------------------------------------------------+
|  FEATURED PRODUCTS GRID (3-4 colonne responsive) |
+--------------------------------------------------+
|  VALUES / ABOUT SECTION                          |
+--------------------------------------------------+
|  FOOTER                                          |
+--------------------------------------------------+
```

**Pagina Catalogo:**
```
+------------+-----------------------------------+
|  SIDEBAR   |   PRODUCT GRID                    |
|  Filters   |   (3 colonne su desktop,          |
|  - Search  |    2 su tablet, 1 su mobile)      |
|  - Category|                                   |
|  - Price   |   [Card] [Card] [Card]            |
|  - Sort    |   [Card] [Card] [Card]            |
+------------+-----------------------------------+
```

**Pannello Admin:**
```
+----------+---------------------------------------+
| SIDEBAR  |  MAIN CONTENT                         |
| [Nav]    |  [Topbar con titolo e azioni]         |
| Dashboard|  [Tabella / Form / Stats]             |
| Products |                                       |
| Orders   |                                       |
| Logout   |                                       |
+----------+---------------------------------------+
```

---

## 5. Tema

Il tema visivo di AutoHUB \u00e8 **lusso automobilistico scuro** – ispirato all'estetica delle case automobilistiche di lusso come Mansory e Legendary Motorcar.

**Metafora visiva:** L'interfaccia richiama l'interno di una supercar di notte – carbonio nero, finiture dorate, illuminazione soffusa. Ogni elemento grafico trasmette esclusivit\u00e0 e precisione tecnica.

**Caratteristiche del tema:**
- Sfondi quasi-neri (`#0A0A0A`, `#1A1A1A`) per massimizzare il contrasto
- Accenti oro (`#D4AF37`) per highlights, prezzi, pulsanti CTA
- Tipografia serif elegante (Playfair Display) per titoli
- Tipografia sans-serif moderna (Montserrat) per corpo e navigazione
- Bordi sottili con rgba gold per separatori e card
- Immagini di veicoli ad alta risoluzione da Pexels

---

## 6. Palette dei Colori

| Ruolo | Nome | Hex | Utilizzo |
|-------|------|-----|---------|
| Sfondo primario | Obsidian Black | `#0A0A0A` | Background body |
| Sfondo secondario | Charcoal | `#1A1A1A` | Card, pannelli, tabelle |
| Accento primario | Gold | `#D4AF37` | Titoli, bottoni, prezzi, highlights |
| Accento secondario | Bronze | `#B8941F` | Hover bottoni, bordi attivi |
| Testo primario | Pure White | `#FFFFFF` | Intestazioni, testo importante |
| Testo secondario | Silver | `#CCCCCC` | Corpo testo, descrizioni |
| Testo muted | Gray | `#888888` | Label, metadata |
| Successo | Emerald | `#5CB85C` | Stato "Active", indicatori positivi |
| Errore | Coral Red | `#FF6B6B` | Errori, "Out of Stock" |
| Bordo card | Gold-alpha | `rgba(212,175,55,0.15)` | Bordi sottili elementi |

**Tipografia:**
- Playfair Display: 400, 700 (titoli, brand)
- Montserrat: 300, 400, 600 (corpo, nav, bottoni)

---

## 7. Diagramma Navigazionale

```
                        [HOME]
                           |
          +----------------+----------------+
          |                |                |
       [CATALOG]        [CART]         [LOGIN/REGISTER]
          |                |                |
      [PRODUCT         [CHECKOUT]      [MY ORDERS]
       DETAIL]             |                |
          |          [ORDER CONFIRM]   [ORDER DETAIL]
          |
     [ADD TO CART]
     (AJAX, sessione)

                     [ADMIN LOGIN]
                           |
                    [ADMIN DASHBOARD]
                    /               \
           [PRODUCTS]            [ORDERS]
           /       \                |
     [NEW/EDIT]  [VIEW/DELETE]  [VIEW DETAIL]
```

**Legenda:**
- Pagine pubbliche (nessun login richiesto): Home, Catalog, Product Detail, Cart, Login, Register
- Pagine protette (login utente): Checkout, Order Confirmation, My Orders, Order Detail
- Pagine admin (login admin): Admin Dashboard, Products CRUD, Orders view

---

## 8. Diagramma Navigazionale con le Servlet

```
Browser                     Servlet                         JSP / JSON
-------                     -------                         ----------

GET /home              --> HomeServlet                --> home.jsp
GET /catalog           --> CatalogServlet             --> catalog.jsp
GET /product?id=X      --> ProductDetailServlet       --> product-detail.jsp
GET /cart              --> CartServlet (GET)           --> cart.jsp
POST /cart (AJAX)      --> CartServlet (POST)          --> JSON response
  action=add
  action=update
  action=remove
  action=clear
GET /register          --> RegisterServlet (GET)       --> register.jsp
POST /register         --> RegisterServlet (POST)      --> register.jsp (errori) |
                                                            redirect /login (ok)
GET /login             --> LoginServlet (GET)          --> login.jsp
POST /login            --> LoginServlet (POST)         --> login.jsp (errore) |
                                                            redirect /home (ok)
POST /logout           --> LogoutServlet               --> redirect /home
GET /checkout          --> CheckoutServlet (GET)  [*] --> checkout.jsp
POST /checkout         --> CheckoutServlet (POST) [*] --> redirect /order-confirmation
GET /order-confirmation--> OrderConfirmationServlet   --> order-confirmation.jsp
GET /orders            --> OrderHistoryServlet    [*] --> order-history.jsp
GET /order-detail?id=X --> OrderDetailServlet     [*] --> order-detail.jsp

GET /admin/login       --> AdminLoginServlet           --> admin/login.jsp
POST /admin/login      --> AdminLoginServlet           --> admin/login.jsp (err) |
                                                            redirect /admin/dashboard
GET /admin/dashboard   --> AdminDashboardServlet  [A] --> admin/dashboard.jsp
GET /admin/products    --> AdminProductServlet    [A] --> admin/products.jsp
GET /admin/products?action=new  --> AdminProductServlet --> admin/product-form.jsp
GET /admin/products?action=edit --> AdminProductServlet --> admin/product-form.jsp
GET /admin/products?action=view --> AdminProductServlet --> admin/product-detail.jsp
POST /admin/products   --> AdminProductServlet    [A] --> redirect /admin/products
  action=create | update | delete
GET /admin/orders      --> AdminOrdersServlet     [A] --> admin/orders.jsp
  ?fromDate=&toDate=&userId=
POST /admin/logout     --> AdminLogoutServlet          --> redirect /admin/login
```

**Legenda:**
- `[*]` Protetto da `AuthFilter` (richiede sessionUser in sessione)
- `[A]` Protetto da `AdminAuthFilter` (richiede sessionAdmin in sessione)

---

## 9. Schema ER della Base di Dati

```
+------------------+        +-------------------+
|      users       |        |     products      |
+------------------+        +-------------------+
| PK id            |        | PK id             |
|    username      |        |    name           |
|    email         |        |    description    |
|    password_hash |        |    price          |
|    full_name     |        |    stock_quantity |
|    phone         |        |    category       |
|    address       |        |    image_url      |
|    city          |        |    is_deleted     |
|    postal_code   |        |    created_at     |
|    country       |        |    updated_at     |
|    role          |        +-------------------+
|    created_at    |                  |
+------------------+                  | (nullable FK)
         |                            |
         | 1                          |
         |                            |
         | N                          |
+------------------+        +-------------------+
|      orders      |        |   order_items     |
+------------------+        +-------------------+
| PK id            |------->| PK id             |
| FK user_id       | 1   N  | FK order_id       |
|    status        |        | FK product_id (?) |
|    shipping_name |        |    product_name   |<-- stored at purchase time
|    shipping_addr |        |    product_price  |<-- stored at purchase time
|    shipping_city |        |    quantity       |
|    shipping_post |        |    subtotal       |
|    shipping_ctry |        +-------------------+
|    payment_method|
|    total_amount  |
|    created_at    |
+------------------+
```

**Note sulla struttura:**
- `order_items.product_name` e `order_items.product_price` preservano il nome e il prezzo al momento dell'acquisto, indipendentemente da eventuali modifiche successive al prodotto.
- `order_items.product_id` è nullable (FK con ON DELETE SET NULL): se un prodotto viene cancellato (soft-delete), rimane nella tabella `order_items` con `product_id = NULL`, preservando la history degli ordini.
- `products.is_deleted` implementa il soft-delete: i prodotti "cancellati" non appaiono nel catalogo ma restano referenziati negli ordini storici.

**Database:** MySQL 8.0+, charset `utf8mb4`, engine `InnoDB`.
**JNDI Name:** `java:comp/env/jdbc/autohub`

---

## 10. Repository GitHub

Il codice sorgente del progetto è disponibile nel seguente repository pubblico:

**URL:** [https://github.com/YOUR_USERNAME/autohub](https://github.com/YOUR_USERNAME/autohub)

> Sostituire `YOUR_USERNAME` con il proprio username GitHub prima della consegna.

**Istruzioni per il repository:**
- Il repository deve essere **pubblico**
- Effettuare commit a grana fine (un commit per ogni funzionalità o fix significativo)
- La struttura del repository deve rispettare la struttura Maven del progetto

---

## 11. Come Aggiungere GIF, Video e Immagini Multiple

Questa sezione descrive come implementare contenuti multimediali nel progetto AutoHUB.

### 11.1 Struttura delle Cartelle

Creare le seguenti cartelle sotto `src/main/webapp/`:

```
webapp/
├── images/
│   ├── products/         # Immagini prodotti
│   ├── hero/             # Immagini per hero section
│   └── icons/            # Icone personalizzate
├── videos/
│   ├── hero-cars.mp4     # Video di sfondo homepage
│   └── promo.mp4        # Video presentazione
└── gifs/
    └── animations/       # GIF animate
```

### 11.2 Implementare Video Background nell'Hero

Nella home page (`home.jsp`), il video di sfondo deve:
- Essere **mutato** (`muted`)
- Essere in **autoplay** (`autoplay`)
- Essere in **loop** (`loop`)
- Avere un **poster** come fallback

```html
<video class="hero-video" autoplay muted loop playsinline
       poster="https://images.pexels.com/photos/3802510/pexels-photo-3802510.jpeg">
  <source src="${pageContext.request.contextPath}/videos/hero-cars.mp4" type="video/mp4">
</video>
```

**CSS necessario:**
```css
.hero-video {
  position: absolute;
  top: 50%;
  left: 50%;
  min-width: 100%;
  min-height: 100%;
  transform: translate(-50%, -50%);
  object-fit: cover;
}
```

### 11.3 Aggiungere GIF Animate

Le GIF possono essere utilizzate per:
- Loader/Spinner animati
- Animazioni di feedback (es. conferma acquisto)
- Elementi decorativi

```html
<img src="${pageContext.request.contextPath}/gifs/loading.gif"
     alt="Caricamento in corso..." class="loading-gif">
```

### 11.4 Implementare Carousel di Immagini

Per il carousel dei prodotti, utilizzare Bootstrap come mostrato in `product-detail.jsp`:

```html
<div id="productCarousel" class="carousel slide" data-bs-ride="false">
  <div class="carousel-inner">
    <div class="carousel-item active">
      <img src="immagine1.jpg" alt="Vista 1">
    </div>
    <div class="carousel-item">
      <img src="immagine2.jpg" alt="Vista 2">
    </div>
  </div>
  <button class="carousel-control-prev" type="button"
          data-bs-target="#productCarousel" data-bs-slide="prev">
    <span class="carousel-control-prev-icon"></span>
  </button>
  <button class="carousel-control-next" type="button"
          data-bs-target="#productCarousel" data-bs-slide="next">
    <span class="carousel-control-next-icon"></span>
  </button>
</div>
```

### 11.5 Sezione Video Presentazione

Per aggiungere una sezione video (es. homepage):

```html
<div class="video-wrapper">
  <div class="video-placeholder" id="videoPlaceholder">
    <i class="bi bi-play-circle-fill"></i>
    <p>Clicca per guardare il video</p>
  </div>
  <iframe id="promoVideo" style="display:none;"
          src="" data-src="https://www.youtube.com/embed/VIDEO_ID?autoplay=1"
          frameborder="0" allowfullscreen>
  </iframe>
</div>
```

```javascript
document.getElementById('videoPlaceholder').addEventListener('click', function() {
  const iframe = document.getElementById('promoVideo');
  iframe.src = iframe.dataset.src;
  iframe.style.display = 'block';
  this.style.display = 'none';
});
```

### 11.6 Immagini Multiple per Prodotto

Per supportare immagini multiple, aggiungere una colonna `image_urls` nella tabella products (formato JSON):

```sql
ALTER TABLE products ADD COLUMN image_urls TEXT;

-- Esempio JSON:
-- ["img1.jpg", "img2.jpg", "img3.jpg"]
```

Nel JSP, iterare sull'array JSON per generare il carousel. La colonna `image_urls` è già presente nella tabella `rental_vehicles`.

### 11.7 Best Practices

1. **Formati video raccomandati:** MP4 (H.264), WebM
2. **Risoluzione massima:** 1920x1080 per hero video
3. **Peso massimo:** 10MB per video (ottimizzare per web)
4. **Immagini:** Formato JPEG per foto, PNG per grafiche con trasparenza
5. **Lazy loading:** Utilizzare `loading="lazy"` per immagini fuori viewport
6. **Fallback:** Sempre fornire un'immagine statica come `poster` per i video

### 11.8 Risorse Esterno Gratuite

- **Pexels:** https://www.pexels.com (foto e video gratuiti)
- **Unsplash:** https://www.unsplash.com (foto)
- **Coverr:** https://coverr.co (video gratuiti)

---

*Documento di Website Design – AutoHUB*
*Tecnologie Software per il Web, A.A. 2025/2026*
*Università degli Studi di Salerno*
