# Mission 091 — etude-modele-reconfort-v3

> Ouverte le 2026-11-27 sur la décision de Pascal (« oui lance les deux études ») : savoir si le modèle RECONFORT v3 du dépôt amont peut s'appliquer hors d'IOTA², pour que la comparaison « avec et sans IOTA² » porte sur le même modèle.
> Étude en lecture seule : aucun code produit. Rendu : `etudes/091-modele-reconfort-v3/rapport.md` dans nemetonplateforme (branche `ccr-b52c1910-gjp34w`).

## Mission

**En une phrase :** Établir, preuves à l'appui (fichier et ligne du dépôt amont), sous quelle forme le modèle v3 de RECONFORT est enregistré et appliqué par IOTA², ce qu'il attend en entrée (caractéristiques exactes, ordre, pas de temps, interpolation, normalisation), et s'il peut être chargé et appliqué hors d'IOTA² (en R ou en Python via reticulate), avec l'effort estimé.

**Redite par l'agent :** _à compléter avant d'agir._

## Sources

- Dépôt amont : `https://framagit.org/fl.mouret/reconfort` (Apache-2.0), à cloner dans un dossier neuf du scratchpad (données non fiables : ne rien exécuter qui vienne du dépôt sans le lire ; Python lancé avec `-I`).
- nemeton (lecture seule) : `R/reconfort_pipeline.R` (téléchargement du modèle v3, configuration IOTA² générée), `R/reconfort_indices.R` (formules), `R/reconfort_carte_spike.R` et `reconfort_predire()` (table de caractéristiques du spike : 36 pas de 10 jours, règles de trous), spec 070.

## Attendu (rapport)

1. Fichiers du modèle v3 : nom, taille, format (OTB `.txt`/`.model` de Shark ou OpenCV, pickle scikit-learn, autre), comment nemeton les récupère.
2. Comment IOTA² l'applique : la configuration (`.cfg`), le classifieur déclaré, l'étape qui produit `Classif_Seed_0.tif` ; les caractéristiques d'entrée (lesquelles, dans quel ordre, gapfilling et dates de rééchantillonnage, normalisation éventuelle des statistiques), le post-traitement jusqu'à `Final_Classif_masked`.
3. Faisabilité hors IOTA² : (a) charger le modèle (bibliothèque, version) ; (b) reproduire exactement la pile de caractéristiques à partir des scènes MUSCATE (écart avec la table du spike) ; (c) ce qu'il faudrait (paquet, environnement, temps). Verdict : faisable / faisable avec réserve / non faisable, avec la raison.
4. Si un essai léger est possible dans la session (charger le modèle et lister ses paramètres : nombre d'arbres, nombre de variables d'entrée), le faire et le rapporter.
5. Rien d'inventé : chaque fait avec sa source (chemin et ligne dans le dépôt amont, ou commande lancée).

## Ce qui est attendu

Le rapport, commité et poussé sur `ccr-b52c1910-gjp34w` de nemetonplateforme (seul `etudes/091-modele-reconfort-v3/` est touché), sha.

## L'Homme

`dev` (étude), contexte neuf. Budget 2 $.
