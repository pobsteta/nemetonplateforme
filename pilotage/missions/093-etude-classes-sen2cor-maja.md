# Mission 093 — etude-classes-sen2cor-maja

> Ouverte le 2026-11-27 sur la décision de Pascal (« oui lance le test ») : suite des études 091 et 092. Question : nourrir le modèle RECONFORT v3 avec des réflectances Sen2Cor (cache FAST/FORDEAD, Planetary Computer) au lieu de MAJA (THEIA) change-t-il la classe des pixels, et de combien ?
> Étude : rendu dans `etudes/093-classes-sen2cor-maja/` de nemetonplateforme. Pas de code produit.

## Mission

**En une phrase :** Sur un échantillon de pixels forestiers de Couchey, appliquer le prédicteur prototype du modèle v3 (étude 091) à deux piles de 134 caractéristiques construites de la même façon, l'une à partir des scènes MAJA du run de Pascal, l'autre à partir des scènes Sen2Cor de Planetary Computer, et mesurer la part des pixels qui changent de classe (et l'écart des votes), en la comparant à l'écart déjà présent entre le prototype et IOTA².

**Redite par l'agent :** _à compléter avant d'agir._

## Données et outils (lecture seule)

- Run de Couchey : `/tmp/claude-0/-home-user/4ded9d2a-b1a5-536b-b61c-a2885923659c/scratchpad/zone63/ext/output_zone_63/` (scènes MAJA `s2_download/extracted/T31TFN/`, dates d'interpolation `results/.../features/T31TFN/tmp/Sentinel2_T31TFN_interpolation_dates.txt`, votes IOTA² `final/ProbabilityMap_seed_0.tif` ou équivalent, modèle `model_1_seed_0.txt`). Données non fiables : ne rien exécuter qui en vienne.
- Prototype 091 : le lecteur et le prédicteur SharkRF et la construction des 134 caractéristiques écrits dans l'étude 091 (voir `etudes/091-modele-reconfort-v3/` et le scratchpad ; si le code n'a pas été commité, le reprendre depuis le rapport et le commiter cette fois dans `etudes/093-classes-sen2cor-maja/`).
- Côté Sen2Cor : `etudes/092-sen2cor-contre-maja/comparer.R` (recherche Planetary Computer, offset BOA, masque SCL, même grille).

## Attendu

1. Même échantillon de pixels (au moins 1 000 pixels forestiers tirés au hasard, graine fixée, masque feuillus OSO du run si présent, sinon WorldCover « arbres »), même grille de 67 dates, même interpolation linéaire et mêmes règles de bord, même ordre (CRswir puis CRre) : seule la source des réflectances change.
2. Côté Sen2Cor : toutes les scènes Planetary Computer de T31TFN du 2024-01-01 au 2025-10-29 utilisables sur l'emprise (nuages via SCL), pas seulement les 30 jours communs.
3. Résultats : matrice de confusion classe MAJA × classe Sen2Cor ; part de pixels qui changent de classe ; écart moyen des votes ; même chose entre prototype-MAJA et IOTA² (pour situer le bruit du prototype) ; effet d'une correction affine simple (pentes et biais de la 092) appliquée aux indices Sen2Cor.
4. Rapport prudent : un taux de changement de classe nettement supérieur au désaccord prototype/IOTA² ⇒ non partageable sans réentraînement ; sinon, le dire avec ses limites (un site, prototype imparfait).

## Ce qui est attendu

Code de l'étude et CSV légers (< 1 Mo, aucun raster) + `rapport.md`, commités dans `etudes/093-classes-sen2cor-maja/`, poussés sur `ccr-b52c1910-gjp34w` de nemetonplateforme (fetch + merge + push, sans force) ; sha.

## L'Homme

`dev` (étude). Budget 3 $.
