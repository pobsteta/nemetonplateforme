# Mission 056 — nemeton-projet-video-rapide-et-suivi

> Ouverte le 2026-11-25 au cycle 18, sur la demande de Pascal (« Chronomètre les temps nécessaires à la construction du projet » ; « ça a l'air de prendre un temps de fou » sur la Colombière), sous sa délégation du jour. Origine : chronométrage synthétique du journal (2026-11-25, `analyste · inventaire vidéo`) : la segmentation des houppiers domine (~12 s par km², un seul cœur), puis la boucle des placettes (~9 s fixes) et le `.qgz` (7 à 11 s) ; aucune progression par étape n'est émise.
> Dépôt : `nemeton`, depuis la session cloud (branche `ccr-b52c1910-gjp34w`, repartie de `origin/main` ae887f6). Fusion par l'orchestrateur à la CI verte (délégation de Pascal du 2026-11-25). Pas de release.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire que `creer_projet_inventaire_video()` segmente les houppiers en parallèle, ouvre ses rasters une seule fois, et annonce chaque étape avec sa durée par un rappel de progression, pour que la création du projet QField d'une grande forêt prenne deux fois moins de temps et que l'app puisse dire où elle en est.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Choix de l'orchestrateur (délégation)

1. **Parallèle par dalle** dans `.iv_houppiers_emprise()` : un cluster PSOCK (`parallel::makePSOCKcluster` ou `future` si nemeton l'utilise déjà ailleurs ; **jamais `mclapply`/fork**, qui bloque avec terra), chaque worker relit le MNH **par son chemin**. Argument `n_workers` (défaut : `getOption("nemeton.iv_workers", min(4, parallel::detectCores() - 1))`, 1 = séquentiel exact d'aujourd'hui). Si le MNH n'est pas un fichier (SpatRaster en mémoire), séquentiel. Le **résultat est identique** à l'ordre près des lignes, puis trié comme aujourd'hui (`h_max` décroissant, `houppier_id`).
2. **Rasters ouverts une fois** dans la boucle des placettes (MNT et MNH lus une fois avant la boucle, découpe par placette ensuite).
3. **Progression** : argument `progress_callback = NULL` ; à chaque étape (sources, placettes avec compteur i/n, dalles MNT, houppiers avec compteur de dalles, CVAT, GeoPackage, `.qgz`), un appel `progress_callback(list(etape =, i =, n =, secondes =))`, jamais fatal (`tryCatch`), comme le patron `emit` de `regen_sensibilite()`. Noms d'étapes stables (contrat pour nemetonshiny, documentés en roxygen).
4. **`.qgz`** : rasters déjà compressés (DEFLATE) stockés sans recompression dans le zip si la fonction d'empaquetage le permet simplement ; sinon, ne rien changer et le dire.
5. Aucun changement du schéma 1.7.0 ni du contenu produit (on ne segmente pas moins de forêt : ce serait une question de périmètre pour Pascal).

## Cas limites (un test par cas, qui échoue sans le changement ; sans réseau ; données synthétiques)

1. Houppiers en parallèle (`n_workers = 2`) **identiques** au séquentiel (`n_workers = 1`) sur un MNH synthétique de 2 × 2 dalles écrit sur disque.
2. MNH en mémoire (non fichier) : séquentiel, sans erreur.
3. `progress_callback` reçoit les étapes dans l'ordre, avec des `secondes` numériques ≥ 0 et le compteur de placettes qui finit à n ; un callback qui lève une erreur ne casse pas la création.
4. Boucle des placettes : mêmes rasters par placette qu'avant (comparaison des valeurs).
5. `.qgz` identique en contenu (liste et contenu des fichiers) à celui d'avant.
6. Mesure (hors CI, dans le rendu) : le scénario B du chronométrage (441 ha, scripts `/tmp/claude-0/-home-user/4ded9d2a-b1a5-536b-b61c-a2885923659c/scratchpad/chrono/gen.R` et `bench.R`) avant et après, avec `n_workers = 3`.

## Ce qui est attendu

1. Code, roxygen et `.Rd` (à la main si `document()` réécrit d'autres fichiers), tests, contre-épreuve.
2. `Rscript -e 'devtools::test(filter = "inventaire-video|houppiers", stop_on_failure = TRUE)'` (lidR est installé) et `.claude/test-command` (8 échecs préexistants du conteneur : terra 1.7 `flowAccumulation`, `test-indicators-frost.R:63`).
3. NEWS en développement, entrée PLAN.md datée ; DESCRIPTION reste `2026.11.45.9000`.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), dans un worktree de nemeton. Relu par le `relecteur`.
- **Moyens :** budget 3 $.
- **Ce qui ne lui est pas demandé :** l'affichage dans nemetonshiny (mission suivante, une fois les noms d'étapes publiés) ; release ; PR ; fusion.
- **Dépend de / rouge attendu jusqu'à :** rien.
