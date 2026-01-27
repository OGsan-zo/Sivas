-- ============================================================================
-- PROJET SIVAS (ITU) - SCRIPT DE CRÉATION DE LA BASE DE DONNÉES
-- ============================================================================

-- Nettoyage et extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ----------------------------------------------------------------------------
-- 1. RÉFÉRENTIELS ET PARAMÉTRAGES (Tables indépendantes)
-- ----------------------------------------------------------------------------

CREATE TABLE types_statut (
    id SERIAL PRIMARY KEY,
    code_statut VARCHAR(50) UNIQUE NOT NULL, 
    libelle VARCHAR(100) NOT NULL,
    module VARCHAR(50) NOT NULL -- 'ACHAT', 'VENTE', 'STOCK', 'GLOBAL'
);

CREATE TABLE types_tiers (
    id SERIAL PRIMARY KEY,
    code_type VARCHAR(20) UNIQUE NOT NULL, -- 'FOURNISSEUR', 'CLIENT'
    libelle VARCHAR(50) NOT NULL
);

CREATE TABLE methodes_valorisation (
    id SERIAL PRIMARY KEY,
    code_methode VARCHAR(10) UNIQUE NOT NULL, -- 'CUMP', 'FIFO'
    libelle VARCHAR(50) NOT NULL
);

CREATE TABLE types_mouvement (
    id SERIAL PRIMARY KEY,
    code_mouvement VARCHAR(50) UNIQUE NOT NULL, 
    libelle VARCHAR(100) NOT NULL,
    sens_flux INT CHECK (sens_flux IN (1, -1)) -- 1 Entrée, -1 Sortie
);

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(50) UNIQUE NOT NULL, -- 'Acheteur', 'Magasinier', 'DAF'
    montant_max_approbation DECIMAL(15,2) DEFAULT 0
);

-- ----------------------------------------------------------------------------
-- 2. STRUCTURE GÉOGRAPHIQUE ET ORGANISATIONNELLE
-- ----------------------------------------------------------------------------

CREATE TABLE entites_legales (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL
);

CREATE TABLE sites (
    id SERIAL PRIMARY KEY,
    entite_id INT REFERENCES entites_legales(id),
    nom VARCHAR(100) NOT NULL
);

CREATE TABLE depots (
    id SERIAL PRIMARY KEY,
    site_id INT REFERENCES sites(id),
    nom VARCHAR(100) NOT NULL
);

CREATE TABLE emplacements (
    id SERIAL PRIMARY KEY,
    depot_id INT REFERENCES depots(id),
    code_emplacement VARCHAR(50) NOT NULL,
    est_actif BOOLEAN DEFAULT TRUE
);

-- ----------------------------------------------------------------------------
-- 3. UTILISATEURS ET TIERS
-- ----------------------------------------------------------------------------

CREATE TABLE utilisateurs (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role_id INT REFERENCES roles(id),
    site_id INT REFERENCES sites(id),
    depot_id INT REFERENCES depots(id),
    actif BOOLEAN DEFAULT TRUE
);

CREATE TABLE tiers (
    id SERIAL PRIMARY KEY,
    type_tiers_id INT REFERENCES types_tiers(id),
    nom VARCHAR(255) NOT NULL,
    est_actif BOOLEAN DEFAULT TRUE
);

-- ----------------------------------------------------------------------------
-- 4. ARTICLES ET CATALOGUE
-- ----------------------------------------------------------------------------

CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    code_sku VARCHAR(50) UNIQUE NOT NULL,
    designation VARCHAR(255) NOT NULL,
    unite_mesure VARCHAR(20),
    methode_valorisation_id INT REFERENCES methodes_valorisation(id),
    est_perissable BOOLEAN DEFAULT FALSE, -- Déclenche règle FEFO
    seuil_alerte_stock DECIMAL(15,3) DEFAULT 0,
    plafond_remise_max DECIMAL(5,2) DEFAULT 0
);

-- ----------------------------------------------------------------------------
-- 5. FLUX ACHATS
-- ----------------------------------------------------------------------------

CREATE TABLE demandes_achat (
    id SERIAL PRIMARY KEY,
    demandeur_id INT REFERENCES utilisateurs(id),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statut_id INT DEFAULT 1 REFERENCES types_statut(id),
    montant_estime DECIMAL(15,2)
);

CREATE TABLE bons_commande_achat (
    id SERIAL PRIMARY KEY,
    da_id INT REFERENCES demandes_achat(id),
    fournisseur_id INT REFERENCES tiers(id),
    acheteur_id INT REFERENCES utilisateurs(id),
    approbateur_id INT REFERENCES utilisateurs(id),
    date_commande TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statut_id INT DEFAULT 1 REFERENCES types_statut(id),
    montant_total_ht DECIMAL(15,2),
    -- REGLE : Séparation des tâches
    CONSTRAINT chk_separation_taches_achat CHECK (acheteur_id <> approbateur_id)
);

