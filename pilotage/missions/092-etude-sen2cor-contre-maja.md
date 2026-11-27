# Mission 092 — etude-sen2cor-contre-maja

> Ouverte le 2026-11-27 sur la décision de Pascal (« oui lance les deux études ») : peut-on nourrir RECONFORT avec le cache Sentinel-2 de FAST/FORDEAD (Planetary Computer, collection `sentinel-2-l2a`, correction Sen2Cor, masques SCL) au lieu des scènes THEIA/MUSCATE (correction MAJA, bandes FRE, masques CLM) sur lesquelles le modèle v3 a été entraîné ?
> Étude : script et rapport dans `etudes/092-sen2cor-contre-maja/` de nemetonplateforme (pas de code produit). Le côté MAJA dépend du catalogue THEIA, en panne depuis le 2026-11-27 au matin.

## Mission

**En une phrase :** Mesurer, sur une même zone forestière et aux mêmes dates, l'écart entre CRswir et CRre (formules de `nemeton::reconfort_indices()`) calculés à partir des réflectances Sen2Cor de Planetary Computer et à partir des réflectances MAJA FRE de THEIA, et dire si cet écart est négligeable devant ce qui sépare les classes du modèle.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. Un script R reproductible (`etudes/092-sen2cor-contre-maja/comparer.R`) qui, pour une zone (par défaut une emprise de quelques km² en forêt de chênes de la tuile T31TFN — Couchey ; à défaut une zone de chênaie documentée), une période d'été (par ex. juin à août 2023) :
   - cherche les scènes des deux collections aux mêmes dates (même jour de prise de vue) ;
   - lit les bandes B4, B5, B6, B8A, B11, B12 sur la même grille 10 m (Lambert-93), applique les masques de chaque chaîne (SCL côté Sen2Cor, CLM/SAT/EDG côté MAJA) et ne garde que les pixels valides des deux côtés ;
   - applique le décalage radiométrique Sen2Cor (`BOA_ADD_OFFSET`, baseline ≥ 04.00) comme le fait déjà nemeton pour FORDEAD ;
   - calcule CRswir et CRre avec `nemeton::reconfort_indices()` ;
   - rend par date et par indice : n pixels, biais moyen, écart-type des différences, RMSE, corrélation, pente et ordonnée d'une régression, quantiles des différences.
2. Le côté Planetary Computer tout de suite (accès public, signature PC) ; le côté THEIA dès que `api.stac.teledetection.fr` répond (clés `TLD_*` : absentes du conteneur ; dire si une voie publique suffit pour la lecture). Si THEIA reste injoignable, le script est prêt, testé sur le côté PC, et le rapport dit ce qui manque ; Pascal pourra le lancer chez lui.
3. Rapport (`rapport.md`) : résultats chiffrés, et comparaison avec l'ordre de grandeur qui sépare les classes (à défaut des seuils internes du modèle, la dispersion des indices dans une chênaie sur la saison) ; verdict prudent (partageable / non / à confirmer), sans inventer.

## Ce qui est attendu

Script, rapport, sorties légères (CSV) commités sur `ccr-b52c1910-gjp34w` de nemetonplateforme (seul `etudes/092-sen2cor-contre-maja/` touché ; pas de raster lourd commité), sha.

## L'Homme

`dev` (étude), contexte neuf. Budget 3 $.
