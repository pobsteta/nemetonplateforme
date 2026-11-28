# Mission 089 — nemeton-reconfort-repli-archive

> Ouverte le 2026-11-27 sur la décision de Pascal (même jour) : « repli automatique sur les archives GEODES ». Constat : premier essai réel de la voie fenêtre (Couchey, T31TFN, année 2026) en échec à l'ingest, `api.stac.teledetection.fr` injoignable (connexion expirée à 60 s chez Pascal, puis à 20 s par `curl` ; 503 « no available server » depuis le conteneur) ; journal `data/reconfort_child.log` : `.reconfort_fenetre_lister()` → `.stac_search_paginate()` → `httr2::req_perform()` « Timeout was reached ».
> Dépôt : `nemeton`, branche `ccr-b52c1910-gjp34w`, **après la fusion de la PR #710** (release 2026.11.46), partie de `origin/main` à jour. Pas de release.

> **Mise à jour du 2026-11-27 (après la fusion de la 095, nemeton #711, 9274d35).** Partir d'`origin/main` 9274d35 (DESCRIPTION en 2026.11.46.9000 → passer en `.9001`). La 095 a centralisé le choix de voie dans `.reconfort_voie_suivante()` (`R/reconfort_sen2cor.R`) avec un point de raccord commenté pour cette mission : le repli s'y branche, dans l'ordre **THEIA (fenêtre) → GEODES (archive) → Sen2Cor** (décision de Pascal du 2026-11-27). Repli sur Sen2Cor quand GEODES échoue à son tour, avertissement `nemeton_reconfort_repli_sen2cor` existant. **Décision de Pascal du 2026-11-27 : garder le repli Sen2Cor « indicatif » quand conda manque** (comportement déjà codé par la 095, à ne pas changer). Une voie imposée par l'appelant n'est jamais remplacée. `causes_repli` de `run_meta.json` porte chaque cause de repli (THEIA puis GEODES), dans l'ordre.

## Mission

**En une phrase :** Faire que `run_reconfort_dieback()`, quand la voie fenêtre n'a pas été imposée et que le catalogue STAC THEIA ne répond pas (délai dépassé, erreur de connexion, HTTP 5xx), bascule sur la voie archive GEODES avec un avertissement clair au lieu d'échouer, et qu'une voie fenêtre imposée échoue avec un message lisible ; et supprimer l'avertissement `future` des connexions laissées ouvertes par le processus de calcul plafonné.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. Sonde courte du catalogue avant l'ingest (une requête légère, délai d'au plus ~15 s, une nouvelle tentative) ; ou capture de l'échec de la première recherche STAC. Distinguer : indisponibilité (timeout, connexion, 5xx) → repli ; erreur 4xx (clés, requête) → pas de repli silencieux, erreur claire (les clés ou la requête sont en cause).
2. Repli seulement si `acquisition` n'a pas été donnée explicitement (même règle que le repli « clés absentes » existant, `R/reconfort_pipeline.R` vers la ligne 962) ; avertissement `cli_warn` de classe `nemeton_reconfort_repli_archive` : « catalogue THEIA indisponible (cause) : passage par les archives GEODES (~2 Go par scène) ». Voie fenêtre explicite : erreur de classe `nemeton_reconfort_stac_indisponible`, message court avec l'hôte et la cause.
3. La voie retenue est inscrite dans la trace du run (progress/meta) pour que l'app puisse la dire.
4. Avertissement `future` « MultisessionFuture … added connections … supervisor_stdin / supervisor_stdout (fifo) » vu chez Pascal à chaque run RECONFORT : trouver qui ouvre ces fifos (vraisemblablement le superviseur `processx` d'un `callr`/`processx::process$new(supervise = TRUE)` dans le run plafonné, `run_memory_capped()`), et les fermer ou ne pas les ouvrir dans le worker, sans perdre l'arrêt sûr du processus enfant (mission 075). Si la correction relève de l'app (worker `future`), le dire au lieu de la faire.

## Cas limites (tests sans réseau, `httr2` simulé ou `local_mocked_bindings`)

1. STAC en délai dépassé, acquisition par défaut → avertissement de repli, ingest appelé avec `acquisition = "archive"`.
2. STAC en 503 → idem.
3. STAC en 401/403 → erreur claire, pas de repli.
4. `acquisition = "fenetre"` explicite + STAC injoignable → erreur `nemeton_reconfort_stac_indisponible`.
5. STAC joignable → voie fenêtre, aucun avertissement (non-régression).
6. Contre-épreuve sur `origin/main` : le cas 1 échoue comme chez Pascal.

## Ce qui est attendu

Code, tests, contrôle non ASCII, tests des fichiers touchés (dont `test-reconfort-*.R`, `test-memory-capped*.R` s'il existe), `.claude/test-command`, cycle dev (`2026.11.46.9000` puis `.9001`), NEWS, PLAN.md ; commit, push ; sha. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemeton ; relu par le `relecteur`. Budget 3 $.
