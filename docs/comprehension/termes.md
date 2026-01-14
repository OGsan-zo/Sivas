Très bonne question — et tu fais exactement ce qu’un **bon concepteur de SI** doit faire : comprendre les **concepts métier**, pas seulement le code.

Je vais procéder **clairement et pédagogiquement** :

1. **Définition simple** (sans jargon inutile)
2. **Exemple concret lié à TON système d’information (SI achats / ventes / stock)**

---

# 1️⃣ KPI (Key Performance Indicator)

## 🔹 Définition

Un **KPI** est un **indicateur chiffré** qui permet de savoir si une activité fonctionne bien ou mal.

👉 C’est une **mesure** pour aider à décider.

---

## 🔹 Exemple concret dans ton SI

Dans ton application, tu as une page **Tableau de bord**.

Exemples de KPI :

* **Stock total** : 12 500 unités
* **Articles en rupture** : 3
* **Ventes du jour** : 15 commandes
* **Valeur du stock** : 8 000 000 Ar

👉 Le directeur ouvre l’application et **voit immédiatement la situation** sans entrer dans les détails.

---

# 2️⃣ FIFO (First In, First Out)

## 🔹 Définition

FIFO signifie :

> **Le premier article entré en stock est le premier qui sort**

On vend d’abord les produits **les plus anciens**.

---

## 🔹 Exemple concret dans ton SI

Réception de riz :

| Date  | Quantité | Prix      |
| ----- | -------- | --------- |
| 01/03 | 100 sacs | 40 000 Ar |
| 05/03 | 100 sacs | 45 000 Ar |

Un client commande **120 sacs**.

➡️ Le système :

* sort **100 sacs du lot du 01/03**
* * **20 sacs du lot du 05/03**

👉 Tu peux expliquer :

> *« Le système applique la méthode FIFO pour éviter de garder des stocks anciens. »*

---

# 3️⃣ FEFO (First Expired, First Out)

## 🔹 Définition

FEFO signifie :

> **Le produit qui expire le plus tôt sort en premier**

Utilisé pour :

* produits alimentaires
* médicaments
* produits périssables

---

## 🔹 Exemple concret dans ton SI

Stock de yaourts :

| Lot   | Date expiration |
| ----- | --------------- |
| Lot A | 10 avril        |
| Lot B | 25 avril        |

➡️ Même si Lot B est arrivé avant :

* le système force la sortie du **Lot A**

👉 Dans ton SI :

* un lot expiré est **bloqué automatiquement**

---

# 4️⃣ DLUO (Date Limite d’Utilisation Optimale)

## 🔹 Définition

DLUO = date après laquelle :

* le produit reste consommable
* mais peut perdre en qualité

👉 Ex : riz, biscuits, conserves

---

## 🔹 Exemple concret dans ton SI

Article : **Biscuits**

* DLUO : 30 juin

Dans ton système :

* après le 30 juin :

  * produit toujours vendable
  * mais marqué **“à écouler rapidement”**

👉 KPI possible :

* *Produits proches DLUO*

---

# 5️⃣ DLC (Date Limite de Consommation)

## 🔹 Définition

DLC = date **après laquelle la consommation est dangereuse**

👉 Ex : viande, lait frais

---

## 🔹 Exemple concret dans ton SI

Article : **Poulet frais**

* DLC : 12 avril

➡️ Le 13 avril :

* le système :

  * bloque la vente
  * interdit la sortie stock
  * exige un rebut (destruction)

---

# 6️⃣ CUMP (Coût Unitaire Moyen Pondéré)

## 🔹 Définition

CUMP = **prix moyen** du stock, recalculé à chaque entrée.

Formule simple :

```
CUMP = (valeur totale du stock) / (quantité totale)
```

---

## 🔹 Exemple concret dans ton SI

Entrées successives :

| Quantité | Prix      |
| -------- | --------- |
| 100      | 10 000 Ar |
| 50       | 14 000 Ar |

Calcul :

```
(100×10 000 + 50×14 000) / 150 = 11 333 Ar
```

👉 Toutes les sorties utilisent **11 333 Ar** comme coût.

---

# 7️⃣ Supply Chain

## 🔹 Définition

La **Supply Chain** est l’ensemble du parcours :

> Fournisseur → Stock → Client

Elle inclut :

* achats
* stockage
* transport
* vente

---

## 🔹 Exemple concret dans ton SI

Dans ton application :

1. Création fournisseur
2. Commande achat
3. Réception stock
4. Stock disponible
5. Vente client
6. Livraison
7. Facture

👉 Tu peux dire :

> *« L’application couvre la chaîne logistique de bout en bout. »*

---

# 🧠 RÉSUMÉ EXPRESS (à mémoriser)

| Terme        | Idée clé                         |
| ------------ | -------------------------------- |
| KPI          | Indicateur pour décider          |
| FIFO         | Premier entré = premier sorti    |
| FEFO         | Expire d’abord = sort d’abord    |
| DLUO         | Qualité ↓ après date             |
| DLC          | Interdit après date              |
| CUMP         | Prix moyen du stock              |
| Supply Chain | Flux global fournisseur → client |

