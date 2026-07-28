-- Migrazione per database AutoHUB gia' esistenti.
-- Aggiunge le coordinate geografiche ai concessionari nella tabella users.

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS latitude DECIMAL(10,7) NULL,
    ADD COLUMN IF NOT EXISTS longitude DECIMAL(10,7) NULL;
