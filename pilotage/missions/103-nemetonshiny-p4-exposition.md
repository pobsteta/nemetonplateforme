# Mission 103 — nemetonshiny-p4-exposition

> Ouverte le 2026-11-28 sur la décision de Pascal (« A puis B d'affilée ») : on réalise la **partie A** du brief app de la spec 072, `nemeton/specs/072-p4-rendement-net-risque/brief-nemetonshiny.md`, sur `main` de nemeton.
> Le cœur nécessaire est **nemeton 2026.11.48**, dont la release est en cours (PR #718). Le code de P4 est identique sur `main` e036f3a.
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, partie d'`origin/main` ac4cfc02c (DESCRIPTION 2026.11.6.9029). Pas de release.

## Mission

**En une phrase :** exposer P4 dans l'application. Cela couvre :
- les champs `vocation` et `perte_saisie` par UGF, avec un format de données versionné et testé ;
- le calcul de P4 par le cœur quand ses sources sont présentes ;
- son affichage dans la famille P et dans la synthèse forêt ;
- le statut Pareto et le risque de ruine ;
- le drapeau « signal seulement » ;
- l'i18n FR/EN et les colonnes P4 dans l'export GeoPackage et le rapport Quarto.

C'est la partie A du brief, sans le plan d'actions.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

Suivre le brief, partie A (A1 à A3) et § 0. **Le cœur fait foi pour tous les calculs**, et l'app n'en fait aucun.

1. **Lire d'abord le code de l'app** et écrire une courte note d'alignement dans `pilotage/` de nemetonshiny, par exemple `pilotage/notes/103-alignement-p4.md`. Elle porte sur :
   - le format des données UG et sa version ;
   - le service qui appelle les indicateurs ;
   - l'affichage de la famille P ;
   - la synthèse ;
   - l'export.

   Le brief a été écrit sans lire l'app : ses noms de fichiers sont à vérifier.
2. **Champs UGF.**
   - `vocation` : liste fermée, avec les cinq vocations du fichier de paramètres du cœur (`nemeton::p4_parametres()`).
   - `perte_saisie` : proportion par an, facultative.
   - Toute évolution du format des données UG passe par une version de schéma lue et stricte, une migration, et un test d'aller-retour sauvegarde-chargement.
   - Un projet existant sans ces champs se charge à l'identique.
3. **Calcul.**
   - Appeler `nemeton::indicateur_p4_rendement_net()` et les fonctions forêt (`p4_synthese_foret()`, `p4_ruine_foret()`, `p4_pareto()`) depuis un service, jamais depuis un module.
   - Lui passer les `R*_norm` produits par `normalize_indicator()`, comme le fait déjà l'app (`service_project.R`). Sinon, l'erreur `nemeton_p4_norm_incoherent` est attendue.
   - Sans vocation, P4 est absent et rien ne change pour les projets existants.
4. **Affichage, selon le brief A2.**
   - **Détail de la famille P** :
     - rendement brut décomposé en rendement net et en pertes attendues ;
     - taux exigé ;
     - décision ;
     - aléa dominant ;
     - drapeau de précision.
   - **Synthèse forêt.**
   - **Statut Pareto** par UGF.
   - **Risque de ruine** par aléa :
     - perte de sinistre, en part du capital et en années de gain net ;
     - probabilité sur l'horizon ;
     - UGF concentrante ;
     - dépassement du plafond.
   - Le rendement géométrique s'affiche à côté du rendement net.
   - Quand le drapeau « signal seulement » est levé, ne montrer aucune décision de coupe.
   - Respecter la règle des couleurs de `CLAUDE.md` : ce contenu n'est pas de l'IA, donc pas d'ambre.
5. **i18n et export (A3).**
   - Clés FR et EN, en `\uXXXX`, de 30 caractères au plus, pour l'indicateur, les quatre décisions, les cinq vocations et les quatre aléas.
   - Colonnes P4 dans le GeoPackage et dans le rapport Quarto.
6. **Dépendance au cœur.** `Imports: nemeton (>= 2026.11.48)`. Pour les tests, le cœur du `main` est installé dans la bibliothèque fournie.

## Cas limites (tests)

1. **Projet existant sans vocation** : chargement identique, P4 absent, aucun avertissement nouveau, et `famille_production` affichée inchangée.
2. **Forêt de référence de la spec 072 § 10**, reconstruite en UGF de test avec vocations et scores `_norm` : l'app affiche les valeurs du cœur sans les recalculer (vérifier le service et les rendus).
3. **Aller-retour sauvegarde-chargement** avec `vocation` et `perte_saisie`.
4. **Vocation inconnue** : message lisible.
5. **Signal seulement** : pas de décision de coupe affichée.
6. **Contre-épreuve** sur `origin/main`.

## Hors périmètre

La partie B (plan d'actions piloté par P4, missions 104 et 105).

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 6 $.
