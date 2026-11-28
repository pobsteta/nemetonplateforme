# Mission 082 — nemeton-mosaique-dalles-crs

> Ouverte le 2026-11-26 sur un constat de Pascal (sortie console du calcul, projet `20261008_212542_uywc`) : `gdalbuildvrt does not support heterogeneous projection: expected RGF93 v1 / Lambert-93, got EPSG:2154. Skipping …LHD_FXX_0848_6687_MNH_0M50_LAMB93_IGN69.tif` répété, puis `[vrt] vrt did not use 28 of the 29 files`. Défaut, pas une question de sens : délégation de Pascal (« continue le dev … en validant les meilleurs choix »).
> Dépôt : `nemeton`, branche `ccr-b52c1910-gjp34w`. Pas de release.

## Mission

**En une phrase :** Faire que toute mosaïque virtuelle de dalles construite par le cœur (`terra::vrt` sur une liste de fichiers) garde toutes les dalles dont le système de coordonnées est le même sous deux écritures différentes (WKT « RGF93 v1 / Lambert-93 » contre « EPSG:2154 »), et refuse clairement — au lieu d'ignorer en silence — les dalles dont le système est réellement différent.

**Redite par l'agent :** _à compléter avant d'agir._

## Constat

- Appels en cause sur `origin/main` : `R/project_layers.R:154` (`.open_raster`), `R/regen_engines.R:304` (`.rsen_load_raster`, dossiers MNT/MNH de la reGénération), `R/theia_stac.R:639`, `R/fordead_stac.R:419`. Trouver lequel a produit la sortie de Pascal (dossier `cache/layers/lidar_mnh/` de dalles LiDAR HD IGN) et le dire.
- GDAL compare l'écriture du SRS, pas son sens : une dalle IGN sur 29 porte un SRS écrit autrement, et `gdalbuildvrt` jette les 28 autres. Résultat : la mosaïque ne couvre qu'une dalle, sans erreur.

## Attendu

1. Un helper interne unique (par ex. `.mosaique_dalles(fichiers, ...)`) utilisé par tous les appels ci-dessus : vérifie l'équivalence des SRS (`terra::same.crs` contre la première dalle) ; si tous équivalents, construit le VRT avec l'option GDAL qui tolère la différence d'écriture (`-allow_projection_difference`) ; si une dalle a un SRS réellement différent : erreur `cli` qui nomme les dalles (pas de reprojection implicite).
2. Après construction, contrôle : le nombre de fichiers utilisés par le VRT égale le nombre de fichiers donnés ; sinon erreur claire (plus jamais « did not use 28 of 29 » en simple avertissement).
3. Ne pas changer le comportement d'un fichier unique.

## Cas limites (tests sans réseau, petits rasters fabriqués)

1. Deux dalles contiguës, l'une en `EPSG:2154`, l'autre avec le WKT complet Lambert-93 : la mosaïque couvre les deux (étendue et valeurs vérifiées).
2. Une dalle en EPSG:4326 parmi des dalles Lambert-93 : erreur qui la nomme.
3. Une seule dalle : inchangé.
4. Contre-épreuve : l'ancien appel `terra::vrt(fich)` sur le cas 1 ne garde qu'une dalle (le test le montre).

## Ce qui est attendu

Code, tests (fichier `test-mosaique_dalles.R` ou dans les tests existants des fonctions touchées), contrôle non ASCII dans `R/`, tests des fichiers touchés, `.claude/test-command`, contre-épreuve sans `git stash` nu, cycle dev (DESCRIPTION en `.900x`, NEWS), `PLAN.md` (journal) ; commit et push ; sha par `git rev-parse HEAD`. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemeton ; relu par le `relecteur`. Budget 3 $. Indépendante de la 083.
