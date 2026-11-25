# Mission 050 — nemetonshiny-inventaire-video-carte-parametres

> Ouverte le 2026-11-25 au cycle 18, sur la demande de Pascal (capture de la vue Terrain accessible › Inventaire vidéo › Préparer) : « ajouter une carte des points de visite avec ceux qui sont sélectionnés/désélectionnés. Ajouter les paramètres Rayon/Diamètre/... dans source & paramètres. Pourquoi le CVAT n'est pas présent avec la coche MNT, MNH et houppiers ? »
> Dépôt : `nemetonshiny`, depuis la session cloud du 2026-11-25 (clone avec branche autorisée, comme la mission 049). Branche imposée : `ccr-b52c1910-gjp34w`. **Pas de release ni de fusion** : la porte n° 3 de nemetonshiny reste à Pascal (son `CLAUDE.md`, règle stricte 11).

## Le constat (vérifié par l'orchestrateur sur `origin/main` fb5a524)

- La vue « Préparer » (`R/mod_inventaire_video.R`) porte rayon, diamètre minimal, unité d'azimut, déclinaison, la coche « Inclure MNT, MNH et houppiers » et la liste des placettes en `checkboxGroupInput(ns("placettes"))` (l. 157). Aucune carte.
- **CVAT** : `video_args_generation()` (`R/service_inventaire_video.R:161`) ne passe `cvat_path` au cœur que si un CVAT **déjà calculé** existe à côté du MNT du projet (`.video_cvat_path()` l. 205 → `.rvt_precomputed_path()`), « aucun calcul pour l'occasion ». Le seul producteur est l'onglet **Accessibilité** (`R/mod_accessibility.R:687`, `build_cvat_precomputed()`). La coche « MNT, MNH et houppiers » ne règle pas le CVAT. Sans passage préalable par Accessibilité, ou sans MNT LiDAR ou WMS dans le projet, aucun `rasters/cvat.tif` n'est écrit, et rien ne le dit à l'écran.
- « Sources & paramètres » est l'onglet `tab_sources` de la fenêtre Paramètres (`R/mod_theia_config.R:319`, module `mod_sources_config`, options de l'app lues par `get_app_options()`). D'autres vues renvoient déjà là par la phrase « À modifier dans Paramètres › Sources & paramètres. » (clés i18n de `R/utils_i18n.R` vers l. 3043 et 3774).

## Mission

