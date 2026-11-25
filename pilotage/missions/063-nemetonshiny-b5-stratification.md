# Mission 063 — nemetonshiny-b5-stratification

> Ouverte le 2026-11-25 au cycle 18, sous la consigne de Pascal de continuer les briefs restants (« il n'y a plus de brief à coder ? »). Origine : brief `nemeton/specs/067-forpt-lidar-latent/brief-nemetonshiny.md` (écart n° 26 de `nemeton/PLAN.md`) ; cœur livré en 2026.11.5 (B5), le plancher de l'app (`nemeton >= 2026.11.44`) suffit.
> Dépôt : `nemetonshiny`, branche imposée `ccr-b52c1910-gjp34w`, partie d'`origin/main` **après** la fusion de la PR #334. **Pas de release.**

## Mission

**En une phrase (quoi, et pourquoi) :** Calculer et montrer l'indicateur B5 (stratification verticale) dans nemetonshiny quand le projet a un nuage LiDAR — nuage passé au calcul, quatre statuts traduits, couche B5 sur la carte, profil vertical par strates et densité de points dans la fiche de l'UGF — pour que le forestier voie la structure verticale de ses peuplements que le cœur sait déjà calculer.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Ce que dit le brief (fait foi)

1. B5 (famille B, conditionnel, source `lidar`) : colonnes `B5` (0-100) et `b5_status` ∈ `calculated`, `skipped_no_lidar`, `skipped_no_coverage`, `skipped_low_density`. Libellés, infobulle, `doc_url`, sens : lus de `nemeton::indicator_labels()` / `indicator_families()` — aucune table à dupliquer.
2. Profil vertical `b5_s1`…`b5_s5` (parts des strates 0,5-2, 2-5, 5-10, 10-20, > 20 m, somme 1) : petit histogramme horizontal dans la fiche de l'UGF ; `b5_densite` (retours/m²) à côté, avec l'avertissement « sous ~10 retours/m², les sous-étages des peuplements fermés sont sous-estimés ».
3. Activation : passer `nuage =` au calcul (dossier `<projet>/cache/layers/lidar_nuage`, `normaliser = TRUE` pour les dalles brutes IGN ; lidR requis). Sans nuage : B5 `NA`, famille B inchangée.
4. Pas de palier `INDICATOR_SENSE_VERSION`.

**Hors mission** (même brief, « plus tard ») : badge de dimensionnement drone (`simulate_density_sensitivity()`), `t1_source`.

## Les sources à lire

- `nemetonshiny/CLAUDE.md` en entier (i18n `\uXXXX`, clés NMT ≤ 30 car., pas de logique métier dans `mod_*`, services, couleurs, cycle dev `.900x`, NEWS ; **ne pas toucher `nemeton`**).
- Comment l'app branche aujourd'hui les indicateurs conditionnels et leurs statuts : `R/service_compute.R` (`compute_single_indicator()` l. ~5234, chemin `lidar_nuage` l. ~2318-2342), le précédent T4 (`t4_status`, mission 029 de nemetonshiny ; `R/service_production_ifn.R:54`), la fiche UGF (`R/mod_ug.R` ou équivalent), la carte des indicateurs, `R/utils_i18n.R`.
- Côté cœur, en lecture seule : `nemeton/R/indicateur_b5_stratification.R` (signature exacte, colonnes rendues), `nemeton_compute()`.

## Cas limites (un test par cas, sans réseau ; lidR simulé ou sauté s'il manque, sauts comptés)

1. Projet sans `lidar_nuage` : aucun `nuage =` passé, B5 absent/`NA`, aucune erreur, famille B inchangée.
2. Projet avec nuage (fichiers factices + fonction cœur simulée par `local_mocked_bindings(.package = "nemeton")`) : le chemin du dossier et `normaliser = TRUE` arrivent au cœur.
3. Les quatre statuts ont une traduction FR et EN, sans littéral dans l'UI (le test i18n existant reste vert).
4. Fiche UGF : histogramme des cinq strates (parts somme 1) et densité ; sous 10 retours/m², l'avertissement s'affiche ; avec `b5_status` ≠ `calculated`, le statut traduit remplace l'histogramme.
5. Carte : la couche B5 existe quand la colonne existe, et seulement alors.

## Ce qui est attendu

1. Code réparti services / modules selon `CLAUDE.md`, tests ci-dessus.
2. `.claude/test-command` de nemetonshiny s'il existe, sinon `devtools::test(filter = "<fichiers touchés>|i18n", stop_on_failure = TRUE)` ; sha, commande, code, durée, réussis/échoués/sautés.
3. Cycle dev suivant dans `DESCRIPTION`, entrée NEWS. Ne pas toucher `nemeton/PLAN.md`.
4. Corriger au passage l'entrée NEWS des planchers (PR #334, mineurs du `relecteur`) : le test vérifie que **le plancher déclaré est au moins celui qui introduit** `ExtendedTask` / `input_task_button` / `bind_task_button` (pas « que chaque fonction existe »), et le compte exact d'appels bslib (recompter, ou ne pas donner de chiffre).
5. Commit sur `ccr-b52c1910-gjp34w`, push. L'orchestrateur ouvre la PR.

## L'Homme

- **Agent :** `dev`, worktree de nemetonshiny. Relu par le `relecteur`.
- **Moyens :** budget 5 $.
- **Ce qui ne lui est pas demandé :** toucher nemeton ; badge drone ; release ; PR.
- **Dépend de / rouge attendu jusqu'à :** fusion de nemetonshiny #334 (branche de session).
