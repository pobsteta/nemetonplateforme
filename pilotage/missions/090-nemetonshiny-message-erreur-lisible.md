# Mission 090 — nemetonshiny-message-erreur-lisible

> Ouverte le 2026-11-27 sur une capture de Pascal : la notification « Erreur lors du diagnostic RECONFORT » affiche des codes de terminal (`[1m`, `[22m`, `[36m`, `[39m`…) et une pile d'appels (`→ 15. └─nemeton:::.stac_search_paginate(...)` …) au lieu d'un message lisible, et la cause réelle (« Timeout was reached [api.stac.teledetection.fr] ») n'y figure pas.
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, partie de `origin/main` 2c7cc8a. Pas de release.

## Mission

**En une phrase :** Faire que les messages d'erreur des calculs longs affichés dans l'app (au moins RECONFORT, FORDEAD, FAST, via `.monitoring_run_error_msg()` et les notifications équivalentes) soient du texte lisible — sans codes de terminal, sans pile d'appels — et donnent la cause racine (la dernière erreur « Caused by » utile, par ex. le délai dépassé vers un hôte), avec le chemin du journal complet quand il existe.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. Un helper unique (par ex. `.message_erreur_lisible(msg)`) : retire les séquences ANSI (`cli::ansi_strip()`), coupe la pile d'appels (lignes `→ N. └─…`, `Backtrace:`), garde l'en-tête et la cause la plus profonde utile, limite la longueur ; extrait le chemin « The child's output was kept in '…' » pour l'afficher comme « Journal : … ».
2. L'utiliser dans `.monitoring_run_error_msg()` (`R/mod_monitoring.R`, appels vers 3984 et 4810) et dans les autres notifications d'erreur de calcul long du suivi sanitaire ; inventorier les autres endroits (fichier:ligne) et les traiter s'ils montrent la même chose.
3. Les messages complets restent en console (pas de perte d'information).
4. i18n `\uXXXX` pour tout libellé nouveau (« Journal : »), aucun littéral.

## Cas limites (tests)

1. Le message réel de Pascal (copié dans le test, ANSI compris, journal `reconfort_child.log`) → texte sans ANSI ni pile, qui contient « Timeout was reached » et « api.stac.teledetection.fr » et le chemin du journal.
2. Un message simple sans ANSI → inchangé.
3. Contre-épreuve sur `origin/main`.

## Ce qui est attendu

Code, tests, contrôle non ASCII, tests des fichiers touchés (`test-mod_monitoring*.R`, i18n), `.claude/test-command` (l'échec déjà présent de `test-service_marculus_ortho.R` n'est pas de toi), cycle dev (`.9025`), NEWS ; commit, push ; sha. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 2 $.