CREATE TABLE lignes_bc_achat (
    id SERIAL PRIMARY KEY,
    bc_id INT REFERENCES bons_commande_achat(id) ON DELETE CASCADE,
    article_id INT REFERENCES articles(id),
    quantite_commandee DECIMAL(15,3) NOT NULL,
    quantite_reçue DECIMAL(15,3) DEFAULT 0, -- Suivi réceptions partielles
    prix_unitaire_ht DECIMAL(15,2) NOT NULL,
    tva_taux DECIMAL(5,2) DEFAULT 20.00
);

-- ----------------------------------------------------------------------------
-- 6. GESTION DES STOCKS ET MOUVEMENTS
-- ----------------------------------------------------------------------------

CREATE TABLE stocks_lots (
    id SERIAL PRIMARY KEY,
    article_id INT REFERENCES articles(id),
    depot_id INT REFERENCES depots(id),
    emplacement_id INT REFERENCES emplacements(id),
    numero_lot VARCHAR(50) NOT NULL,
    date_peremption DATE, -- Utilisé pour règle FEFO
    quantite_reelle DECIMAL(15,3) DEFAULT 0,
    quantite_reservee DECIMAL(15,3) DEFAULT 0,
    cout_unitaire_valorisation DECIMAL(15,2)
);

CREATE TABLE mouvements_stock (
    id SERIAL PRIMARY KEY,
    type_mouvement_id INT REFERENCES types_mouvement(id),
    article_id INT REFERENCES articles(id),
    lot_id INT REFERENCES stocks_lots(id),
    quantite DECIMAL(15,3) NOT NULL,
    utilisateur_id INT REFERENCES utilisateurs(id),
    date_mouvement TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 7. GESTION DES INVENTAIRES
-- ----------------------------------------------------------------------------

CREATE TABLE sessions_inventaire (
    id SERIAL PRIMARY KEY,
    depot_id INT REFERENCES depots(id),
    date_inventaire TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responsable_id INT REFERENCES utilisateurs(id),
    statut_id INT DEFAULT 1 REFERENCES types_statut(id)
);

CREATE TABLE lignes_inventaire (
    id SERIAL PRIMARY KEY,
    session_id INT REFERENCES sessions_inventaire(id) ON DELETE CASCADE,
    lot_id INT REFERENCES stocks_lots(id),
    quantite_theorique DECIMAL(15,3),
    quantite_physique DECIMAL(15,3),
    -- Calcul automatique de l'écart
    ecart DECIMAL(15,3) GENERATED ALWAYS AS (quantite_physique - quantite_theorique) STORED,
    justification TEXT -- Obligatoire si écart significatif
);

-- ----------------------------------------------------------------------------
-- 8. TRAÇABILITÉ (AUDIT LOGS)
-- ----------------------------------------------------------------------------

CREATE TABLE logs_audit (
    id SERIAL PRIMARY KEY,
    table_nom VARCHAR(50),
    enregistrement_id INT,
    action VARCHAR(20), -- 'INSERT', 'UPDATE', 'DELETE'
    utilisateur_id INT,
    donnees_anciennes JSONB,
    donnees_nouvelles JSONB,
    date_action TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 9. INITIALISATION DES DONNÉES DE BASE
-- ----------------------------------------------------------------------------

INSERT INTO types_tiers (code_type, libelle) VALUES 
('FOURNISSEUR', 'Fournisseur'), ('CLIENT', 'Client');

INSERT INTO methodes_valorisation (code_methode, libelle) VALUES 
('CUMP', 'Coût Moyen Pondéré'), ('FIFO', 'Premier Entré, Premier Sorti');

INSERT INTO types_statut (code_statut, libelle, module) VALUES 
('BROUILLON', 'Brouillon', 'GLOBAL'),
('EN_ATTENTE_V1', 'En attente Validation N1', 'ACHAT'),
('APPROUVE', 'Approuvé', 'GLOBAL'),
('EN_COURS', 'En cours', 'STOCK'),
('VALIDE', 'Validé', 'STOCK');

INSERT INTO types_mouvement (code_mouvement, libelle, sens_flux) VALUES 
('REC_FOURN', 'Réception Fournisseur', 1),
('LIV_CLIENT', 'Livraison Client', -1),
('AJUST_POS', 'Ajustement Inventaire (+)', 1),
('AJUST_NEG', 'Ajustement Inventaire (-)', -1);