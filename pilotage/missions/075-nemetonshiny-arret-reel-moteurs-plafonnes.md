# Mission 075 — nemetonshiny-arret-reel-moteurs-plafonnes

> Ouverte le 2026-11-26. Pascal : « 075 en premier ». Suite de la mission 072 (PR nemetonshiny #340), dont le dev a établi que RECONFORT et FORDEAD tournent dans un enfant lancé par `nemeton::run_memory_capped()` (via `.run_capped()`, `R/service_monitoring.R:83`) que l'arrêt n'atteint pas.
> **Réorientée vers l'app** (orchestrateur, 2026-11-26) : le cœur offre déjà l'API stable pour arrêter cet enfant — `run_memory_capped(marker_path = )`, `capped_run_alive()`, `stop_memory_capped()` (`nemeton/R/isolate.R`, spec 057, « Stable ») — et l'app s'en sert déjà pour reGénération (`R/mod_regeneration.R:194-235`, `.regen_marker_*`). Aucun changement du cœur n'est requis.
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, **après fusion de la PR #340**, avant 073. Pas de release.

## Mission

**En une phrase :** Faire que l'arrêt (bouton d'arrêt de l'onglet Santé ou de « Tout calculer ») tue vraiment les moteurs RECONFORT et FORDEAD lancés en processus plafonné, par le marqueur de run du cœur (`marker_path` + `stop_memory_capped()`), comme reGénération le fait déjà, pour qu'un calcul arrêté cesse de télécharger et libère son verrou.

## Attendu

1. `.run_capped()` (ou ses appelants RECONFORT et FORDEAD dans `R/service_monitoring.R`) passe un `marker_path` propre au moteur et au projet (ex. `<projet>/cache/layers/reconfort/engine_run.json`, `.../fordead/engine_run.json`), **si** `run_memory_capped` l'accepte (même garde `formals()` que `mod_regeneration.R:299`).
2. Sur arrêt (le chemin qui pose aujourd'hui `cancel_path` / `cancel_computation()` et, depuis 072, retire les toasts), l'app appelle `stop_memory_capped(marker)` pour le ou les moteurs vivants du projet. Factoriser avec `.regen_marker_alive()` / `.regen_marker_stop()` plutôt que dupliquer (un helper commun, `service_*`).
3. Avant de lancer RECONFORT ou FORDEAD, si un moteur du même type vit encore sur le projet (`capped_run_alive(marker)`), ne pas lancer : notification claire (clé de la 072 `monitoring_reconfort_verrou` ou équivalent FORDEAD) avec l'option de l'arrêter.
4. Le drapeau coopératif `cancel_path` reste posé (le cœur le lit aux frontières de phase) : l'arrêt dur vient en plus.
5. Après l'arrêt, le verrou du dossier de travail RECONFORT tenu par l'enfant tué est périmé et repris par le cœur au lancement suivant (`.reconfort_lock_workdir`, PID mort) : vérifier par un test.

## Cas limites (tests, cœur simulé par `local_mocked_bindings`)

1. Lancement RECONFORT : `marker_path` transmis à `run_memory_capped` (et pas transmis si sa signature ne l'a pas).
2. Arrêt pendant un run RECONFORT vivant : `stop_memory_capped` appelé avec le bon marqueur ; idem FORDEAD ; arrêt sans run : rien appelé.
3. Relance pendant qu'un moteur vit : pas de second lancement, message clair.
4. Vrai processus (si faisable sans réseau) : un `run_memory_capped` réel sur une fonction qui dort, arrêté par le chemin d'arrêt de l'app, est mort en quelques secondes.
5. reGénération : comportement inchangé (ses tests existants verts).

## Ce qui est attendu

Code, tests, contrôle non ASCII, i18n `\uXXXX`, tests ciblés et `.claude/test-command` (échec préexistant `test-service_marculus_ortho.R`), contre-épreuve, cycle dev suivant, NEWS ; commit et push. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 4 $. Dépend de : fusion de #340.
