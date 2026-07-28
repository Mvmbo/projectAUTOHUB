-- Migrazione per database AutoHUB gia' esistenti.
-- Eseguire solo se le colonne dealer_id non sono ancora presenti.

ALTER TABLE products
    ADD COLUMN IF NOT EXISTS dealer_id INT NULL;

ALTER TABLE rental_vehicles
    ADD COLUMN IF NOT EXISTS dealer_id INT NULL;
