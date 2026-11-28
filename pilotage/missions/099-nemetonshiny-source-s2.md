# Mission 099 — nemetonshiny-source-s2

> Ouverte le 2026-11-28, après la release du cœur **nemeton v2026.11.47** (PR #714, tag posé par `release.yml` à 08:22 UTC), qui contient la 095 (RECONFORT sur Sen2Cor, indicatif), la 089 (repli THEIA → GEODES → Sen2Cor) et la 096 (`source_s2`).
> Décisions de Pascal du 2026-11-27 qui s'appliquent ici :
> - un choix de source par projet ;
> - par défaut, chaque méthode garde sa source de calage (RECONFORT = THEIA ; FAST, FORDEAD et ICD = Sen2Cor) ;
> - repli sur Sen2Cor si THEIA est en panne ;
> - le champ `validee` est supprimé ;
> - l'app déduit « indicatif » en comparant `calee_sur` à la source effective.
>
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, partie de `origin/main` 17f8115f2 (DESCRIPTION 2026.11.6.9027). Pas de release.

## Mission

**En une phrase :** Permettre de choisir, dans Sources & paramètres, la source Sentinel-2 du suivi sanitaire d'un projet (défaut par méthode, THEIA ou Sen2Cor) et la passer à FAST, FORDEAD, RECONFORT et l'ICD. Chaque carte du suivi dit la source effectivement utilisée, la mention « indicatif » quand la méthode tourne hors de sa source de calage, et le repli quand il a eu lieu.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. **Plancher du cœur** : `Imports: nemeton (>= 2026.11.47)`, et rien d'autre dans `DESCRIPTION` côté dépendances (`Remotes @*release` ne bouge pas).
2. **Réglage** : dans `R/mod_sources_config.R`, un choix « Source Sentinel-2 du suivi sanitaire » à trois valeurs. `NULL` = « par méthode (recommandé) » est le défaut, y compris pour les projets existants ; viennent ensuite « THEIA (MAJA) » et « Sen2Cor (Planetary Computer) ». Le choix est enregistré dans les métadonnées du projet, au même endroit que les autres réglages de sources, et une migration éventuelle se fait dans `R/migrate.R` sans rien changer pour les projets existants. Texte d'aide i18n : RECONFORT est calé sur THEIA, FAST, FORDEAD et l'ICD sur Sen2Cor, et un résultat hors calage est indicatif.
3. **Transmission** : l'argument `source_s2` est passé aux appels `nemeton::` de FAST, FORDEAD, RECONFORT et de l'ICD (services `R/service_*.R`, jamais dans `mod_*.R`). Avec « par méthode », aucun `source_s2` n'est passé, pour un comportement identique à aujourd'hui. Vérifier par un test que les appels gardent exactement leurs arguments actuels dans ce cas.
4. **Lecture des résultats** : avec la source THEIA, les résultats de l'ICD sont dans `<result_dir>_theia` et ceux de FORDEAD dans `<mask_cache_dir>_theia/zone_<id>`, et le cache FAST est `<cache>_theia`. Les lecteurs de l'app (`read_icd_*`, `read_fordead_dieback_mask()`, `read_fast_alert_raster()`, cartes `mod_monitoring_*_map.R`) doivent lire le bon dossier selon la source effective du dernier run, inscrite dans ses métadonnées. Sans `source_s2`, les chemins ne changent pas.
5. **Affichage** : sur chaque carte ou panneau du suivi sanitaire (FAST, FORDEAD, RECONFORT, ICD), une ligne discrète « Source : THEIA (MAJA) / Sen2Cor ».
   - **Indicatif** : quand `calee_sur` diffère de la source effective, on ajoute la mention « indicatif », avec la `mention` du cœur en infobulle si elle existe. C'est le cas de RECONFORT sur Sen2Cor (`source_reflectances = "sen2cor"`, voie de la 095) comme de FAST, FORDEAD et ICD sur THEIA.
   - **Repli** : quand il a eu lieu (`repli_sen2cor`, `causes_repli` de RECONFORT), une ligne « repli : … » donne la cause, sous une forme lisible (`.message_erreur_lisible()`).
   - Couleurs : le badge « indicatif » est un avertissement, ce n'est pas du contenu IA. Ne pas utiliser l'ambre `bg-ia` ; choisir une classe d'avertissement existante.
6. **Avertissements du cœur** : les classes `nemeton_s2_repli_sen2cor`, `nemeton_s2_source_non_calee`, `nemeton_reconfort_repli_archive` et `nemeton_reconfort_repli_sen2cor` doivent devenir des notifications lisibles, pas des avertissements bruts en console. Les erreurs `nemeton_s2_theia_refuse`, `nemeton_s2_theia_sans_cles` et `nemeton_reconfort_stac_refuse` deviennent un message « vérifier les clés THEIA » qui renvoie vers Sources & paramètres.
7. **i18n** : toutes les nouvelles clés sont dans `TRANSLATIONS` (FR/EN), en `\uXXXX`, avec 30 caractères au plus par clé.
8. **`validee`** : l'app n'en lit aucun (vérifié par grep le 2026-11-27). Ne pas en introduire.

## Cas limites (tests)

1. Un projet existant sans réglage donne « par méthode » : les appels `nemeton::` sont inchangés (stub) et les chemins de lecture aussi.
2. Avec « THEIA » : `source_s2 = "theia"` est passé aux quatre méthodes, l'ICD est lu dans `_theia`, et le badge « indicatif » s'affiche sur FAST, FORDEAD et l'ICD, mais pas sur RECONFORT.
3. Avec « Sen2Cor » : le badge « indicatif » s'affiche sur RECONFORT seulement.
4. Repli simulé (métadonnées `repli_sen2cor = TRUE`, `cause_repli`) : la ligne « repli » s'affiche avec la cause lisible.
5. Erreur `nemeton_s2_theia_refuse` simulée : le message parle des clés THEIA et ne montre aucune pile d'appels.
6. Contre-épreuve : les nouveaux tests échouent sur `origin/main`.

## Ce qui est attendu

Livrer, puis rendre le sha :
- code et tests ;
- contrôle ASCII, et tests des fichiers touchés : `test-mod_sources_config.R`, `test-service_monitoring.R`, `test-service_icd.R`, `test-mod_monitoring*.R`, `test-service_pipeline.R`, `test-i18n_keys_used.R`, `test-utils_i18n.R` ;
- cycle dev `.9028` et NEWS ;
- commit et push.

L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny, relu par le `relecteur`. Budget 5 $.
