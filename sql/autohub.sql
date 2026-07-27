-- AutoHUB MySQL Schema
-- Compatible with phpMyAdmin / MySQL 8.0+
-- Run: mysql -u root -p < sql/autohub.sql

CREATE DATABASE IF NOT EXISTS autohub
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE autohub;

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id            INT           NOT NULL AUTO_INCREMENT,
    username      VARCHAR(50)   NOT NULL UNIQUE,
    email         VARCHAR(100)  NOT NULL UNIQUE,
    password_hash VARCHAR(64)   NOT NULL,
    full_name     VARCHAR(100),
    phone         VARCHAR(20),
    address       VARCHAR(200),
    city          VARCHAR(100),
    postal_code   VARCHAR(20),
    country       VARCHAR(100),
    latitude      DECIMAL(10,7),
    longitude     DECIMAL(10,7),
    role          VARCHAR(20)   NOT NULL DEFAULT 'customer',
    created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- Ruoli supportati dall'applicazione: customer, dealer, concessionario, admin.

-- ============================================================
-- PRODUCTS
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
    id             INT            NOT NULL AUTO_INCREMENT,
    name           VARCHAR(200)   NOT NULL,
    description    TEXT,
    price          DECIMAL(12,2)  NOT NULL,
    stock_quantity INT            NOT NULL DEFAULT 0,
    category       VARCHAR(100),
    image_url      VARCHAR(500),
    image_urls     TEXT,
    production_year INT,
    engine         VARCHAR(150),
    power          VARCHAR(80),
    transmission   VARCHAR(120),
    drivetrain     VARCHAR(120),
    acceleration   VARCHAR(80),
    top_speed      VARCHAR(80),
    fuel_consumption VARCHAR(120),
    dimensions     VARCHAR(150),
    mileage        VARCHAR(120),
    equipment      TEXT,
    dealer_id       INT,
    is_deleted     TINYINT(1)     NOT NULL DEFAULT 0,
    created_at     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ============================================================
