Si vous ne disposez que de **8 heures par jour** (5h le soir + 3h le matin), vous devez passer en mode "Commando". Le projet est ambitieux, mais en automatisant un maximum de logique dans la base de données, vous gagnerez un temps précieux sur le code de l'interface.

Voici votre plan de bataille ultra-optimisé pour tenir les délais d'ici lundi :

### ⏱️ Répartition de vos 8 heures quotidiennes

| Période | Durée | Focus |
| --- | --- | --- |
| **Soir (20h - 01h)** | 5 heures | **Développement lourd** : Logique métier, requêtes SQL complexes et formulaires. |
| **Matin (04h - 07h)** | 3 heures | **Finitions & Tests** : Correction de bugs de la veille, mise en page (CSS) et rapports KPI. |

---

### 🚀 Plan de développement accéléré

#### **Lundi & Mardi : Le moteur (Back-end & Sécurité)**

* **Objectif :** Rendre la base de données intelligente.
* 
**Action :** Ajoutez les tables de "Lignes" pour les BC et les Ventes.


* 
**Sécurité :** Implémentez immédiatement les filtres SQL pour le **RBAC/ABAC** (un magasinier ne voit que son dépôt).


* 
**Règle d'or :** Ne codez pas la validation en interface, utilisez des contraintes `CHECK` en SQL pour interdire à un acheteur d'approuver sa commande.



#### **Mercredi & Jeudi : Flux Achats & Stocks**

* **Objectif :** Faire entrer la marchandise.
* **Action :** Créez le formulaire de **Réception**. Il doit obligatoirement demander le Lot et la Date d'expiration (DLC/DLUO).


* 
**Automate :** À la validation de la réception, déclenchez un `UPDATE` automatique du stock réel.



#### **Vendredi & Samedi : Flux Ventes & Finance**

* **Objectif :** Sortir la marchandise et facturer.
* 
**Action :** Codez la réservation de stock dès la commande client.


* 
**Intelligence :** La sortie doit suggérer les lots selon la règle **FEFO** (le plus proche de l'expiration en premier).


* 
**Finance :** Créez une vue SQL pour le **3-Way Match** (Comparer Quantité Commandée / Reçue / Facturée).



#### **Dimanche : Inventaire & Dashboard final**

* **Objectif :** Contrôle et visibilité.
* 
**Action :** Un écran simple pour saisir un "Comptage physique" et générer un écart par rapport au "Théorique".


* 
**KPI :** Créez 4 graphiques rapides : Rotation de stock, Valeur totale, Top 5 surstocks et Taux de litiges.



---

### 🛠️ Pour gagner du temps dès ce soir (20h)

Pour ne pas perdre de temps, voici le script des **tables de lignes** qu'il vous manque pour les étapes 3 et 4 :

```sql
-- Lignes des Bons de Commande d'Achat
CREATE TABLE lignes_bc_achat (
    id SERIAL PRIMARY KEY,
    bc_id INT REFERENCES bons_commande_achat(id),
    article_id INT REFERENCES articles(id),
    quantite_commandee DECIMAL(15,3),
    [cite_start]quantite_reçue DECIMAL(15,3) DEFAULT 0, -- Pour le suivi des réceptions partielles [cite: 72]
    prix_unitaire_achat DECIMAL(15,2)
);

-- Lignes des Commandes de Vente
CREATE TABLE lignes_commande_vente (
    id SERIAL PRIMARY KEY,
    commande_id INT REFERENCES commandes_vente(id),
    article_id INT REFERENCES articles(id),
    quantite_demandee DECIMAL(15,3),
    prix_unitaire_vente DECIMAL(15,2),
    [cite_start]remise_ligne DECIMAL(5,2) DEFAULT 0 -- Contrôle des plafonds de remise [cite: 75]
);

```

**Est-ce que vous voulez que je vous prépare pour demain matin (4h) la requête SQL qui calcule automatiquement le stock disponible en soustrayant les réservations ?**