# Mission 097 — nemetonshiny-marculus-format-csv-9

> Ouverte le 2026-11-27, après la fusion de la 088 (nemetonshiny #352, 37e2388). Source : `pilotage/briefs/brief-nemetonshiny-marculus-format-csv-9.md` (Marculus #82, squash 1e7c0a0, release v2026.11.4).
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w` repartie de `origin/main` 37e23888b. Pas de release.

## Mission

**En une phrase :** Faire que l'import Marculus de nemetonshiny lise les fichiers au format CSV 9 (et les `.marsync` correspondants) : bois fort sous son nouveau nom comme sous l'ancien, volume aérien EMERGE et nombre de tiges qu'il couvre quand ils sont présents, sans rien changer aux imports des formats 2 à 8.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

Tout le détail est dans le brief (points 1 à 6). En résumé :
1. `R/service_marculus_import.R` : lire `VolumeBoisFortTotalM3` / `volumeBoisFortTotalM3` en priorité, sinon l'ancien `VolumeTotalM3` / `volumeTotalM3`, **compris comme bois fort total**. Champ interne : renommer en `volumeBoisFortTotalM3` partout où il est consommé (`MARCULUS_VOLUMES_CONTEXTE`, l. 758, `R/mod_action_plan.R`) ou garder le nom et corriger les libellés ; choisir le moins risqué et le dire.
2. Lire `VolumeAerienTotalM3` / `volumeAerienTotalM3` (tige et contexte) et `NbTigesVolumeAerien` / `nbTigesVolumeAerien` (contexte) ; NA quand absents. S'ils sont affichés : libellé « Volume aérien total (sans découpe, EMERGE) », « sur N tige(s) EMERGE » en contexte mixte ; jamais sommé avec du Schaeffer.
3. Accepter `FormatCsv;9` partout où le format est contrôlé ; mettre à jour le texte d'aide i18n (`utils_i18n.R` l. 769-770, « FormatCsv;2 à 8 » → « 2 à 9 ») ; un format plus récent inconnu : message clair, pas de refus muet.
4. CSV foncier, si l'app le lit : accepter `BoisFortTotal_m3` et `AerienTotal_m3`.
5. i18n `\uXXXX`, aucun littéral, aucun caractère non ASCII dans le code R.

## Cas limites (tests)

1. Un CSV format 8 (ancien nom) et un CSV format 9 (nouveaux noms, aérien présent, contexte mixte EMERGE + Schaeffer) de la même opération donnent le même bois fort, tige par tige et au contexte.
2. Un `.marsync` ancien et un `.marsync` nouveau : idem.
3. Un contexte sans EMERGE : aérien et nombre de tiges à NA.
4. Le journal par tige du format 9 a l'aérien en 23e colonne : la lecture par nom ne doit pas décaler les autres colonnes.
5. Contre-épreuve : les nouveaux tests échouent sur `origin/main`.
Fixtures écrites à la main d'après le brief, dans `tests/testthat/fixtures/`.

## Ce qui est attendu

Code, tests, contrôle non ASCII, tests des fichiers touchés (`test-service_marculus_import*.R`, `test-mod_action_plan*.R`, i18n), `.claude/test-command` (l'échec déjà présent de `test-service_marculus_ortho.R` n'est pas de toi), cycle dev `.9027`, NEWS ; commit, push ; sha. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 2 $.