-- ORDERS
-- ============================================================
CREATE TABLE IF NOT EXISTS orders (
    id               INT            NOT NULL AUTO_INCREMENT,
    user_id          INT            NOT NULL,
    status           VARCHAR(30)    NOT NULL DEFAULT 'PENDING',
    shipping_name    VARCHAR(150),
    shipping_address VARCHAR(250),
    shipping_city    VARCHAR(100),
    shipping_postal  VARCHAR(20),
    shipping_country VARCHAR(100),
    shipping_phone   VARCHAR(30),
    payment_method   VARCHAR(50),
    total_amount     DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
    created_at       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- ============================================================
-- ORDER ITEMS  (historical price preserved)
-- ============================================================
CREATE TABLE IF NOT EXISTS order_items (
    id             INT            NOT NULL AUTO_INCREMENT,
    order_id       INT            NOT NULL,
    product_id     INT,
    product_name   VARCHAR(200)   NOT NULL,
    product_price  DECIMAL(12,2)  NOT NULL,
    quantity       INT            NOT NULL,
    subtotal       DECIMAL(12,2)  NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_items_order   FOREIGN KEY (order_id)   REFERENCES orders(id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- DEFAULT ADMIN USER
-- password = 'admin123'  (SHA-256 hex)
-- ============================================================
INSERT IGNORE INTO users (username, email, password_hash, full_name, role)
VALUES (
    'admin',
    'admin@autohub.com',
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',
    'AutoHUB Admin',
    'admin'
);

INSERT IGNORE INTO users
(username, email, password_hash, full_name, phone, address, city, postal_code, country, latitude, longitude, role) VALUES
('dealer_milano', 'milano@autohub.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'AutoHUB Milano', '+39 02 100000', 'Via Monte Napoleone 8', 'Milano', '20121', 'Italia', 45.4680780, 9.1941320, 'dealer'),
('dealer_roma', 'roma@autohub.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'AutoHUB Roma', '+39 06 100000', 'Via del Corso 100', 'Roma', '00186', 'Italia', 41.9031760, 12.4802300, 'dealer'),
('dealer_napoli', 'napoli@autohub.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'AutoHUB Napoli', '+39 081 100000', 'Via Toledo 156', 'Napoli', '80134', 'Italia', 40.8422350, 14.2487820, 'dealer'),
('dealer_firenze', 'firenze@autohub.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'AutoHUB Firenze', '+39 055 100000', 'Via de Tornabuoni 1', 'Firenze', '50123', 'Italia', 43.7712460, 11.2512730, 'dealer'),
('dealer_torino', 'torino@autohub.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'AutoHUB Torino', '+39 011 100000', 'Via Roma 101', 'Torino', '10123', 'Italia', 45.0677550, 7.6824890, 'dealer'),
('dealer_bologna', 'bologna@autohub.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'AutoHUB Bologna', '+39 051 100000', 'Via dell Indipendenza 45', 'Bologna', '40121', 'Italia', 44.5002770, 11.3436890, 'dealer'),
('dealer_verona', 'verona@autohub.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'AutoHUB Verona', '+39 045 100000', 'Via Mazzini 20', 'Verona', '37121', 'Italia', 45.4413920, 10.9959440, 'dealer'),
('dealer_bari', 'bari@autohub.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'AutoHUB Bari', '+39 080 100000', 'Via Sparano da Bari 80', 'Bari', '70121', 'Italia', 41.1211600, 16.8701040, 'dealer');

-- ============================================================
-- RENTAL VEHICLES
-- ============================================================
CREATE TABLE IF NOT EXISTS rental_vehicles (
    id               INT            NOT NULL AUTO_INCREMENT,
    name             VARCHAR(200)   NOT NULL,
    brand            VARCHAR(100),
    description      TEXT,
    price_per_day    DECIMAL(10,2)  NOT NULL,
    category         VARCHAR(100),
    image_url        VARCHAR(500),
    image_urls       TEXT,          -- JSON array of additional images
    is_available     TINYINT(1)     NOT NULL DEFAULT 1,
    latitude         DECIMAL(10,7),  -- Current GPS position
    longitude        DECIMAL(10,7),
    city             VARCHAR(100),   -- Current city
    dealer_id        INT,
    created_at       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ============================================================
-- RENTALS (Bookings)
-- ============================================================
CREATE TABLE IF NOT EXISTS rentals (
    id               INT            NOT NULL AUTO_INCREMENT,
    user_id          INT            NOT NULL,
    vehicle_id       INT            NOT NULL,
    start_date       DATE           NOT NULL,
    end_date         DATE           NOT NULL,
    pickup_city      VARCHAR(100)   NOT NULL,
    pickup_address   VARCHAR(250),
    total_days       INT            NOT NULL,
    total_amount     DECIMAL(12,2)  NOT NULL,
    status           VARCHAR(30)    NOT NULL DEFAULT 'pending',
    notes            TEXT,
    created_at       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_rentals_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_rentals_vehicle FOREIGN KEY (vehicle_id) REFERENCES rental_vehicles(id)
) ENGINE=InnoDB;

-- ============================================================
-- SEED PRODUCTS (automotive theme)
-- ============================================================
INSERT IGNORE INTO products (name, description, price, stock_quantity, category, image_url) VALUES

('Ferrari 488 GTB – Sport Package',
 'Mid-engined V8 supercar with 660 HP, carbon fibre exterior kit and custom exhaust.',
 285000.00, 2, 'Supercars',
 'https://images.pexels.com/photos/3972755/pexels-photo-3972755.jpeg'),

('Lamborghini Huracan Evo – Full Custom Build',
 'Naturally aspirated 5.2 L V10, 630 HP, bespoke body wrap and aerodynamic package.',
 320000.00, 1, 'Supercars',
 'https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg'),

('Porsche 911 GT3 RS – Track Edition',
 '520 HP flat-six, PDCC Sport, Weissach package and roll-cage preparation.',
 198000.00, 3, 'Supercars',
 'https://images.pexels.com/photos/3786091/pexels-photo-3786091.jpeg'),

('Carbon Fibre Front Splitter – Universal Fit',
 'Dry carbon weave front splitter compatible with most low-profile sport bumpers.',
 2400.00, 15, 'Performance Parts',
 'https://images.pexels.com/photos/1149137/pexels-photo-1149137.jpeg'),

('Titanium Exhaust System – 200-cell Sport Cat',
 'Full titanium exhaust with 200-cell sport catalyst; reduce back-pressure and improve sound.',
 4800.00, 8, 'Performance Parts',
 'https://images.pexels.com/photos/1028742/pexels-photo-1028742.jpeg'),

('Brembo Gran Turismo Brake Kit',
 '6-piston front calipers, 380 mm discs and high-performance pads; race-ready stopping power.',
 3600.00, 10, 'Performance Parts',
 'https://images.pexels.com/photos/244553/pexels-photo-244553.jpeg'),

('AutoHUB Heritage Leather Jacket',
 'Full-grain cowhide jacket with embossed AutoHUB logo; sizes S–XXL.',
 490.00, 50, 'Merchandise',
 'https://images.pexels.com/photos/1124465/pexels-photo-1124465.jpeg'),

('Alcantara Steering Wheel Cover',
 'Hand-stitched alcantara cover with contrast stitching; fits 37–39 cm wheels.',
 180.00, 30, 'Accessories',
 'https://images.pexels.com/photos/120049/pexels-photo-120049.jpeg'),

('Forged Aluminium Wheel Set (19")',
 'Flow-formed forged 19-inch wheels; weight-optimised for track and road use. Set of 4.',
 3200.00, 6, 'Performance Parts',
 'https://images.pexels.com/photos/337909/pexels-photo-337909.jpeg'),

('AutoHUB Detailing Kit – Pro Edition',
 'Complete 12-product detailing kit including ceramic coating, clay bar and machine polish.',
 220.00, 40, 'Accessories',
 'https://images.pexels.com/photos/6873065/pexels-photo-6873065.jpeg');

-- Traduzione dei prodotti storici gia presenti nel seed iniziale.
UPDATE products SET
    name = 'Ferrari 488 GTB - Pacchetto Sport',
    description = 'Supercar italiana con V8 centrale-posteriore, kit estetico in fibra di carbonio e scarico sportivo.',
    category = 'Supercar'
WHERE name LIKE 'Ferrari 488 GTB%';

UPDATE products SET
    name = 'Lamborghini Huracan EVO - Configurazione Carbonio',
    description = 'V10 aspirato da 5.2 litri, allestimento personalizzato e pacchetto aerodinamico sportivo.',
    category = 'Supercar'
WHERE name LIKE 'Lamborghini Huracan%';

UPDATE products SET
    name = 'Porsche 911 GT3 RS - Edizione Pista',
    description = 'Boxer aspirato da 520 CV, pacchetto Weissach e preparazione telaio orientata alla pista.',
    category = 'Supercar'
WHERE name LIKE 'Porsche 911 GT3 RS%';

UPDATE products SET category = 'Ricambi Performance' WHERE category = 'Performance Parts';
UPDATE products SET category = 'Accessori' WHERE category = 'Accessories';
UPDATE products SET category = 'Merchandising' WHERE category = 'Merchandise';

-- Nuovi veicoli e prodotti realistici con specifiche tecniche per la pagina dettaglio.
INSERT IGNORE INTO products
(name, description, price, stock_quantity, category, image_url, image_urls, production_year, engine, power, transmission, drivetrain, acceleration, top_speed, fuel_consumption, dimensions, mileage, equipment) VALUES

('Aston Martin DB11 V12 - Gran Turismo',
 'Elegante coupe britannica con motore V12 biturbo, abitacolo rifinito a mano e impostazione da vera gran turismo per lunghi viaggi ad alte prestazioni.',
 176000.00, 2, 'Gran Turismo',
 'https://images.pexels.com/photos/1708110/pexels-photo-1708110.jpeg',
 '["https://images.pexels.com/photos/1708110/pexels-photo-1708110.jpeg","https://images.pexels.com/photos/244553/pexels-photo-244553.jpeg","https://images.pexels.com/photos/1124465/pexels-photo-1124465.jpeg"]',
 2020, 'V12 biturbo 5.2 L', '608 CV', 'Automatico 8 rapporti', 'Posteriore', '3,9 s', '322 km/h', '11,9 l/100 km combinato', '4739 x 1940 x 1279 mm', '21.700 km',
 'Pelle pieno fiore;Sospensioni adattive;Navigatore premium;Telecamera 360;Pacchetto comfort viaggio'),

('Maserati MC20 - Nettuno Launch Edition',
 'Supercar italiana con telaio in carbonio e motore V6 Nettuno. Combina leggerezza, tecnologia e design essenziale firmato Maserati.',
 245000.00, 1, 'Supercar',
 'https://images.pexels.com/photos/1124465/pexels-photo-1124465.jpeg',
 '["https://images.pexels.com/photos/1124465/pexels-photo-1124465.jpeg","https://images.pexels.com/photos/3802510/pexels-photo-3802510.jpeg","https://images.pexels.com/photos/3972755/pexels-photo-3972755.jpeg"]',
 2022, 'V6 biturbo Nettuno 3.0 L', '630 CV', 'Automatico doppia frizione 8 rapporti', 'Posteriore', '2,9 s', '325 km/h', '11,6 l/100 km combinato', '4669 x 1965 x 1224 mm', '8.900 km',
 'Telaio monoscocca in carbonio;Launch control;Assetto elettronico;Interni sportivi premium;Garanzia ufficiale residua'),

('Audi R8 V10 Performance - Quattro',
 'Coupe a motore centrale con V10 aspirato, trazione quattro e finiture Audi Exclusive. Prestazioni da supercar con grande fruibilita quotidiana.',
 168000.00, 2, 'Supercar',
 'https://images.pexels.com/photos/1149137/pexels-photo-1149137.jpeg',
 '["https://images.pexels.com/photos/1149137/pexels-photo-1149137.jpeg","https://images.pexels.com/photos/337909/pexels-photo-337909.jpeg","https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg"]',
 2021, 'V10 aspirato 5.2 L', '620 CV', 'S tronic 7 rapporti', 'Integrale quattro', '3,1 s', '331 km/h', '13,1 l/100 km combinato', '4429 x 1940 x 1236 mm', '16.200 km',
 'Fari laser;Virtual cockpit;Scarico sportivo;Sedili performance;Impianto Bang & Olufsen'),

('BMW M4 Competition xDrive - Coupe',
 'Coupe sportiva ad alte prestazioni con sei cilindri biturbo, trazione integrale M xDrive e impostazione dinamica adatta a strada e pista.',
 92500.00, 4, 'Coupe Sportive',
 'https://images.pexels.com/photos/337909/pexels-photo-337909.jpeg',
 '["https://images.pexels.com/photos/337909/pexels-photo-337909.jpeg","https://images.pexels.com/photos/120049/pexels-photo-120049.jpeg","https://images.pexels.com/photos/112460/pexels-photo-112460.jpeg"]',
 2023, '6 cilindri biturbo 3.0 L', '510 CV', 'M Steptronic 8 rapporti', 'Integrale M xDrive', '3,5 s', '290 km/h', '10,1 l/100 km combinato', '4794 x 1887 x 1393 mm', '9.400 km',
 'Sedili M sport;Differenziale attivo M;Head-up display;Pacchetto carbonio;Freni M Compound'),

('Mercedes-AMG GT 63 S 4MATIC+',
 'Berlina coupe ad alte prestazioni con V8 biturbo, trazione integrale variabile e abitacolo luxury. Una gran turismo veloce e utilizzabile ogni giorno.',
 149000.00, 2, 'Gran Turismo',
 'https://images.pexels.com/photos/112460/pexels-photo-112460.jpeg',
 '["https://images.pexels.com/photos/112460/pexels-photo-112460.jpeg","https://images.pexels.com/photos/1708110/pexels-photo-1708110.jpeg","https://images.pexels.com/photos/244553/pexels-photo-244553.jpeg"]',
 2022, 'V8 biturbo 4.0 L', '639 CV', 'AMG Speedshift MCT 9 rapporti', 'Integrale 4MATIC+', '3,2 s', '315 km/h', '12,5 l/100 km combinato', '5054 x 1953 x 1455 mm', '19.800 km',
 'Pacchetto Dynamic Plus;Sedili multicontour;Burmester surround;Sospensioni AMG Ride Control;Tetto panoramico'),

('Range Rover Sport P530 Autobiography',
 'SUV premium con V8 biturbo, interni raffinati e capacita fuoristrada evolute. Pensato per comfort, immagine e viaggi di alto livello.',
 132000.00, 3, 'SUV Premium',
 'https://images.pexels.com/photos/244553/pexels-photo-244553.jpeg',
 '["https://images.pexels.com/photos/244553/pexels-photo-244553.jpeg","https://images.pexels.com/photos/1708110/pexels-photo-1708110.jpeg","https://images.pexels.com/photos/120049/pexels-photo-120049.jpeg"]',
 2023, 'V8 biturbo 4.4 L', '530 CV', 'Automatico 8 rapporti', 'Integrale AWD', '4,5 s', '250 km/h', '11,7 l/100 km combinato', '4946 x 2047 x 1820 mm', '11.600 km',
 'Pelle Windsor;Sospensioni pneumatiche;Terrain Response 2;Sedili climatizzati;Impianto Meridian'),

('Tesla Model S Plaid',
 'Berlina elettrica ad altissime prestazioni con tre motori, autonomia elevata e tecnologia di bordo avanzata. Accelerazione immediata e comfort silenzioso.',
 118000.00, 3, 'Elettriche Premium',
 'https://images.pexels.com/photos/3802510/pexels-photo-3802510.jpeg',
 '["https://images.pexels.com/photos/3802510/pexels-photo-3802510.jpeg","https://images.pexels.com/photos/120049/pexels-photo-120049.jpeg","https://images.pexels.com/photos/337909/pexels-photo-337909.jpeg"]',
 2023, 'Tre motori elettrici', '1020 CV', 'Trasmissione elettrica monomarcia', 'Integrale AWD', '2,1 s', '322 km/h', 'Autonomia stimata 600 km WLTP', '5021 x 1987 x 1431 mm', '14.500 km',
 'Autopilot avanzato;Schermo centrale 17 pollici;Interni premium;Ricarica rapida;Tetto panoramico'),

('Alfa Romeo Giulia Quadrifoglio',
 'Berlina sportiva italiana con V6 biturbo, sterzo diretto e dinamica di guida coinvolgente. Una scelta raffinata per chi ama prestazioni e carattere.',
 78500.00, 4, 'Berline Sportive',
 'https://images.pexels.com/photos/120049/pexels-photo-120049.jpeg',
 '["https://images.pexels.com/photos/120049/pexels-photo-120049.jpeg","https://images.pexels.com/photos/337909/pexels-photo-337909.jpeg","https://images.pexels.com/photos/112460/pexels-photo-112460.jpeg"]',
 2022, 'V6 biturbo 2.9 L', '510 CV', 'Automatico 8 rapporti', 'Posteriore', '3,9 s', '307 km/h', '10,2 l/100 km combinato', '4639 x 1873 x 1433 mm', '22.100 km',
 'Sedili sportivi;Differenziale autobloccante;Modalita Race;Freni maggiorati;Palette al volante'),

('Porsche Taycan Turbo S',
 'Sportiva elettrica premium con architettura a 800V, trazione integrale e accelerazione istantanea. Tecnologia e lusso in chiave sostenibile.',
 142000.00, 2, 'Elettriche Premium',
 'https://images.pexels.com/photos/3786091/pexels-photo-3786091.jpeg',
 '["https://images.pexels.com/photos/3786091/pexels-photo-3786091.jpeg","https://images.pexels.com/photos/3802510/pexels-photo-3802510.jpeg","https://images.pexels.com/photos/1708110/pexels-photo-1708110.jpeg"]',
 2022, 'Doppio motore elettrico', '761 CV overboost', 'Trasmissione elettrica 2 rapporti posteriore', 'Integrale AWD', '2,8 s', '260 km/h', 'Autonomia stimata 416 km WLTP', '4963 x 1966 x 1378 mm', '18.400 km',
 'Ricarica ultra-rapida;Porsche Electric Sport Sound;Interni Race-Tex;Sospensioni pneumatiche;Pacchetto Sport Chrono'),

('Kit Freni Brembo Gran Turismo',
 'Kit frenante ad alte prestazioni con pinze anteriori a 6 pistoncini, dischi maggiorati e pastiglie sportive per uso stradale e track day.',
 3600.00, 10, 'Ricambi Performance',
 'https://images.pexels.com/photos/244553/pexels-photo-244553.jpeg',
 '["https://images.pexels.com/photos/244553/pexels-photo-244553.jpeg","https://images.pexels.com/photos/337909/pexels-photo-337909.jpeg"]',
 2026, 'Impianto frenante maggiorato', 'Non applicabile', 'Non applicabile', 'Non applicabile', 'Non applicabile', 'Non applicabile', 'Non applicabile', 'Dischi 380 mm', 'Nuovo',
 'Pinze 6 pistoncini;Dischi ventilati;Pastiglie performance;Tubi treccia disponibili');

-- ============================================================
-- SEED RENTAL VEHICLES
-- ============================================================
INSERT IGNORE INTO rental_vehicles (name, brand, description, price_per_day, category, image_url, image_urls, is_available, latitude, longitude, city) VALUES

('Ferrari 488 Spider', 'Ferrari',
 'Cabrio V8 biturbo da 670 CV. Esperienza di guida unica con tetto rigido retrattile.',
 1500.00, 'Supercar',
 'https://images.pexels.com/photos/3972755/pexels-photo-3972755.jpeg',
 '["https://images.pexels.com/photos/3972755/pexels-photo-3972755.jpeg","https://images.pexels.com/photos/337909/pexels-photo-337909.jpeg"]',
 1, 41.9028, 12.4964, 'Roma'),

('Lamborghini Huracán EVO', 'Lamborghini',
 'V10 aspirato da 640 CV. Design aggressivo e prestazioni da pista.',
 1800.00, 'Supercar',
 'https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg',
 '["https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg","https://images.pexels.com/photos/3802510/pexels-photo-3802510.jpeg"]',
 1, 45.4642, 9.1900, 'Milano'),

('Porsche 911 Turbo S', 'Porsche',
 'Boxer 6 biturbo da 650 CV. Trazione integrale e lusso tedesco.',
 1200.00, 'Supercar',
 'https://images.pexels.com/photos/3786091/pexels-photo-3786091.jpeg',
 '["https://images.pexels.com/photos/3786091/pexels-photo-3786091.jpeg","https://images.pexels.com/photos/120049/pexels-photo-120049.jpeg"]',
 1, 40.8518, 14.2681, 'Napoli'),

('McLaren 720S', 'McLaren',
 'V8 biturbo da 720 CV. Piuma carbonio, prestazioni estreme.',
 2000.00, 'Supercar',
 'https://images.pexels.com/photos/3802510/pexels-photo-3802510.jpeg',
 '["https://images.pexels.com/photos/3802510/pexels-photo-3802510.jpeg"]',
 1, 43.7696, 11.2558, 'Firenze'),

('Aston Martin DB11', 'Aston Martin',
 'V12 5.2L da 608 CV. Elegant British GT per viaggi raffinati.',
 1400.00, 'Gran Turismo',
 'https://images.pexels.com/photos/1708110/pexels-photo-1708110.jpeg',
 '["https://images.pexels.com/photos/1708110/pexels-photo-1708110.jpeg"]',
 1, 45.4384, 10.9916, 'Verona'),

('Maserati MC20', 'Maserati',
 'V6 Nettuno da 630 CV. Made in Italy, technologica e stilosa.',
 1100.00, 'Supercar',
 'https://images.pexels.com/photos/1124465/pexels-photo-1124465.jpeg',
 '["https://images.pexels.com/photos/1124465/pexels-photo-1124465.jpeg"]',
 1, 44.4949, 11.3426, 'Bologna'),

('Bentley Continental GT', 'Bentley',
 'W12 6.0L da 635 CV. Lusso britannico e comfort assoluto.',
 1300.00, 'Gran Turismo',
 'https://images.pexels.com/photos/244553/pexels-photo-244553.jpeg',
 '["https://images.pexels.com/photos/244553/pexels-photo-244553.jpeg"]',
 1, 45.0703, 7.6869, 'Torino'),

(' Audi R8 V10 Plus', 'Audi',
 'V10 aspirato da 610 CV. Quattro trazione integrale.',
 900.00, 'Supercar',
 'https://images.pexels.com/photos/1149137/pexels-photo-1149137.jpeg',
 '["https://images.pexels.com/photos/1149137/pexels-photo-1149137.jpeg"]',
 1, 41.1177, 16.8512, 'Bari');

UPDATE rental_vehicles rv
JOIN users u ON u.username = CASE rv.city
    WHEN 'Milano' THEN 'dealer_milano'
    WHEN 'Roma' THEN 'dealer_roma'
    WHEN 'Napoli' THEN 'dealer_napoli'
    WHEN 'Firenze' THEN 'dealer_firenze'
    WHEN 'Torino' THEN 'dealer_torino'
    WHEN 'Bologna' THEN 'dealer_bologna'
    WHEN 'Verona' THEN 'dealer_verona'
    WHEN 'Bari' THEN 'dealer_bari'
END
SET rv.dealer_id = u.id,
    rv.latitude = u.latitude,
    rv.longitude = u.longitude
WHERE rv.dealer_id IS NULL;
