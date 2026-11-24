# Mission 042 — nemeton-era5ts-cache-scalaires

> Ouverte le 2026-11-24 au cycle 15, sous la délégation de Pascal (« Fais le et test la colombière »). Origine : essai réel de la Colombière par l'orchestrateur, le 2026-11-24 vers 0 h 30, avec nemeton v2026.11.43 installé.
> Dépôt : `nemeton` (session ouverte dans le projet, ADR 0001). Fusion et release par l'orchestrateur. **Correctif urgent** : le chemin ERA5 par défaut ne marche pas sur une vraie réponse du CDS.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire accepter par le contrôle de cache ERA5 les fichiers NetCDF que le CDS livre réellement pour le jeu `timeseries` (variables `latitude` et `longitude` scalaires, sans dimension), pour que le forçage par défaut de microclimf et de BILJOU cesse de rejeter chaque fichier valide et de le redemander en boucle.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Le constat (vérifié par l'orchestrateur)

- Le CDS a livré en 1 à 2 min par maille un zip contenant un seul NetCDF-4 (`reanalysis-era5-single-levels-timeseries-*.nc`) : dimension unique `valid_time` (8 760 pas, secondes depuis 1970), variables `u10 v10 d2m t2m sp ssrd strd tcc tp fdir` en float sur `valid_time`, et **`latitude`, `longitude` scalaires (0 dimension)**. Le fichier est sain : `ncdf4::ncvar_get()` lit chaque variable.
- `nemeton:::.rsen_era5_nc_complet()` (`R/regen_engines.R:437`) rend `FALSE` sur ce fichier : pour chaque variable il lit `ncvar_get(nc, v, start = v$varsize, count = rep(1L, length(dl)))`, ce qui échoue sur une variable à 0 dimension (`varsize` vide). D'où « Discarding unreadable cache file 'era5ts_5p00_47p25_2018.nc' » (`.cache_valid_or_drop`, `R/utils.R:1650`), le fichier effacé, la requête resoumise.
- La vraie réponse est gardée hors dépôt : `~/.cache/nemetonplateforme/m042/reponse-cds-reelle-2018.zip` (maille 5,00 E / 47,25 N, 2018). Les fixtures des tests de la mission 039 n'ont pas de variable scalaire : c'est pourquoi la CI était verte.

## Les sources à lire avant d'agir

- `CLAUDE.md` de nemeton ; `R/regen_engines.R` (`.rsen_era5_nc_complet()`, `.rsen_era5_cache_ok()`, le lot) ; `R/era5_timeseries.R` (`.rsen_era5ts_en_cache()`, `.rsen_era5ts_couvre()`, `.rsen_era5ts_lire_maille()`, `.rsen_era5ts_extraire()`) ; `R/utils.R` (`.cache_valid_or_drop`) ; `tests/testthat/test-era5-timeseries.R` (fixtures `.ts_fixture()`) et les tests du contrôle de cache classique dans `test-regen-engines.R`.

## Cas limites (un test par cas, qui échoue sans le changement ; sans réseau)

1. **Forme réelle** : un NetCDF-4 à la forme exacte de la réponse CDS (dimension `valid_time`, 10 variables float, `latitude` et `longitude` scalaires) est accepté par `.rsen_era5_nc_complet()`, par `.rsen_era5ts_en_cache()` et lu par `.rsen_era5ts_lire_maille()`. Fixture **construite par le test** avec `ncdf4` (petite : quelques jours suffisent si `.rsen_era5ts_couvre()` le permet pour le cas visé ; sinon une année au pas horaire, générée, pas copiée), pas le fichier réel de 480 Ko.
2. **Chaîne complète** : un accès CDS simulé dont `extraire` livre un zip de cette forme → `.rsen_forcage_era5()` rend le data.frame, sans aucun « Discarding » ni nouvel envoi (compteur de `soumettre` à 4 pour les 4 mailles, pas plus).
3. **Variables scalaires dans le contrôle** : une variable à 0 dimension est lue entière (une valeur) ; un fichier tronqué ou une variable illisible reste refusé comme avant (tests existants verts).
4. **Chemin classique** : les NetCDF de mcera5 (classiques et NetCDF-4) restent acceptés à l'identique (tests existants verts).
5. **Contrôle sur le vrai fichier (hors CI)** : l'agent vérifie localement que `.rsen_era5_nc_complet()` rend `TRUE` sur le NetCDF extrait de `~/.cache/nemetonplateforme/m042/reponse-cds-reelle-2018.zip`, et que `.rsen_era5ts_lire_maille()` le lit ; il le dit dans la PR (commande et sortie). Le fichier réel n'entre pas dans le dépôt.

## Ce qui est attendu

1. Le correctif dans `.rsen_era5_nc_complet()` (ou un contrôle propre au `timeseries`, si c'est plus sûr : à justifier dans la PR).
2. `.claude/test-command` **et** `Rscript -e 'devtools::test(filter = "era5-timeseries|regen-engines|load-biljou", stop_on_failure = TRUE)'` ; les deux dans `tests`.
3. `DESCRIPTION` en cycle dev (`2026.11.43.9000` si `main` ne l'est pas déjà : le poser dans la même PR) ; entrée `NEWS.md` en développement (« fix ») ; `PLAN.md` selon `CLAUDE.md`. Pas de version stable ni de tag.
4. CI verte, codecov compris. Pas de ScheduleWakeup : attendre la CI au premier plan, puis rendre.

## L'Homme

- **Agent :** `dev`, dans une session ouverte dans `nemeton`. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 3 $ ; worktree depuis `origin/main`.
- **Ce qui ne lui est pas demandé :** release ; appel réel au CDS ; toucher un autre dépôt ; fusionner.
- **Dépend de / rouge attendu jusqu'à :** rien.

## Fin

> Ajoutée le 2026-11-24 (mission 046), d'après le journal et le kanban.

PR nemeton #689 (3e0171b97) fusionnée (718518b) le 2026-11-24 ; publiée en v2026.11.44 (PR de release nemeton #690, tag `v2026.11.44`). Coût : 0,81 $ pour 3 $ ; 0 aller-retour (relue « prête » au premier rendu). Essai réel de la Colombière vert : 1,8 min par année.
