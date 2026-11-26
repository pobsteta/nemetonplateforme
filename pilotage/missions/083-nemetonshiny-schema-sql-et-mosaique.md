# Mission 083 — nemetonshiny-schema-sql-et-mosaique

> Ouverte le 2026-11-26 sur un constat de Pascal (sortie console du calcul) : `Warning: Schema initialization error: Failed to prepare query : ERROR: syntax error at or near "creees" LINE 1: creees aussi a la volee par l'application)`, et la même mosaïque de dalles que la 082 (`.regen_grille_pai`). Défaut, pas une question de sens : délégation de Pascal.
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`. Pas de release.

## Mission

**En une phrase :** Faire que l'initialisation du schéma exécute tout `inst/sql/schema.sql` sans se couper sur un point-virgule de commentaire, et que la mosaïque des dalles MNT de la reGénération garde toutes les dalles d'un même système de coordonnées écrit de deux façons.

**Redite par l'agent :** _à compléter avant d'agir._

## Constat

- `R/service_db.R` (init du schéma, vers la ligne 270) découpe le fichier par `strsplit(sql_text, ";")`. `inst/sql/schema.sql:197` contient le commentaire `-- (une ligne par version ; creees aussi a la volee par l'application)` : le point-virgule coupe l'instruction, la suite part en SQL, erreur, et **toutes les instructions qui suivent ne sont pas exécutées** (la boucle est dans un seul `tryCatch`). Dire lesquelles étaient sautées.
- `R/service_regeneration.R:655` (`.regen_grille_pai`) : `terra::vrt(fich)` sur les dalles MNT, même défaut que la 082.

## Attendu

1. Découpage robuste : retirer les commentaires `--` (jusqu'à la fin de ligne) avant de découper sur `;` (les chaînes SQL du fichier ne contiennent ni `--` ni `;` : le vérifier et le dire ; sinon un découpeur qui respecte les chaînes). Retirer aussi le point-virgule du commentaire de `schema.sql:197`.
2. Un test qui exécute le découpage sur le vrai `schema.sql` et vérifie que chaque morceau commence par un mot SQL attendu (`CREATE`, `ALTER`, `INSERT`, `DO`, `COMMENT`…), et qu'un commentaire contenant `;` ne coupe rien. Si une base de test est disponible (`NEMETON_DB_URL_TEST`), test d'intégration : init sans avertissement ; sinon sauté (le dire).
3. Mosaïque : même règle que la 082 (SRS équivalents ⇒ toutes les dalles ; SRS différent ⇒ erreur claire nommant la dalle ; contrôle du nombre de fichiers utilisés), dans un helper interne de l'app (le cœur n'exporte pas le sien ; ne pas attendre la 082).

## Cas limites

1. Commentaire avec `;` : aucun morceau ne commence par du texte de commentaire.
2. Deux dalles MNT, `EPSG:2154` et WKT complet : la grille couvre les deux.
3. Une dalle EPSG:4326 : erreur claire.

## Ce qui est attendu

Code, tests, i18n `\uXXXX` si message UI, contrôle non ASCII dans `R/`, tests des fichiers touchés, `.claude/test-command`, contre-épreuve sans `git stash` nu, cycle dev (`.9022`), NEWS ; commit et push ; sha par `git rev-parse HEAD`. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 3 $. Indépendante de la 082.
