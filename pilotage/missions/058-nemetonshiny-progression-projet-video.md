# Mission 058 — nemetonshiny-progression-projet-video

> Ouverte le 2026-11-25 au cycle 18, sous la délégation de Pascal du jour. Origine : sa question « Est-ce que cette construction est dans un espace dédié … pour qu'il ne bloque pas l'application » et le constat du journal (génération déjà hors de la session Shiny, mais aucune progression à l'écran) ; la mission 056 (nemeton #700) ajoute à `creer_projet_inventaire_video()` un `progress_callback(list(etape, i, n, secondes))` aux étapes stables `sources`, `placettes`, `dalles_mnt`, `houppiers`, `cvat`, `geopackage`, `qgz`.
> Dépôt : `nemetonshiny`, depuis la session cloud (branche `ccr-b52c1910-gjp34w`, repartie de `origin/main` 2738d03). Fusion par l'orchestrateur à la CI verte (délégation de Pascal du 2026-11-25). Pas de release.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire afficher par la vue Inventaire vidéo l'étape en cours de la création du projet QField (nom, compteur, temps écoulé), relayée depuis le worker par le rappel de progression du cœur, pour que le forestier voie où en est un calcul de plusieurs minutes au lieu d'un écran muet.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Choix de l'orchestrateur (délégation)

1. **Relais depuis le worker** : reprendre le patron déjà en place dans l'app pour les tâches longues avec progression (chercher `progress_callback` dans `R/service_*.R` et `R/mod_*.R` : fichier de progression partagé, `ipc`, ou équivalent existant). Ne pas inventer un nouveau mécanisme s'il en existe un.
2. **Compatibilité** : l'app passe `progress_callback` au cœur **seulement si** `creer_projet_inventaire_video` l'accepte (`"progress_callback" %in% names(formals(...))`) ; avec le nemeton installé aujourd'hui (sans 056), rien ne change, la génération marche comme avant.
3. **Affichage** : une ligne sous le bouton « Générer » (ou la notification de progression existante de l'app, `mod_progress`), libellés i18n FR/EN des 7 étapes (`\uXXXX`, clés ≤ 30 caractères), compteur `i/n` pour `placettes`, `dalles_mnt`, `houppiers`, temps écoulé total. Le `i = 0` ré-émis au repli séquentiel des houppiers fait simplement repartir le compteur.
4. **File d'attente visible** : si la tâche de génération attend un worker occupé (par ex. le calcul du CVAT), la ligne le dit (« en attente d'un processus libre ») tant qu'aucune progression n'est arrivée.

## Les sources à lire avant d'agir

- `CLAUDE.md` de nemetonshiny ; `R/mod_inventaire_video.R` (tâche `tache`, l. ~416), `R/service_inventaire_video.R` (`video_creer_projet()`), `R/mod_progress.R`, les modules qui relaient déjà une progression depuis un worker (`mod_regeneration.R`, `mod_monitoring.R`, `service_compute.R`) ; dans nemeton, en lecture seule, le contrat de la 056 : `/home/user/wt-056/R/inventaire_video.R` (roxygen de `progress_callback`).

## Cas limites (un test par cas, qui échoue sans le changement ; cœur simulé)

1. Cœur qui accepte `progress_callback` : les événements simulés (sources, placettes 0..3/3, houppiers 0..4/4, qgz) arrivent jusqu'au module et la ligne affiche l'étape et le compteur.
2. Cœur sans `progress_callback` (nemeton actuel) : aucun argument en trop passé, génération inchangée.
3. Un rappel qui échoue côté app (fichier de progression illisible) ne fait pas échouer la génération.
4. En attente : tâche lancée, aucune progression reçue → « en attente d'un processus libre ».
5. i18n : clés FR/EN présentes, aucun littéral.

## Ce qui est attendu

1. Code (service pour le relais, module pour l'affichage), tests, contre-épreuve.
2. `Rscript -e 'devtools::test(filter = "inventaire_video|i18n|static_assets", stop_on_failure = TRUE)'`.
3. DESCRIPTION au cycle dev suivant (`.9005`), entrée NEWS en développement.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), dans un worktree de nemetonshiny. Relu par le `relecteur`.
- **Moyens :** budget 3 $.
- **Ce qui ne lui est pas demandé :** toucher nemeton ; release ; PR ; fusion.
- **Dépend de / rouge attendu jusqu'à :** rien (cœur simulé) ; l'effet réel arrive avec la fusion de nemeton #700.