**En une phrase (quoi, et pourquoi) :** Dans la vue Inventaire vidéo de nemetonshiny, montrer sur une carte les placettes du plan, sélectionnées ou non et sélectionnables au clic, déplacer les paramètres de génération (rayon, diamètre minimal, unité d'azimut, déclinaison) dans Paramètres › Sources & paramètres, et dire à l'écran si le relief CVAT sera joint au projet QField, pour que le forestier voie ce qu'il emporte avant de générer.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Choix pris par l'orchestrateur (prudents et réversibles, à confirmer par Pascal dans la PR)

- **Carte** : Leaflet, dans le volet « Préparer », à côté de la liste des placettes (qui reste). Point vert plein = sélectionnée, point gris creux = désélectionnée. Un clic sur un point bascule sa sélection, et la liste et la carte restent d'accord dans les deux sens. Le fond et le relief se font comme les cartes voisines (`mod_desserte.R` vers l. 900, avec le CVAT en fond s'il existe). Les étiquettes portent l'identifiant de la placette (P001…).
- **Paramètres** : rayon, diamètre minimal, unité d'azimut et déclinaison passent dans `mod_sources_config`, comme options de l'app. Les défauts sont ceux d'aujourd'hui : 15 m, 7,5 cm, degrés, déclinaison vide (WMM2025 par placette). La vue n'en garde qu'un rappel d'une ligne (valeurs en cours et « À modifier dans Paramètres › Sources & paramètres. »). **La coche « Inclure MNT, MNH et houppiers » reste dans la vue** : c'est un choix propre à chaque génération.
- **CVAT** : aucun calcul déclenché par cette vue (le calcul prend des minutes, voire environ 350 s sur une mosaïque à 0,5 m, et Pascal n'a pas tranché). Sous la coche, une ligne d'état dit « Relief CVAT : joint au projet » ou « Relief CVAT : absent — le calculer dans Accessibilité ». Cette ligne s'appuie sur `.video_cvat_path()`.

## Les sources à lire avant d'agir

- `CLAUDE.md` de nemetonshiny, en entier : i18n obligatoire avec `\uXXXX`, clés NMT de 30 caractères au plus, couleurs de boutons, pas de logique métier dans `mod_*`, cycle dev `.900x`, NEWS.
- `R/mod_inventaire_video.R`, `R/service_inventaire_video.R`, `R/mod_sources_config.R` (avec `get_app_options()` et ses défauts), `R/mod_theia_config.R` (l. 300-325), `R/mod_desserte.R` (carte et fond CVAT, l. 890-940), `R/service_rvt.R` (`.rvt_precomputed_path()`).
- Les tests existants : `tests/testthat/test-mod_inventaire_video.R` et `test-service_inventaire_video.R` (selon leur nom réel), ainsi que ceux de `mod_sources_config`.

## Cas limites (un test par cas, qui échoue sans le changement ; sans réseau)

1. **Synchronisation** : en `testServer()`, une placette décochée dans la liste passe en « désélectionnée » dans les données de la carte. Un clic simulé sur un marqueur (`input$<carte>_marker_click` avec `id = "P003"`) l'ajoute ou la retire de `input$placettes`. Tout cocher puis tout décocher garde la carte et la liste d'accord.
2. **Plan absent ou vide** : pas de carte (ou une carte vide avec le message existant `video_sans_plan`), sans erreur.
3. **Placettes sans géométrie ou hors CRS** : elles sont reprojetées pour Leaflet (EPSG:4326). Une placette française tombe en France : test de coordonnées avec une placette connue.
4. **Paramètres** : les options rayon, diamètre, unité et déclinaison sont lues par `video_args_generation()` (valeurs non par défaut posées par `withr::local_options()` ou par le mécanisme réel de `get_app_options()`). Les défauts donnent les mêmes `args` qu'aujourd'hui. Une déclinaison vide donne `declinaison_deg = NULL`.
5. **CVAT** : sans CVAT précalculé, la ligne d'état dit « absent » et `args` n'a pas de `cvat_path`. Avec un fichier `<mnt>_CVAT_8bit_foretaccess.tif` fabriqué dans un projet temporaire, elle dit « joint » et `args$cvat_path` y pointe.
6. **i18n** : chaque nouvelle clé existe en `fr` et en `en`, et aucun littéral n'apparaît dans l'UI (le test i18n existant reste vert).

## Ce qui est attendu

1. Le code, réparti entre `mod_*` et `service_*` selon le `CLAUDE.md`, avec les tests ci-dessus.
2. `.claude/test-command` de nemetonshiny s'il existe, sinon `Rscript -e 'devtools::test(filter = "inventaire_video|sources_config|i18n", stop_on_failure = TRUE)'`. Pour chacun : sha, commande, code de sortie, durée, et nombre de tests réussis, échoués et sautés. R est installé dans le conteneur. Une dépendance absente se dit, avec les fichiers sautés comptés ; on ne conclut pas au vert dans ce cas.
3. `DESCRIPTION` passe au cycle dev suivant (`.900x` + 1) et une entrée NEWS en développement est ajoutée, selon le `CLAUDE.md`. **Ne pas toucher `nemeton/PLAN.md`** : un autre dépôt, que l'orchestrateur tient.
4. Le commit va sur `ccr-b52c1910-gjp34w` de nemetonshiny, partie de `origin/main`, puis on pousse. L'orchestrateur ouvre la PR en brouillon et suit la CI.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), dans un worktree de nemetonshiny. Relu par le `relecteur`.
- **Moyens :** budget 3 $. La carte reste visible dans le conteneur par Playwright (`golem` lancé en local) si le `dev` le juge utile ; ce n'est pas exigé.
- **Ce qui ne lui est pas demandé :** calculer le CVAT depuis cette vue ; toucher `nemeton` ; release, tag ou fusion ; ouvrir la PR.
- **Dépend de / rouge attendu jusqu'à :** rien (aucune API nouvelle du cœur).
