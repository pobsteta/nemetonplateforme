# Mission 071 — nemeton-reconfort-lecture-fenetree

> Ouverte le 2026-11-26 sur la décision de Pascal du même jour : « lance la 071 en gardant IOTA² et on compare les 2 méthodes ».
> Dépôt : `nemeton`, branche imposée `ccr-b52c1910-gjp34w`, partie d'`origin/main` (04849a3 ou plus récent). **Pas de release.**

## Mission

**En une phrase (quoi, et pourquoi) :** Faire lire à RECONFORT, comme FAST, les seules fenêtres utiles des bandes THEIA/MUSCATE L2A au lieu de télécharger l'archive entière de chaque scène (≈ 2 Go), en reconstituant l'arborescence que IOTA² attend, puis outiller la comparaison des deux méthodes (archive contre fenêtre) et de la carte IOTA² contre le spike de la mission 060, pour réduire le temps d'ingestion sans changer le résultat.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les décisions (font foi)

1. **IOTA² est gardé** : la méthode RECONFORT officielle reste celle qui produit la carte. Seule l'acquisition change.
2. **Lecture fenêtrée** : les bandes dont RECONFORT a besoin (lire la liste exacte dans `R/reconfort_ingest.R`, `R/reconfort_crop.R` et les scripts IOTA² vendus ; au moins B4, B5, B6, B8A, B11, B12 et les masques MAJA nuages/ombres/eau/neige, CLM/MG2/SAT ou équivalent) sont lues à distance par fenêtre sur l'emprise de la zone (avec la marge que `.reconfort_crop_scenes_to_aoi()` applique aujourd'hui), par les moyens déjà présents dans le cœur (`R/theia_stac.R` : recherche STAC, URL signées `/vsicurl/` ; reprises comme `R/monitoring.R`). Les fichiers écrits doivent être **ceux que `.reconfort_crop_scenes_to_aoi()` écrit aujourd'hui** (noms, arborescence `extracted/<tile>/…`, grille, type, valeurs) : IOTA² ne voit pas la différence.
3. **Choix de méthode exposé** : un paramètre d'acquisition (par ex. `acquisition = c("fenetre", "archive")`) ; **défaut `"fenetre"`**, `"archive"` conservé intact pour la comparaison et en repli. Aucune signature publique cassée.
4. **Comparer les deux méthodes**, outillé et documenté :
   - a) **archive contre fenêtre** : sur une même scène et une même zone, les rasters écrits sont identiques (mêmes dimensions, étendue, CRS, valeurs au bit près ou écart nul documenté) ; durée et volume téléchargé mesurés pour chacune ;
   - b) **IOTA² contre spike 060** : un script `data-raw/comparaison_reconfort/` qui, sur une zone, prend la carte RECONFORT IOTA² et la carte du spike (`reconfort_entrainer()`/prédiction, `reconfort_comparer_amont()`), et rend l'accord par classe (matrice de confusion, accord global, kappa en indicateur), les surfaces, et les durées. Il se lance sur la machine de Pascal (conda IOTA², compte GEODES/THEIA) ; sorties hors dépôt.
5. Le réseau réel n'est jamais exigé par les tests : tests sans réseau sur fixtures légères (petits COG fabriqués) ; test vivant THEIA facultatif, sauté sur erreur de transport (`.tss_sauter_si_reseau()`).

## Les sources

`nemeton/CLAUDE.md` ; `R/reconfort_ingest.R`, `R/reconfort_crop.R`, `R/reconfort_pipeline.R`, `R/reconfort_validity.R`, `R/theia_stac.R`, `R/monitoring.R` (`.get_s2_band_raster`, reprises `/vsicurl/`, `GDAL_DISABLE_READDIR_ON_OPEN`), `R/reconfort_apprentissage.R` (spike), spec 029 (source MUSCATE de FAST), spec 070, ADR-013 A4 et A6 (`nemetonplateforme/docs/ADR-013_Suivi_sanitaire_FORDEAD.md`), PR #692 (lecture fenêtrée de FAST).

## Cas limites (un test chacun, sans réseau)

1. Pour une scène fabriquée, la voie « fenêtre » écrit les mêmes fichiers (noms, arborescence, valeurs) que la voie « archive » appliquée à une archive fabriquée du même contenu.
2. Une bande ou un masque absent de l'item STAC : erreur claire nommant la bande, pas de scène à moitié écrite.
3. Une lecture qui échoue puis réussit : la reprise fonctionne ; échec durable : scène sautée et dite, comme la voie archive.
4. `acquisition = "archive"` garde le comportement actuel (tests existants verts sans modification).
5. Le script de comparaison b) tourne sur deux petites cartes fabriquées et rend matrice, accord et surfaces justes.

## Ce qui est attendu

Code, tests, script de comparaison, `README` court de la comparaison (commande à lancer chez Pascal) ; aucun caractère non ASCII dans le code R hors commentaires ; nouvelles fonctions exportées dans `_pkgdown.yml` ; tests ciblés `reconfort|theia` puis `devtools::test()` ; contre-épreuve ; `DESCRIPTION` en cycle dev suivant, NEWS, entrée `PLAN.md` ; commit et push sur `ccr-b52c1910-gjp34w`. L'orchestrateur ouvre la PR. Mesure réelle de durée seulement si THEIA répond depuis la session (sinon : dit, et laissé au lancement chez Pascal).

## L'Homme

- **Agent :** `dev`, worktree de nemeton. Relu par le `relecteur`.
- **Moyens :** budget 6 $.
- **Ce qui ne lui est pas demandé :** remplacer IOTA² ; réentraîner le spike ; toucher nemetonshiny ; release ; PR.
- **Dépend de :** rien.
