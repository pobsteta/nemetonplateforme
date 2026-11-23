# Mission 037 — nemeton-relief-cvat-houppiers-foret

> Ouverte le 2026-11-20 au cycle 14, sur la consigne de Pascal (« regarde le brief vers-nemeton et code le dans un cycle »). Origine : brief `~/dev/briefs/vers-nemeton/2026-11-20-relief-cvat-houppiers-foret.md`, émis depuis Groma après l'essai de Marsannay du 2026-11-20 (placette déplacée de 152 m, hors des données LiDAR).
> Dépôt : `nemeton` (session ouverte dans le projet, ADR 0001). Fusion par l'orchestrateur quand les contrôles sont verts. **La release de nemeton n'est pas posée par la mission** : `DESCRIPTION` reste en `.9000`.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire écrire par `creer_projet_inventaire_video()` le schéma 1.7.0 (dalles MNT de 1 km, relief CVAT et houppiers avec leur sommet, sur toute la forêt, tous dans le `.qgz`), pour qu'une placette déplacée sur le terrain garde son calage au sol et son contrôle d'orientation dans Groma.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- Le brief, en entier, dans sa **version révisée le 2026-11-20**, qui remplace la première (pas de dalles MNH, dalles à plat sous `rasters/`, présence exigée dans le `.qgz`) : `~/dev/briefs/vers-nemeton/2026-11-20-relief-cvat-houppiers-foret.md`. Il fait foi pour le format (§ 2) et les critères d'acceptation (§ 6).
- Dans `nemeton` (vérifié le 2026-11-20 sur `origin/main` 70618fd, dernier tag v2026.11.36) : `CLAUDE.md` (§ « Cycle de développement (versions `.9000`) », « Règles strictes »), `R/inventaire_video.R` (`creer_projet_inventaire_video()`, l. 1424 et suivantes), `R/houppiers.R` (`segment_houppiers()`, l. 206 et suivantes), `inst/inventaire_video/inventaire_video.schema.json` (1.6.0), `inst/inventaire_video/inventaire_video.qml`, `tests/testthat/test-houppiers.R`, `test-houppiers-lsms.R`, `test-inventaire-video-gpkg.R`.
- Pour le CVAT (lecture seule, ne rien modifier hors de `nemeton`) : `~/dev/nemetonshiny/R/service_rvt.R` (`build_cvat_precomputed`, l. 515 et suivantes) et `foretaccess::vat_combined()` : **vérifier la plage réelle des valeurs** du fichier CVAT produit (le brief la dit `[0, 1]`).

## Contrat aval lu

- **Groma** lit le GeoPackage et les rasters du projet. `origin/main` de Groma (1dc6825, v2026.11.9) est encore au schéma **1.6.0** : il ignore les fichiers et colonnes nouveaux, et garde les rasters par placette. Rien ne casse : le changement est **additif** (version mineure 1.7.0). Groma lira les dalles, `cvat.tif` et `x_sommet`/`y_sommet` dans une mission à lui, après la release de nemeton.
- **nemeton lui-même** relit les GeoPackages rendus par Groma (`R/inventaire_video.R:121-125`, `:769`, `:903`) : un projet 1.6.0 doit rester lisible, un projet 1.7.0 aussi.
- **nemetonshiny** (§ 4 du brief) passera `cvat_path` : rien à faire dans ce dépôt, seulement un brief.
- Hors périmètre : la valeur des codes `qualite_gnss` et la table des relevés ne changent pas.

## Cas limites (un test par cas, qui échoue sans le changement)

