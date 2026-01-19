-- Extension pour la génération d'UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-------------------------------------------------------------------------------
-- 1. RÉFÉRENTIELS ET PARAMÉTRAGES (Tables Maîtresses)
-------------------------------------------------------------------------------

-- Gestion centralisée des statuts (DA, BC, Ventes, etc.)
CREATE TABLE types_statut (
    id SERIAL PRIMARY KEY,
    code_statut VARCHAR(50) UNIQUE NOT NULL, 
    libelle VARCHAR(100) NOT NULL,
    module VARCHAR(50) NOT NULL -- 'ACHAT', 'VENTE', 'STOCK', 'GLOBAL'
);

-- Gestion normalisée des types de tiers
CREATE TABLE types_tiers (
    id SERIAL PRIMARY KEY,
    code_type VARCHAR(20) UNIQUE NOT NULL, -- 'FOURNISSEUR', 'CLIENT', 'PROSPECT'
    libelle VARCHAR(50) NOT NULL
);

-- Gestion des méthodes de valorisation de stock
CREATE TABLE methodes_valorisation (
    id SERIAL PRIMARY KEY,
    code_methode VARCHAR(10) UNIQUE NOT NULL, -- 'CUMP', 'FIFO'
    libelle VARCHAR(50) NOT NULL
);

-- Gestion des types de mouvements de stock
CREATE TABLE types_mouvement (
    id SERIAL PRIMARY KEY,
    code_mouvement VARCHAR(50) UNIQUE NOT NULL, 
    libelle VARCHAR(100) NOT NULL,
    sens_flux INT CHECK (sens_flux IN (1, -1)) -- 1 pour Entrée, -1 pour Sortie
);

-------------------------------------------------------------------------------
-- 2. GOUVERNANCE ET ACCÈS (RBAC / ABAC)
-------------------------------------------------------------------------------

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(50) UNIQUE NOT NULL, -- Acheteur, Magasinier, Vendeur, DAF
    montant_max_approbation DECIMAL(15,2) DEFAULT 0 -- Seuils N1/N2/N3
);

CREATE TABLE entites_legales (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL -- Multi-entités
);

CREATE TABLE sites (
    id SERIAL PRIMARY KEY,
    entite_id INT REFERENCES entites_legales(id),
    nom VARCHAR(100) NOT NULL -- Multi-sites
);

CREATE TABLE depots (
    id SERIAL PRIMARY KEY,
    site_id INT REFERENCES sites(id),
    nom VARCHAR(100) NOT NULL -- Multi-dépôts
);

CREATE TABLE emplacements (
    id SERIAL PRIMARY KEY,
    depot_id INT REFERENCES depots(id),
    code_emplacement VARCHAR(50) NOT NULL, -- Zone de picking
    est_actif BOOLEAN DEFAULT TRUE
);

CREATE TABLE utilisateurs (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role_id INT REFERENCES roles(id),
    site_id INT REFERENCES sites(id), -- ABAC : Restriction par site
    depot_id INT REFERENCES depots(id), -- ABAC : Restriction par dépôt
    actif BOOLEAN DEFAULT TRUE
);

-------------------------------------------------------------------------------
-- 3. ARTICLES ET TIERS
-------------------------------------------------------------------------------

CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    code_sku VARCHAR(50) UNIQUE NOT NULL,
    designation VARCHAR(255) NOT NULL,
    unite_mesure VARCHAR(20),
    methode_valorisation_id INT REFERENCES methodes_valorisation(id), -- Optimisé
    est_perissable BOOLEAN DEFAULT FALSE, -- Si TRUE -> règle FEFO
    seuil_alerte_stock DECIMAL(15,3) DEFAULT 0,
    plafond_remise_max DECIMAL(5,2) DEFAULT 0 -- Contrôle commercial
);

CREATE TABLE tiers (
    id SERIAL PRIMARY KEY,
    type_tiers_id INT REFERENCES types_tiers(id), -- Optimisé
    nom VARCHAR(255) NOT NULL,
    est_actif BOOLEAN DEFAULT TRUE
);

-------------------------------------------------------------------------------
-- 4. FLUX ACHATS ET STOCKS
-------------------------------------------------------------------------------

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

CREATE TABLE stocks_lots (
    id SERIAL PRIMARY KEY,
    article_id INT REFERENCES articles(id),
    depot_id INT REFERENCES depots(id),
    emplacement_id INT REFERENCES emplacements(id),
    numero_lot VARCHAR(50) NOT NULL, -- Traçabilité lot obligatoire
    date_peremption DATE, -- Pour FEFO
    quantite_reelle DECIMAL(15,3) DEFAULT 0,
    quantite_reservee DECIMAL(15,3) DEFAULT 0, -- Réservation
    cout_unitaire_valorisation DECIMAL(15,2)
);

