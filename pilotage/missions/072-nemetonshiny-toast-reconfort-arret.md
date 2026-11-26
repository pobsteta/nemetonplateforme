# Mission 072 — nemetonshiny-toast-reconfort-arret

> Ouverte le 2026-11-26 sur le constat de Pascal (capture) : après l'arrêt de « Tout calculer », le toast « Scène 64/269 — téléchargement · 2026-04-01 — 3:50:06 » de RECONFORT reste en bas à droite, et son chrono continue : il laisse croire que le calcul tourne encore.
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, **après fusion de la PR #339** (même branche de session). Pas de release.

## Mission

**En une phrase :** Faire disparaître toute notification de progression (RECONFORT, et les autres chaînes lancées par « Tout calculer » : FAST, FORDEAD, ingestion…) et arrêter son chrono dès que le calcul est arrêté, annulé ou en erreur, puis dire « calcul arrêté », pour que l'écran ne mente pas sur l'état du calcul.

**Redite par l'agent :** _à compléter avant d'agir._

## Constat (lu sur origin/main)

`R/mod_monitoring.R` (~l. 4580-4650) : les événements `reconfort:ingest_*` posent la notification `session$ns("reconfort_progress")` (`duration = NULL`, sans bouton de fermeture) avec un chrono (`.monitoring_spinning_msg`, ticker `on_msg`). Elle n'est retirée qu'à `reconfort:complete`. L'arrêt (`app_state$cancel_computation`, `mod_home.R` ~l. 1600 ; flag coopératif du cœur ; `compute_task$cancel()`) ne la retire pas et ne stoppe pas le ticker.

## Attendu

1. Sur arrêt, annulation, erreur ou fin de la tâche (quel que soit le chemin : bouton d'arrêt de « Tout calculer », arrêt dans l'onglet Santé, `ExtendedTask` en erreur), toutes les notifications de progression persistantes des chaînes santé (`reconfort_progress`, `fast_prewarm_progress`, `ingest_progress`, et celles de FORDEAD s'il y en a) sont retirées et leurs tickers arrêtés ; une notification courte « calcul arrêté » (clé i18n existante si possible) les remplace.
2. Un événement de progression qui arrive **après** l'arrêt (le processus asynchrone peut en émettre encore) ne fait pas réapparaître le toast.
3. Lire `mod_progress.R` et `mod_home.R` ; centraliser (une fonction qui nettoie) plutôt que dupliquer.

## Cas limites (tests `testServer`, sans réseau)

1. Événement `reconfort:ingest_item` puis arrêt : la notification `reconfort_progress` est retirée, le ticker stoppé.
2. Arrêt puis événement `reconfort:ingest_item` tardif : pas de nouvelle notification.
3. Même chose pour FAST (`ingest_progress`) ou la chaîne équivalente.
4. Fin normale (`reconfort:complete`) : comportement inchangé.

## Ce qui est attendu

Code, tests, contrôle non ASCII, i18n `\uXXXX`, tests ciblés et `.claude/test-command` (échec préexistant connu `test-service_marculus_ortho.R`), contre-épreuve, cycle dev suivant, NEWS ; commit et push. L'orchestrateur ouvre la PR.

## L'Homme

- **Agent :** `dev`, worktree de nemetonshiny ; relu par le `relecteur`. Budget 3 $.
- **Dépend de :** fusion de nemetonshiny #339.
