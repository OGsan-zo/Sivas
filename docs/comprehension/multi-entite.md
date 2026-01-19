Dans le contexte de votre projet et du cahier des charges fourni, le terme **"multi-entité"** (ou multi-entités légales) signifie que l'application doit être capable de gérer **plusieurs sociétés juridiques distinctes** au sein d'un même système.

Voici concrètement ce que cela implique pour votre développement :

* 
**Séparation juridique :** Chaque entité possède son propre nom, son identification fiscale et ses propres obligations comptables. Dans votre base de données, cela correspond à la table `entites_legales` que vous avez créée.


* 
**Hiérarchie organisationnelle :** Une entité légale peut posséder plusieurs **sites**, et chaque site peut avoir plusieurs **dépôts**. Votre structure de base de données reflète bien cet emboîtement : `Entité > Site > Dépôt`.


* 
**Consolidation des données :** Bien que les sociétés soient distinctes, le système doit permettre à la Direction Générale ou au DAF d'avoir une **vue consolidée** (globale) des indicateurs de performance (KPI), comme la valeur totale du stock pour l'ensemble du groupe.


* **Gestion des accès (ABAC) :** Le concept multi-entité est lié au contrôle d'accès. Un utilisateur peut être restreint à voir uniquement les données d'une entité spécifique, ou avoir des droits transverses s'il travaille au niveau du siège.


* 
**Indépendance des flux :** Chaque entité peut avoir ses propres fournisseurs, clients et tarifs, même si certains référentiels d'articles peuvent être partagés au niveau du groupe.



C'est une fonctionnalité essentielle pour une **"Grande entreprise"** (comme mentionné en page 1) qui possède souvent plusieurs filiales ou bureaux dans différents pays ou régions.