1. Projet **avec `ugf`** : l'emprise est l'union des `ugf` + 50 m.
2. **Sans `ugf`, avec `parcelles`** : union des parcelles + 50 m.
3. **Ni `ugf` ni `parcelles`** : emprise actuelle (placettes + `marge_m`), comme aujourd'hui.
4. **Placette prévue hors des `ugf`** : ses rasters par placette et ses houppiers restent écrits comme aujourd'hui. Choix prudent : l'emprise inclut aussi les placettes + `rayon_m` + `marge_m`. Le noter dans la PR.
5. **Nom et place des dalles** : `rasters/mnt_{x}_{y}.tif`, directement sous `rasters/` (aucun sous-dossier), le coin sud-ouest en km sur 4 chiffres (`rasters/mnt_0849_6689.tif`). Aucune confusion avec `{plot_id}_mnt.tif`. Une emprise qui s'arrête pile sur une limite de kilomètre n'écrit pas de dalle vide de l'autre côté. Seules les dalles qui touchent l'emprise sont écrites, chacune en 2 000 × 2 000 pixels.
6. **Format des dalles MNT** : identique à `rasters.format` (GeoTIFF Float32, une bande, non tuilé, DEFLATE sans prédicteur, nodata -9999, EPSG:2154). Les pixels hors de l'emprise valent nodata.
7. **Données LiDAR qui ne couvrent qu'une partie de l'emprise** : la partie non couverte vaut nodata, sans erreur.
8. **Houppier hors de toute placette** : écrit avec `plot_id` NULL. Un houppier qui touche une placette garde la règle actuelle.
9. **Sommet** : `x_sommet` et `y_sommet` sont à l'intérieur du polygone de chaque houppier, pour chaque méthode de `segment_houppiers()`. Pour `"watershed"` et `"lsms"`, c'est le pixel du `h_max` ; en cas d'égalité, la règle choisie est écrite et testée.
10. **Index** B-tree sur (`x_sommet`, `y_sommet`) présent dans le GeoPackage.
11. **CVAT** : un `cvat.tif` en Byte, 2 m, EPSG:2154, DEFLATE, valeurs `1 + round(v * 254)`, avec **0 = nodata**. Une valeur hors de `[0, 1]` est ramenée dans `[0, 1]`. Un NA donne 0. Un CVAT dans un autre système de coordonnées est reprojeté.
12. **Sans `cvat_path`** : pas de `cvat.tif`, projet écrit sans erreur.
13. **`cvat_path` vers un fichier absent ou illisible** : avertissement clair, pas de `cvat.tif`, projet écrit. C'est le choix le plus prudent ; le noter dans la PR.
14. **Aucune dalle MNH** n'est écrite, ni dans le dossier ni dans le `.qgz`. Le MNH de l'emprise ne sert qu'à segmenter les houppiers (en mémoire ou en fichier temporaire).
15. **Dans le `.qgz`** : les dalles MNT et `cvat.tif` (quand `cvat_path` est fourni) sont sous `rasters/`, à plat, comme les rasters par placette, et aussi dans le dossier du projet. Le test ouvre le `.qgz` (zip) et en liste les entrées.
16. **Rasters par placette** `rasters/{plot_id}_mnt.tif` et `_mnh.tif` inchangés : même fichier, octet pour octet ou valeur pour valeur, sur le projet de test.
17. **Projet 1.6.0 existant** : toujours relu sans erreur par les fonctions de nemeton qui lisent le GeoPackage.

## Ce qui est attendu

1. `segment_houppiers()` : renvoie `x_sommet` et `y_sommet` (les sommets déjà calculés, gardés). Aucune autre signature ne change ; `marge_m` et les méthodes existantes restent valides.
2. `creer_projet_inventaire_video()` :
   - calcule l'emprise ;
   - segmente les houppiers sur toute l'emprise ;
   - écrit les dalles MNT (pas de MNH) ;
   - met les dalles et `cvat.tif` dans le `.qgz` et dans le dossier du projet ;
   - prend un nouvel argument `cvat_path = NULL` (roxygen en anglais).

   Le projet QGIS/QField range les dalles et `cvat.tif` repliés et décochés, comme les rasters par placette.
3. `inst/inventaire_video/inventaire_video.schema.json` passe en **1.7.0**, d'après le § 2 du brief. Le brief cite une source chez Groma qui n'existe pas encore : **nemeton écrit la 1.7.0**, et Groma la recopiera.
4. Tests : un par cas limite ci-dessus, sur des données synthétiques petites (quelques dalles au plus, pas de LiDAR réel, pas de réseau). Lancer `.claude/test-command`, **et aussi** `Rscript -e 'devtools::test(filter = "houppiers|inventaire-video", stop_on_failure = TRUE)'` : le niveau rapide n'exécute pas ces fichiers. Noter les deux dans `tests`.
5. Version : `DESCRIPTION` en `2026.11.36.9000` (cycle dev) si ce n'est pas déjà le cas. Une entrée dans `NEWS.md` sous la rubrique de développement, selon `CLAUDE.md`. Pas de version stable ni de tag.
6. Briefs aux avals :
   - `~/dev/briefs/vers-groma/2026-11-20-schema-1-7-0-ecrit-par-nemeton.md` : le schéma 1.7.0 est écrit côté nemeton (chemin du fichier, ce qui change, et ce que Groma doit lire), à recopier dans `core/src/groma/donnees/` ; disponible à la prochaine release de nemeton.
   - `~/dev/briefs/vers-nemetonshiny/2026-11-20-cvat-path-inventaire-video.md` : le § 4 du brief, avec le nom exact de l'argument.
7. CI verte.

## L'Homme

- **Agent :** `dev`, dans une session ouverte dans `nemeton`. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 3 $ ; worktree depuis `origin/main`.
- **Ce qui ne lui est pas demandé :**
  - poser une version stable, un tag ou une release ;
  - toucher `nemetonshiny`, Groma ou un autre dépôt, sauf les deux boîtes de briefs nommées ;
  - calculer le CVAT, qui vient de `cvat_path` ;
  - fusionner ;
  - déplacer le brief d'origine (l'orchestrateur le range).
- **Dépend de / rouge attendu jusqu'à :** rien.
