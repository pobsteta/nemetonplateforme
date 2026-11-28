# Mission 055 — nemetonshiny-cvat-erreur-codage

> Ouverte le 2026-11-25 au cycle 18, sous la délégation de Pascal du jour (« continue le dev des briefs restants dans les projets en validant les meilleurs choix pour la plateforme par toi même »). Origine : mission 051 (PR nemeton #699) : `creer_projet_inventaire_video()` lèvera désormais une erreur de classe `nemeton_erreur_cvat_codage` pour un CVAT au codage inconnu (par exemple un `*_CVAT_8bit.tif` du plugin QGIS sans nodata déclaré), là où il sortait un projet sans relief. nemetonshiny passe `cvat_path` dès qu'un fichier existe (`R/service_inventaire_video.R`, `.video_cvat_path()`, `.rvt_precomputed_path()`). À faire **avant la prochaine release de nemeton** (l'app tire `@*release`).
> Dépôt : `nemetonshiny`, depuis la session cloud (branche `ccr-b52c1910-gjp34w`, repartie de `origin/main` e8ab0f1 après la fusion de #330). **Fusion par Pascal** (règle 11 de nemetonshiny). Pas de release.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire que la génération du projet QField de l'inventaire vidéo, quand nemeton refuse le CVAT pour son codage (`nemeton_erreur_cvat_codage`), reprenne aussitôt sans relief et le dise à l'écran, pour qu'un CVAT mal codé ne prive jamais le forestier de son projet.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Choix de l'orchestrateur (délégation)

- **Reprise sans relief** : l'app relance `creer_projet_inventaire_video()` une fois **sans** `cvat_path` ; elle ne convertit rien elle-même (le codage reste l'affaire du cœur).
- **Dit à l'écran** : la ligne d'état CVAT de la vue (mission 050) passe à « absent » avec la raison « codage du fichier non reconnu » (clé i18n FR/EN, `\uXXXX`), et une notification d'avertissement le dit au moment de la génération.
- Seule `nemeton_erreur_cvat_codage` déclenche la reprise ; toute autre erreur garde le comportement actuel (échec affiché).
- Compatible avec le nemeton installé aujourd'hui (2026.11.45, qui n'émet pas cette classe) : rien ne change tant que le cœur ne la lève pas.

## Les sources à lire avant d'agir

- `CLAUDE.md` de nemetonshiny ; `R/service_inventaire_video.R` (génération, `video_args_generation()`, `video_cvat_plan()`), `R/mod_inventaire_video.R` (tâche de génération, ligne d'état CVAT `cvat_info`), leurs tests ; dans nemeton, en lecture seule, la PR #699 : `/home/user/wt-051/R/inventaire_video.R` (`.iv_cvat_lire()`, classe d'erreur).

## Cas limites (un test par cas, qui échoue sans le changement ; sans réseau ; le cœur est simulé par `local_mocked_bindings`)

1. Le cœur lève `nemeton_erreur_cvat_codage` au premier appel : un second appel part **sans** `cvat_path`, le projet est rendu, l'avertissement est émis.
2. Le cœur lève une autre erreur : pas de second appel, l'erreur remonte comme aujourd'hui.
3. Pas d'erreur : un seul appel, avec `cvat_path` (comportement inchangé).
4. Le second appel échoue aussi : l'erreur du second appel remonte (pas de boucle).
5. Ligne d'état : après un refus de codage, elle dit « absent — codage du fichier non reconnu ».

## Ce qui est attendu

1. Le code (service pour la reprise, module pour l'affichage), les tests, la clé i18n.
2. `Rscript -e 'devtools::test(filter = "inventaire_video|i18n|static_assets", stop_on_failure = TRUE)'` ; `.claude/test-command` (échecs connus du conteneur : `llm_prompts`, `action_plan_prompts`, `mod_synthesis`, identiques sur main — à vérifier).
3. DESCRIPTION au cycle dev suivant (`.9004`), entrée NEWS en développement.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), dans un worktree de nemetonshiny. Relu par le `relecteur`.
- **Moyens :** budget 2 $.
- **Ce qui ne lui est pas demandé :** toucher nemeton ; release ; ouvrir ou fusionner la PR.
- **Dépend de / rouge attendu jusqu'à :** rien (le cœur est simulé dans les tests).
