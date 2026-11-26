# Mission 086 — nemetonshiny-houppiers-cause-reelle

> Ouverte le 2026-11-26 avec la 085 : sur Couchey, `.project_chm()` (`R/service_marculus.R:938`) avale toute erreur de `nemeton::resolve_project_chm()` et affiche « Houppiers : aucun modèle de hauteur exploitable … (pas de LiDAR HD, et le modèle Open-Canopy ne porte aucune végétation) », alors que l'erreur réelle était `nemeton_mosaique_srs`. Un message qui ment sur la cause.
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, partie de `origin/main` 6f9df89. Pas de release.

## Mission

**En une phrase :** Faire que l'app, quand la recherche du modèle de hauteur échoue par une erreur, dise cette erreur (message du cœur, classe) au lieu d'affirmer qu'il n'y a pas de LiDAR HD, et le dise partout où elle avale aujourd'hui une erreur de `resolve_project_chm()` / `resolve_project_dem()`.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. Inventaire des appels à `resolve_project_chm()` / `resolve_project_dem()` (et `resolve_raster_layer` sur `lidar_mnh`/`lidar_mnt`) dans `R/` qui avalent l'erreur (`tryCatch(..., error = function(e) NULL)`) : les lister avec fichier:ligne.
2. Pour chacun : distinguer « rien trouvé » (NULL rendu par le cœur) de « erreur » ; en cas d'erreur, `cli::cli_warn` (console) avec le message du cœur, et, là où un statut est persisté (`.persist_houppiers_statut`), un statut distinct (par ex. `erreur_chm`) avec le message en détail. Le message « pas de LiDAR HD » reste pour le seul cas NULL.
3. Pas de logique métier, pas de changement de choix de source (c'est la 085, côté cœur).

## Cas limites (tests, cœur simulé par `local_mocked_bindings(..., .package = "nemeton")`)

1. `resolve_project_chm` lève une erreur de classe `nemeton_mosaique_srs` : avertissement avec son message, statut `erreur_chm`, pas de « pas de LiDAR HD ».
2. `resolve_project_chm` rend NULL : message actuel inchangé, statut `sans_chm`.
3. Contre-épreuve sur l'ancien code.

## Ce qui est attendu

Code, tests, i18n `\uXXXX` si texte UI, contrôle non ASCII, tests des fichiers touchés (dont `test-service_marculus*.R` ; l'échec déjà présent de `test-service_marculus_ortho.R` lignes 95-98 n'est pas de toi), `.claude/test-command`, cycle dev (`.9024`), NEWS ; commit et push ; sha. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 2 $. Indépendante de la 085.
