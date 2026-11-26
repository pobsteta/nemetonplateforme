# Mission 085 — nemeton-mnh-dalles-et-chm-derive

> Ouverte le 2026-11-26 sur une régression constatée chez Pascal après la PR nemeton #708 (mission 082) : sur Couchey (`20261008_212542_uywc`), `resolve_project_chm()` lève `nemeton_mosaique_srs` car `cache/layers/lidar_mnh/` contient 28 dalles MNH IGN (SRS nommé « EPSG:2154 », sans bloc d'autorité) ET `chm.tif`, calculé par `compute_dtm_chm_from_laz()` (lasR, 1 m, SRS « RGF93 v1 / Lambert-93 »). Avant la 082, GDAL ne gardait que `chm.tif` (premier fichier). Décision de Pascal (même jour) : **les dalles IGN (0,5 m) priment ; `chm.tif` ne sert que sans dalles.**
> Dépôt : `nemeton`, branche `ccr-b52c1910-gjp34w`. Pas de release.

## Mission

**En une phrase :** Faire que `resolve_project_chm()` (et `resolve_project_dem()` pour le même cas dans `lidar_mnt/`) ne mosaïque jamais un produit dérivé avec les dalles IGN — dalles IGN d'abord, produit dérivé du nuage (`chm.tif`, `dtm.tif`, et tout `*_mosaic.tif` écrit par l'app) en candidat suivant — et que deux SRS de même sens (Lambert-93 nommé « EPSG:2154 » sans autorité contre WKT complet) soient reconnus équivalents.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. `R/project_layers.R` : le candidat « LiDAR HD MNH » (`lidar_mnh/`) ne prend que les dalles IGN (motif des noms IGN, par ex. `^LHD_.*MNH.*\\.tif$`, ou à défaut tous les `.tif` sauf les produits dérivés connus) ; un candidat suivant « LiDAR HD CHM (nuage, lasR) » prend `lidar_mnh/chm.tif`. Même chose pour le MNT (`lidar_mnt/`, `dtm.tif`) dans `resolve_project_dem()`. Inventorier les produits dérivés que le cœur ou l'app écrivent dans ces dossiers (`grep` des écritures : `chm.tif`, `dtm.tif`, `*_mosaic.tif`, autres) et les dire.
2. `R/mosaique_dalles.R` : l'équivalence des SRS devient sémantique : `terra::same.crs` vrai, OU la transformation de quelques points (coins de l'emprise de la dalle) du SRS A vers le SRS B est l'identité à 1 mm près. Garder le refus des SRS réellement différents (2154/27572, 32631/32632, 2154/3035, Lambert-93 à x_0 = 700001 : refus attendu).
3. Reproduire le cas réel : un SRS Lambert-93 nommé « EPSG:2154 » sans bloc d'autorité (si le réseau le permet, une vraie dalle MNH IGN LiDAR HD ; sinon un WKT fabriqué du même nom, et le dire) face au WKT complet « RGF93 v1 / Lambert-93 » : équivalents, mosaïque complète.
4. NEWS : dire la régression de la #708 sur un projet réel, sa cause et le choix de Pascal.

## Cas limites (tests sans réseau)

1. Dossier avec dalles IGN + `chm.tif` : le CHM rendu = mosaïque des dalles seules (étendue, résolution 0,5 m), libellé « LiDAR HD MNH ».
2. Dossier avec `chm.tif` seul : rendu = `chm.tif`, libellé du candidat nuage.
3. Idem pour `lidar_mnt/` avec `dtm.tif`.
4. Équivalence : cas réel ci-dessus vrai ; les refus de la 082 toujours refusés.
5. Contre-épreuve : avec le code de `origin/main`, le cas 1 lève `nemeton_mosaique_srs`.

## Ce qui est attendu

Code, tests, contrôle non ASCII, tests des fichiers touchés (`test-project_layers.R`, `test-mosaique_dalles.R`, et tout test de `resolve_project_*`), `.claude/test-command`, contre-épreuve sans `git stash` nu, cycle dev, NEWS, PLAN.md ; commit et push ; sha. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemeton ; relu par le `relecteur`. Budget 3 $. Urgent (régression sur le poste de Pascal).
