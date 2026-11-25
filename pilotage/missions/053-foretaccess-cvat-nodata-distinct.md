# Mission 053 — foretaccess-cvat-nodata-distinct

> Ouverte le 2026-11-25 au cycle 18, sous la délégation de Pascal du jour (« continue le dev des briefs restants dans les projets en validant les meilleurs choix pour la plateforme par toi même »). Origine : relecture de la mission 051 (nemeton #699) : le CVAT 8 bits de foretaccess code le relief de 0 à 255 et le nodata à 255 (`R/vat_combined.R:76-86`, `.rvt_byte_scale01()`), si bien qu'un relief valide maximal (v ≥ 0,996) est indiscernable du nodata et devient un trou dans le `cvat.tif` de Groma. Le § 2.3 du brief groma `briefs/vers-nemeton/2026-11-20-relief-cvat-houppiers-foret.md` suppose un relief 0 à 254.
> Dépôt : `foretaccess`, depuis la session cloud (branche `ccr-b52c1910-gjp34w`). Fusion par l'orchestrateur à la CI verte (délégation du 2026-11-16). **Pas de release.**

## Mission

**En une phrase (quoi, et pourquoi) :** Faire écrire à `build_cvat_precomputed()` un CVAT 8 bits dont le relief valide va de 0 à 254 et dont 255 est réservé au nodata, sans changer `vat_combined(as_byte = TRUE)` qui reste fidèle au plugin QGIS RVT, pour que le relief le plus clair n'apparaisse plus comme un trou dans le projet QField de Groma.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Choix de l'orchestrateur (délégation)

- **Ne pas toucher `.rvt_byte_scale01()` ni `vat_combined(as_byte = TRUE)`** : c'est le portage du `byte_scale` du plugin QGIS RVT, testé pour la parité (`tests/testthat/test-vat-combined.R:26-30`). La parité avec le plugin reste une promesse du paquet.
- Le changement porte sur le **fichier précalculé** (`build_cvat_precomputed()`, `R/cvat_precompute.R:144-149`), seul consommé par la plateforme (nemetonshiny, puis nemeton pour Groma) : valeur valide 255 → 254 avant l'écriture, NA → 255, et `NAflag = 255` **déclaré explicitement** dans le GeoTIFF (aujourd'hui implicite par terra).
- Prix : un pixel de relief maximal perd un niveau de gris sur 255 (254 au lieu de 255), invisible à l'écran ; en échange, plus aucun trou.
- Un fichier déjà en cache n'est pas réécrit (pas de migration) : il le sera au prochain `overwrite = TRUE` ou à un nouveau projet. Le dire dans NEWS.

## Cas limites (un test par cas, qui échoue sans le changement ; sans réseau ; MNT synthétique)

1. Un MNT dont une zone donne un relief `v` ≥ 0,996 : le fichier écrit par `build_cvat_precomputed()` (avec `mnt_existant`, sans acquisition) n'a **aucune** valeur 255 hors des zones NA ; ces pixels valent 254.
2. Une zone NA du MNT : 255 dans le fichier, et le nodata déclaré est 255 (`terra::describe()` ou `NAflag`), lu comme NA par terra.
3. `vat_combined(as_byte = TRUE)` est inchangé (le test de parité existant reste vert, sans modification).
4. Les autres valeurs (0 à 254) sont identiques à celles de `vat_combined(as_byte = TRUE)`.

## Ce qui est attendu

1. Le correctif dans `R/cvat_precompute.R`, roxygen de `build_cvat_precomputed()` (codage du fichier : 0 à 254, 255 = nodata déclaré), `.Rd` à jour (via `devtools::document()` seulement si la version de roxygen du dépôt le permet sans réécrire d'autres fichiers ; sinon à la main).
2. `.claude/test-command` du dépôt et `Rscript -e 'devtools::test(filter = "cvat|vat-combined")'` ; pour chacun : sha, code, durée, réussis/échoués/sautés.
3. Contre-épreuve : les tests 1 et 2 rougissent sur `origin/main`.
4. Version : cycle dev selon le `CLAUDE.md` de foretaccess (`DESCRIPTION` reste en `X.Y.Z.9000`), entrée NEWS ; `PLAN.md` selon le `CLAUDE.md`.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), dans un worktree de foretaccess. Relu par le `relecteur`.
- **Moyens :** budget 2 $. Le paquet a un noyau Rust (déjà compilé et installé dans le conteneur) ; la mission ne touche pas le crate.
- **Ce qui ne lui est pas demandé :** toucher nemeton, nemetonshiny ou groma ; release ; ouvrir ou fusionner la PR.
- **Dépend de / rouge attendu jusqu'à :** rien.
