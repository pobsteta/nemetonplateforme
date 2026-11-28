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

## Ajout du 2026-11-26 (second constat de Pascal, capture)

Après l'arrêt de « Tout calculer », relancer le calcul dans l'onglet RECONFORT échoue : `run_reconfort_dieback failed in its capped child process (exit 1)` … `.reconfort_lock_workdir()` → « working directory in use by another process (PID …) ». **Cause lue** : `run_with_python()` (`R/service_python.R` ~l. 126-180) lance le moteur dans un `callr::r_bg` et ne le tue que sur dépassement de délai (30 min sans sortie, 12 h au total) ; l'arrêt de l'utilisateur n'y arrive pas. Le RECONFORT « arrêté » continue donc de télécharger en arrière-plan et garde le verrou du dossier de travail (`nemeton:::.reconfort_lock_workdir`, `<workdir>/.lock`).

4. **L'arrêt tue vraiment le calcul** : `run_with_python()` reçoit un moyen de savoir que l'utilisateur a arrêté (le drapeau d'annulation déjà écrit par `cancel_computation()` / `app_state$cancel_computation`, lu à chaque tour de la boucle de `poll_io`) et fait alors `px$kill_tree()` ; même chose pour les autres moteurs passant par `run_with_python()` (FORDEAD). Le verrou laissé par un processus mort est déjà repris par le cœur (PID mort = verrou périmé) : vérifier que c'est le cas après `kill_tree`.
5. **Message clair** quand un calcul RECONFORT tourne encore (verrou tenu par un processus vivant) : notification i18n « Un calcul RECONFORT tourne encore sur ce projet : attendez sa fin ou arrêtez-le », au lieu de la pile d'appels brute.



1. Événement `reconfort:ingest_item` puis arrêt : la notification `reconfort_progress` est retirée, le ticker stoppé.
2. Arrêt puis événement `reconfort:ingest_item` tardif : pas de nouvelle notification.
3. Même chose pour FAST (`ingest_progress`) ou la chaîne équivalente.
4. Fin normale (`reconfort:complete`) : comportement inchangé.
5. `run_with_python()` avec un enfant factice qui dort : l'annulation le tue en moins de quelques secondes (processus mort vérifié), et l'erreur rendue dit « arrêté par l'utilisateur ».
6. Erreur de verrou du cœur (message simulé) : la notification est le message i18n clair, sans pile d'appels.

## Ce qui est attendu

Code, tests, contrôle non ASCII, i18n `\uXXXX`, tests ciblés et `.claude/test-command` (échec préexistant connu `test-service_marculus_ortho.R`), contre-épreuve, cycle dev suivant, NEWS ; commit et push. L'orchestrateur ouvre la PR.

## L'Homme

- **Agent :** `dev`, worktree de nemetonshiny ; relu par le `relecteur`. Budget 4 $.
- **Dépend de :** fusion de nemetonshiny #339.
