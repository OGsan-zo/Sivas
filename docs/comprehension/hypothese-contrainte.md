Parfait, on est exactement dans la **lecture intelligente d’un cahier des charges**.
Les notions **d’hypothèses** et de **contraintes** sont souvent confondues, alors je vais être **très clair**, puis **100 % lié à ton SI (SIVAS)**.

---

# 1️⃣ Différence fondamentale (à comprendre avant tout)

### 👉 **Hypothèses**

Ce sont des **suppositions de départ** que l’on accepte comme vraies pour concevoir le système.

➡️ *“On part du principe que…”*

---

### 👉 **Contraintes**

Ce sont des **limites imposées** que le système **doit obligatoirement respecter**.

➡️ *“Le système doit…”*

---

## Phrase clé à mémoriser

> **Hypothèse = on suppose**
> **Contrainte = on est obligé**

---

# 2️⃣ Hypothèses SI (expliquées simplement)

Dans ton cahier des charges, les hypothèses définissent **le contexte dans lequel SIVAS fonctionne**.

---

## 🔹 Hypothèse 1 : Multi-sites / multi-dépôts possibles

### 🧠 Ce que ça veut dire

On suppose que l’entreprise :

* peut avoir plusieurs sites
* plusieurs entrepôts
* plusieurs dépôts de stockage

👉 Même si tu n’implémentes **qu’un seul dépôt**, le système doit être **prévu pour évoluer**.

---

### 📦 Exemple concret dans SIVAS

Dans la base de données :

* table `depot`
* table `stock` liée à `depot`

👉 À l’oral tu dis :

> *« Le système a été conçu avec une hypothèse multi-dépôts afin de garantir l’évolutivité. »*

---

## 🔹 Hypothèse 2 : Multi-entités légales

### 🧠 Ce que ça veut dire

L’entreprise peut avoir :

* plusieurs sociétés
* une maison mère
* des filiales

---

### 🧾 Exemple concret dans SIVAS

Même si tu n’as qu’une entité :

* tu prévois un champ `entite_id`
* chaque document (vente, achat) y est rattaché

👉 C’est une **hypothèse d’extension**, pas une obligation d’implémentation complète.

---

# 3️⃣ Contraintes SI (les règles non négociables)

Maintenant, les **contraintes**, c’est ce qui **t’impose des choix**.

---

## 🔹 Contrainte 1 : Volumétrie élevée

### 🧠 Ce que ça veut dire

Le système doit supporter :

* beaucoup d’articles
* beaucoup de mouvements de stock
* beaucoup d’utilisateurs

---

### 🔧 Impact sur ton SI

Tu dois :

* éviter les traitements inutiles
* utiliser des identifiants clairs
* prévoir une structure propre

👉 Même si ton projet est petit, la **conception** doit être sérieuse.

---

## 🔹 Contrainte 2 : Traçabilité obligatoire

### 🧠 Ce que ça veut dire

Chaque action doit être :

* tracée
* horodatée
* liée à un utilisateur

---

### 🧾 Exemple concret

Dans SIVAS :

* une entrée stock contient :

  * date
  * utilisateur
  * référence document

👉 Tu peux dire :

> *« La contrainte de traçabilité a guidé la conception des mouvements de stock. »*

---

## 🔹 Contrainte 3 : Séparation des tâches

### 🧠 Ce que ça veut dire

Une même personne ne doit pas :

* créer ET valider
* réceptionner ET contrôler

---

### 🔐 Exemple concret

Dans ton système :

* rôle **Magasinier** : réception
* rôle **Responsable** : validation

👉 Même si c’est simplifié, la règle est visible.

---

## 🔹 Contrainte 4 : Sécurité et habilitations

### 🧠 Ce que ça veut dire

Tout le monde ne peut pas tout faire.

---

### 👤 Exemple concret

* Commercial : créer commande
* Magasinier : sortir stock
* Admin : tout

👉 C’est une contrainte **organisationnelle**, pas technique.

---

# 4️⃣ Hypothèses vs Contraintes (tableau clair)

| Élément              | Hypothèse | Contrainte |
| -------------------- | --------- | ---------- |
| Multi-sites          | ✔️        | ❌          |
| Multi-entités        | ✔️        | ❌          |
| Volumétrie élevée    | ❌         | ✔️         |
| Traçabilité          | ❌         | ✔️         |
| Séparation des rôles | ❌         | ✔️         |
| Sécurité accès       | ❌         | ✔️         |

---

# 5️⃣ Comment l’expliquer à l’oral (phrase prête)

### Version complète (très pro)

> *« Les hypothèses SI définissent le contexte d’exploitation du système, notamment la possibilité de gérer plusieurs sites et entités. Les contraintes SI imposent quant à elles des règles strictes de traçabilité, de sécurité, de séparation des tâches et de gestion de volumétrie. »*

---

### Version simple

> *« Les hypothèses décrivent le contexte prévu, tandis que les contraintes imposent les règles que le système doit respecter. »*

---

# 6️⃣ Application directe à ton projet (important)

Tu peux dire sans problème :

> *« Dans le cadre de ce projet académique, certaines hypothèses ont été anticipées au niveau de la conception, tandis que les contraintes principales ont été implémentées de manière fonctionnelle. »*

👉 C’est une **phrase très intelligente**.

