# AutoHUB – Design Document
## Tecnologie Software per il Web – A.A. 2025/2026
### Prof. Simone Romano – Università degli Studi di Salerno

---


## 1. Obiettivo del progetto

AutoHUB è una web application Java per il settore automotive premium. Integra in un unico ambiente la vendita di veicoli e prodotti automotive, il noleggio di supercar e la gestione dell'inventario da parte di amministratori e concessionari.

Il progetto si rivolge a clienti interessati ad auto sportive e di lusso, ricambi performance, accessori e noleggi a breve termine. L'applicazione è realizzata come progetto Maven WAR con Java 21, Jakarta Servlet/JSP, JSTL, MySQL e un datasource JNDI (`java:comp/env/jdbc/autohub`).

Gli obiettivi funzionali sono:

- consentire la consultazione pubblica del catalogo di vendita e dei veicoli a noleggio;
- permettere agli utenti registrati di acquistare prodotti, prenotare noleggi e consultare i propri ordini e noleggi;
- consentire ai concessionari di gestire autonomamente i veicoli di cui sono proprietari;
- fornire all'amministratore una visione complessiva di prodotti, ordini, noleggi e posizioni dei veicoli attivi.

## 2. Analisi dei competitor

### AutoScout24

[AutoScout24](https://www.autoscout24.it) è focalizzato sulla ricerca e sulla compravendita di veicoli nuovi e usati. Offre filtri avanzati e un ampio inventario, ma non propone un flusso di e-commerce per ricambi né il noleggio integrato nella stessa esperienza.

### Autodoc

[Autodoc](https://www.auto-doc.it) è un e-commerce specializzato in ricambi e accessori. Il suo punto di forza è la profondità del catalogo tecnico; AutoHUB si differenzia perché associa vendita di veicoli, accessori e noleggio con un'interfaccia orientata al segmento premium.

### Turo

[Turo](https://turo.com) propone il noleggio di veicoli tramite una piattaforma digitale. AutoHUB ne riprende il concetto di prenotazione, ma lo combina con un catalogo di vendita e con la gestione da parte dei concessionari. Il pannello amministrativo include inoltre una mappa dei noleggi attivi.

### Posizionamento di AutoHUB

AutoHUB si posiziona come hub automotive premium: unisce acquisto, noleggio e gestione dell'offerta dei concessionari, privilegiando supercar e veicoli di fascia alta. L'esperienza è completata da schede ricche di specifiche, gallerie di immagini e da un'interfaccia scura con accenti oro.

## 3. Funzionalità del sito

### Visitatore

- Visualizza home, catalogo prodotti, dettaglio prodotto, catalogo noleggi e dettaglio del veicolo a noleggio.
- Filtra il catalogo prodotti per ricerca, categoria, prezzo e ordinamento; filtra i noleggi per città.
- Gestisce un carrello mantenuto in sessione (aggiunta, modifica quantità, rimozione e svuotamento).
- Può registrarsi o accedere.

### Cliente registrato

- Completa il checkout con dati di spedizione e metodo di pagamento; l'ordine memorizza gli articoli, il prezzo storico e il totale.
- Consulta storico e dettaglio dei propri ordini.
- Prenota un veicolo scegliendo date, città/indirizzo di ritiro e note; il totale è calcolato sui giorni di noleggio.
- Consulta storico e dettaglio dei propri noleggi.

### Concessionario

- Accede all'area concessionario attraverso il normale login con ruolo `dealer` o `concessionario`.
- Aggiorna indirizzo e coordinate della propria sede; l'applicazione prova a geocodificare l'indirizzo tramite Nominatim/OpenStreetMap.
- Gestisce soltanto i propri veicoli in vendita e a noleggio: inserimento, modifica ed eliminazione.
- Carica da tre a cinque immagini per veicolo, salvate sotto `/images/products/` e registrate anche come lista JSON.

### Amministratore

- Accede al pannello separato `/admin`.
- Consulta dashboard, prodotti e ordini; può creare, modificare e cancellare logicamente i prodotti.
- Consulta la pagina dei noleggi con veicoli, noleggi attivi e concessionari su una mappa Leaflet/CARTO; la posizione delle auto attive è simulata lato client.
- Può eliminare veicoli a noleggio e aggiornare le coordinate di un veicolo.

## 4. Layout

Il sito pubblico usa una navbar sticky orizzontale con i collegamenti Home, Acquista, Noleggi, Carrello e area utente. Le pagine sono responsive e basate su Bootstrap: griglie di card per catalogo e noleggi, sidebar filtri nel catalogo, form per checkout e prenotazione, e galleria con specifiche per il dettaglio prodotto.

```
+-----------------------------------------------------------+
| Navbar: Home | Acquista | Noleggi | Carrello | Account   |
+-----------------------------------------------------------+
| Hero / video promozionale                                 |
+-----------------------------------------------------------+
| Sezioni editoriali e card in griglia                      |
| [prodotto o veicolo] [prodotto o veicolo] [...]           |
+-----------------------------------------------------------+
| Footer                                                     |
+-----------------------------------------------------------+
```

Il catalogo di vendita combina una sidebar per ricerca, categoria, fascia di prezzo e ordinamento con una griglia di prodotti. Il catalogo noleggi presenta card con città, concessionario, tariffa giornaliera e call to action per la prenotazione.

Le aree amministratore e concessionario adottano una sidebar fissa a sinistra, topbar e contenuto principale. L'area admin mostra tabelle, statistiche e la mappa dei noleggi; l'area concessionario offre dashboard e form per i due inventari.

```
+----------------+------------------------------------------+
| Sidebar        | Topbar                                   |
| - Dashboard    +------------------------------------------+
| - Inventario   | Tabelle, form, statistiche oppure mappa  |
| - Noleggi      |                                          |
| - Logout       |                                          |
+----------------+------------------------------------------+
```

## 5. Tema

Il tema è un "luxury automotive dark": superfici scure, contrasti netti e dettagli oro richiamano gli interni e le finiture di una supercar. Le immagini dei veicoli, il video promozionale in homepage e le gallerie dei dettagli mantengono l'attenzione sul prodotto.

La tipografia usa Playfair Display per brand e titoli, per dare un carattere editoriale e premium, e Montserrat per testi, navigazione e controlli. Bootstrap 5 fornisce la base responsive; Bootstrap Icons identifica azioni e sezioni; Leaflet con tile CARTO dark è impiegato per la mappa amministrativa.

## 6. Palette dei colori

| Ruolo | Colore | Valore | Uso principale |
|---|---|---:|---|
| Sfondo principale | Obsidian Black | `#0A0A0A` | Corpo del sito |
| Sfondo pannelli | Charcoal | `#1A1A1A` | Card, form e pannelli |
| Sfondo secondario | Dark Grey | `#2A2A2A` | Stati e componenti secondari |
| Accento | Gold | `#D4AF37` | CTA, titoli, prezzi e marker |
| Accento hover | Gold Light | `#F0C040` | Hover e risalto |
| Accento secondario | Copper | `#B87333` | Stato in attesa |
| Testo principale | White | `#FFFFFF` | Titoli e contenuti importanti |
| Testo attenuato | Muted Grey | `#888888` | Metadati e descrizioni |
| Successo | Green | `#5CB85C` | Disponibilità e stati positivi |
| Errore | Coral Red | `#FF6B6B` | Errori e azioni distruttive |
| Bordo | Gold alpha | `rgba(212,175,55,0.20)` | Separazione di card e pannelli |

## 7. Diagramma navigazionale

```
                                  [HOME]
                         /          |          \
                 [ACQUISTA]     [NOLEGGI]    [LOGIN / REGISTRAZIONE]
                     |              |                 |
            [DETTAGLIO PRODOTTO] [DETTAGLIO]       [AREA UTENTE]
                     |              |              /          \
                [CARRELLO]     [PRENOTAZIONE] [ORDINI]    [I MIEI NOLEGGI]
                     |              |             |              |
                 [CHECKOUT] [CONFERMA NOLEGGIO] [DETTAGLIO] [DETTAGLIO]
                     |
             [CONFERMA ORDINE]

        [AREA CONCESSIONARIO]                 [PANNELLO ADMIN]
          /        |        \                 /      |       \
 [Dashboard] [Vendita] [Noleggio]       [Dashboard][Prodotti][Ordini]
              |           |                           |
         [Nuovo/Modifica] [Nuovo/Modifica]       [Mappa noleggi]
```

Le pagine checkout, ordini, dettaglio ordine, prenotazione, conferma e storico noleggi richiedono autenticazione cliente. L'area concessionario verifica il ruolo applicativo all'ingresso di ogni servlet. Tutte le rotte `/admin/*`, ad eccezione della gestione del login effettuata dal filtro, sono riservate alla sessione amministrativa.

## 8. Diagramma navigazionale con le Servlet

```
Rotta / metodo                         Servlet                              Vista / risultato
GET  /home                             HomeServlet                          home.jsp
GET  /catalog                          CatalogServlet                       catalog.jsp
GET  /product?id=                      ProductDetailServlet                 product-detail.jsp
GET|POST /cart                         CartServlet                          cart.jsp / JSON per azioni AJAX
GET|POST /register                     RegisterServlet                      register.jsp / redirect login
GET|POST /login                        LoginServlet                         login.jsp / redirect per ruolo
POST /logout                           LogoutServlet                        redirect home
GET|POST /checkout              [U]   CheckoutServlet                      checkout.jsp / conferma ordine
GET  /order-confirmation        [U]   OrderConfirmationServlet             order-confirmation.jsp
GET  /orders                    [U]   OrderHistoryServlet                  order-history.jsp
GET  /order-detail?id=          [U]   OrderDetailServlet                   order-detail.jsp

GET  /rentals                          RentalsServlet                       rentals.jsp
GET  /rental-detail?id=                RentalVehicleDetailServlet           rental-detail.jsp
GET|POST /rental-booking        [U]   RentalBookingServlet                 rental-booking.jsp / conferma
GET  /rental-confirmation       [U]   RentalConfirmationServlet            rental-confirmation.jsp
GET  /my-rentals                [U]   RentalHistoryServlet                 rental-history.jsp

GET|POST /dealer/dashboard      [D]   DealerDashboardServlet               dealer/dashboard.jsp
GET|POST /dealer/sale-vehicles  [D]   DealerProductServlet                 elenco o vehicle-form.jsp
GET|POST /dealer/rental-vehicles[D]   DealerRentalVehicleServlet           elenco o vehicle-form.jsp

GET|POST /admin/login                 AdminLoginServlet                    admin/login.jsp / dashboard
GET  /admin/dashboard           [A]   AdminDashboardServlet                admin/dashboard.jsp
GET|POST /admin/products        [A]   AdminProductServlet                  elenco, dettaglio o form prodotto
GET  /admin/orders              [A]   AdminOrdersServlet                   admin/orders.jsp
GET|POST /admin/rentals         [A]   AdminRentalsServlet                  admin/rentals-map.jsp
POST /admin/rentals/update-location[A] UpdateVehicleLocationServlet         redirect noleggi admin
GET|POST /admin/logout          [A]   AdminLogoutServlet                   redirect login admin
```

Legenda: `[U]` protetta da `AuthFilter`; `[A]` protetta da `AdminAuthFilter`; `[D]` controllata dalla verifica del ruolo concessionario nelle servlet. `CharacterEncodingFilter` applica UTF-8 a tutte le richieste. Le azioni del carrello sono `add`, `update`, `remove` e `clear`.

## 9. Schema ER della base di dati

```
  USERS                                      PRODUCTS
+--------------------------+                +---------------------------+
| PK id                    |  1          N  | PK id                     |
| username, email          |<---------------| dealer_id (logico)         |
| password_hash, role      |                | nome, categoria, prezzo   |
| sede e coordinate        |                | stock, immagini, specs    |
+------------+-------------+                | is_deleted                |
             | 1                            +-------------+-------------+
             | N                                          | 0..1
          ORDERS                                        ORDER_ITEMS
+---------------------------+                 +--------------------------+
| PK id                     | 1             N | PK id                    |
| FK user_id                |---------------->| FK order_id              |
| spedizione, pagamento     |                 | FK product_id, nullable  |
| stato, totale, created_at |                 | nome/prezzo storico, q.tà|
+---------------------------+                 +--------------------------+

  USERS                                    RENTAL_VEHICLES
+--------------------------+               +---------------------------+
| PK id                    | 1         N   | PK id                     |
| cliente / concessionario |<--------------| dealer_id (logico)         |
+------------+-------------+               | dati, prezzo/giorno        |
             | 1                           | città, coordinate, stato  |
             | N                           +-------------+-------------+
          RENTALS                                        | 1
+---------------------------+                            | N
| PK id                     |----------------------------+
| FK user_id                |       FK vehicle_id
| date, luogo ritiro        |
| giorni, totale, stato     |
| note, created_at          |
+---------------------------+
```

Entità e relazioni principali:

- `users` contiene clienti, concessionari e amministratori; il ruolo distingue `customer`, `dealer`/`concessionario` e `admin`. Per le sedi sono disponibili indirizzo, città, CAP, nazione, latitudine e longitudine.
- `products` contiene prodotti e veicoli in vendita, comprese specifiche tecniche, più immagini (`image_url` e `image_urls`) e il proprietario `dealer_id`. La cancellazione è logica tramite `is_deleted`.
- `orders` appartiene a un utente; `order_items` associa gli articoli ordinati e conserva nome e prezzo al momento dell'acquisto. `product_id` è nullable con `ON DELETE SET NULL`.
- `rental_vehicles` contiene i veicoli disponibili per il noleggio, il concessionario proprietario, località e coordinate correnti.
- `rentals` collega cliente e veicolo, con periodo, dati di ritiro, importo e stato della prenotazione.

Le chiavi esterne effettivamente dichiarate nello script iniziale sono quelle di `orders`, `order_items` e `rentals`. I campi `dealer_id`, introdotti anche dalle migrazioni per database esistenti, sono gestiti dall'applicazione come riferimenti logici a `users.id`.

Il database usa MySQL 8+, InnoDB e charset `utf8mb4`.

## 10. Repository GitHub

Il codice sorgente è disponibile nel repository GitHub configurato per il progetto:

[https://github.com/Mvmbo/projectAUTOHUB](https://github.com/Mvmbo/projectAUTOHUB)

La struttura segue il modello Maven: sorgenti Java in `src/main/java`, JSP e risorse web in `src/main/webapp`, script SQL in `sql/` e build WAR tramite `pom.xml`.
