# Mission 059 — nemeton-projet-video-parallele-suite

> Ouverte le 2026-11-25 au cycle 18, sous la délégation de Pascal du jour. Origine : la mission 056 (nemeton #700, fusionnée f685248) a divisé le temps des houppiers mais pas le total par deux : sur 441 ha synthétiques, 74,2 s → 54,7 s ; ~20 s restent séquentiels (boucle des 62 placettes ~7-8 s, dalles MNT ~5 s, `.qgz` ~8 s) et ~6 s de chargement des workers en dev (journal du 2026-11-25, `dev · 056`).
> Dépôt : `nemeton`, depuis la session cloud (branche `ccr-b52c1910-gjp34w`, repartie de `origin/main` f685248). Fusion par l'orchestrateur à la CI verte. Pas de release.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire tourner aussi en parallèle, sur le même cluster que les houppiers, la découpe des placettes et l'écriture des dalles MNT de `creer_projet_inventaire_video()`, et réutiliser ce cluster une seule fois pour toute la création, pour approcher la division par deux du temps total visée par la 056.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Choix de l'orchestrateur (délégation)

1. **Un seul cluster PSOCK par création** (créé une fois, initialisé une fois par `.iv_cluster_init()`, partagé par les placettes, les dalles MNT et les houppiers, fermé par `on.exit`) : le coût de chargement des workers n'est payé qu'une fois.
2. **Placettes en parallèle** : découpe MNT/MNH, écriture des tif et topographie par lots de placettes ; les workers relisent les rasters par leur chemin (même règle que la 056 : séquentiel si le raster n'est pas un fichier relisible). Résultat **identique** (mêmes fichiers, mêmes valeurs, mêmes attributs `topo`, même ordre).
3. **Dalles MNT en parallèle**, même principe.
4. **`.qgz` hors mission** : un zip ne se parallélise pas simplement ; le laisser tel quel.
5. **Progression** inchangée dans ses noms et son contrat (étapes `placettes` et `dalles_mnt`, compteur par lot comme pour `houppiers`).
6. Contenu produit et schéma 1.7.0 inchangés.

## Cas limites (un test par cas, qui échoue sans le changement ; sans réseau ; données synthétiques)

1. Placettes en parallèle (`n_workers = 2`) : fichiers tif et attributs topographiques identiques au séquentiel.
2. Dalles MNT en parallèle : fichiers identiques.
3. Un seul cluster créé par appel (compter les appels à `makePSOCKcluster` ou à l'init) quand placettes, dalles et houppiers tournent.
4. Raster en mémoire : séquentiel, sans erreur.
5. Progression : étapes et compteurs conformes au contrat, finissant à `i == n`.
6. Mesure (hors CI, dans le rendu) : scénario B (441 ha, scripts `/tmp/claude-0/-home-user/4ded9d2a-b1a5-536b-b61c-a2885923659c/scratchpad/chrono/`), avant (f685248) et après, `n_workers = 3`, avec le paquet **installé** dans une bibliothèque jetable (pas `load_all`), pour ne pas compter le chargement de dev.

## Ce qui est attendu

1. Code, `.Rd` à la main, tests, contre-épreuve sur `origin/main`.
2. `Rscript -e 'devtools::test(filter = "inventaire-video|houppiers")'` (échecs préexistants connus du conteneur : `test-houppiers.R` et `test-inventaire-video-foret.R` sur silva/watershed) et `.claude/test-command` (8 échecs connus, terra 1.7).
3. NEWS en développement, PLAN.md daté ; DESCRIPTION reste `2026.11.45.9000`.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), dans un worktree de nemeton. Relu par le `relecteur`.
- **Moyens :** budget 3 $.
- **Ce qui ne lui est pas demandé :** le `.qgz` ; release ; PR ; fusion.
- **Dépend de / rouge attendu jusqu'à :** rien (056 fusionnée).