CREATE TABLE mouvements_stock (
    id SERIAL PRIMARY KEY,
    type_mouvement_id INT REFERENCES types_mouvement(id),
    article_id INT REFERENCES articles(id),
    lot_id INT REFERENCES stocks_lots(id),
    quantite DECIMAL(15,3) NOT NULL,
    utilisateur_id INT REFERENCES utilisateurs(id), -- Qui a fait quoi
    date_mouvement TIMESTAMP DEFAULT CURRENT_TIMESTAMP --
);

-------------------------------------------------------------------------------
-- 5. TRAÇABILITÉ (AUDIT)
-------------------------------------------------------------------------------

CREATE TABLE logs_audit (
    id SERIAL PRIMARY KEY,
    table_nom VARCHAR(50),
    enregistrement_id INT,
    action VARCHAR(20), -- INSERT, UPDATE, DELETE
    utilisateur_id INT,
    donnees_anciennes JSONB,
    donnees_nouvelles JSONB,
    date_action TIMESTAMP DEFAULT CURRENT_TIMESTAMP --
);

-------------------------------------------------------------------------------
-- INITIALISATION DES DONNÉES DE RÉFÉRENCE
-------------------------------------------------------------------------------

INSERT INTO types_tiers (code_type, libelle) VALUES 
('FOURNISSEUR', 'Fournisseur'), ('CLIENT', 'Client');

INSERT INTO methodes_valorisation (code_methode, libelle) VALUES 
('CUMP', 'Coût Moyen Pondéré'), ('FIFO', 'Premier Entré, Premier Sorti');

INSERT INTO types_statut (code_statut, libelle, module) VALUES 
('BROUILLON', 'Brouillon', 'GLOBAL'),
('EN_ATTENTE_V1', 'En attente Validation N1', 'ACHAT'),
('APPROUVE', 'Approuvé', 'GLOBAL');

INSERT INTO types_mouvement (code_mouvement, libelle, sens_flux) VALUES 
('REC_FOURN', 'Réception Fournisseur', 1),
('LIV_CLIENT', 'Livraison Client', -1);



-------------------------------------------------------------------------------
-- 4. FLUX ACHATS : DÉTAILS (Lignes de documents)
-------------------------------------------------------------------------------

-- Lignes des Bons de Commande d'Achat [cite: 23]
CREATE TABLE lignes_bc_achat (
    id SERIAL PRIMARY KEY,
    bc_id INT REFERENCES bons_commande_achat(id) ON DELETE CASCADE,
    article_id INT REFERENCES articles(id),
    quantite_commandee DECIMAL(15,3) NOT NULL,
    quantite_reçue DECIMAL(15,3) DEFAULT 0, -- Pour le suivi des réceptions partielles 
    prix_unitaire_ht DECIMAL(15,2) NOT NULL,
    tva_taux DECIMAL(5,2) DEFAULT 20.00
);

-------------------------------------------------------------------------------
-- 5. FLUX VENTES : DÉTAILS (Lignes de documents)
-------------------------------------------------------------------------------

-- Lignes des Commandes de Vente [cite: 25]
CREATE TABLE lignes_commande_vente (
    id SERIAL PRIMARY KEY,
    commande_id INT REFERENCES commandes_vente(id) ON DELETE CASCADE,
    article_id INT REFERENCES articles(id),
    quantite_demandee DECIMAL(15,3) NOT NULL,
    quantite_livree DECIMAL(15,3) DEFAULT 0,
    prix_unitaire_vente_ht DECIMAL(15,2) NOT NULL,
    remise_ligne_pourcent DECIMAL(5,2) DEFAULT 0, -- Soumis au plafond_remise_max de l'article 
    statut_ligne_id INT DEFAULT 1 REFERENCES types_statut(id)
);

-------------------------------------------------------------------------------
-- 6. GESTION DES INVENTAIRES (Ajustements contrôlés)
-------------------------------------------------------------------------------

-- Table pour planifier les inventaires (annuels ou tournants) [cite: 27]
CREATE TABLE sessions_inventaire (
    id SERIAL PRIMARY KEY,
    depot_id INT REFERENCES depots(id),
    date_inventaire TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responsable_id INT REFERENCES utilisateurs(id),
    statut_id INT DEFAULT 1 REFERENCES types_statut(id) -- BROUILLON, EN_COURS, VALIDE
);

-- Détails de l'inventaire (Écarts entre théorique et physique) [cite: 27, 108]
CREATE TABLE lignes_inventaire (
    id SERIAL PRIMARY KEY,
    session_id INT REFERENCES sessions_inventaire(id) ON DELETE CASCADE,
    lot_id INT REFERENCES stocks_lots(id),
    quantite_theorique DECIMAL(15,3), -- Ce que le système dit
    quantite_physique DECIMAL(15,3),  -- Ce que l'agent a compté
    ecart DECIMAL(15,3) GENERATED ALWAYS AS (quantite_physique - quantite_theorique) STORED,
    justification TEXT -- Obligatoire si écart important [cite: 62]
);