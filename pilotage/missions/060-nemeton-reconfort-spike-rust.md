# Mission 060 — nemeton-reconfort-spike-rust

> Ouverte le 2026-11-25 au cycle 18, sur les décisions de Pascal (journal, lignes « Pascal · RECONFORT · décisions » et réponses aux préalables du même jour) : ré-entraînement RECONFORT en **spike**, étiquettes **terrain + propagation**, **Rust dès le spike**, en attendant le terrain **le modèle amont sert de référence**, crate **dans nemeton** ([ADR 0003](../../docs/adr/0003-noyau-rust-dans-nemeton.md)).
> Dépôt : `nemeton`, branche imposée `ccr-b52c1910-gjp34w`, partie d'`origin/main`. **Pas de release**, pas de changement de la production RECONFORT (spec 021).

## Mission

**En une phrase (quoi, et pourquoi) :** Poser dans nemeton un crate Rust (extendr) qui calcule CRswir et CRre par pixel avec un repli R identique, et un pipeline d'apprentissage RECONFORT (étiquettes au format amont propagées de Y-2 à Y+2, masques chênaie et coupes rases, Random Forest `ranger`, validation croisée spatiale), testé sur placettes `synth_`, pour que les vraies notes DEPERIS se branchent ensuite sans refaire le code.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les faits (vérifiés par l'orchestrateur)

- Formules amont (`framagit.org/fl.mouret/reconfort`, `iota2/external_features/custom_index.py`, Apache-2.0) :
  - CRswir = B11 / (B8A + (1610 − 865) × (B12 − B8A) / (2190 − 865)) ;
  - CRre = B5 / (B4 + (704 − 665) × (B6 − B4) / (741 − 665)) ;
  - dénominateur nul remplacé par 1.
- Série : une image tous les 10 jours, du 1er janvier Y1 au 31 décembre Y2 (README amont).
- Format d'étiquettes de `train_new_model/` : `dep_cor` (1 sain, 2 dépérissant, 3 très dépérissant ; jamais 0), `DEPERIS_pe` (part de D+ dans [0, 1]), `id_unique`, `date` (année du relevé).
- Classes (page Sycomore) : saine < 20 % de D+, dépérissante 20-50 %, très dépérissante > 50 %. Propagation : saine en Y ⇒ saine en Y-1 et Y-2 ; dépérissante en Y ⇒ dépérissante en Y+1 et Y+2.
- Aucune placette DEPERIS publique : le spike tourne sur des jeux `synth_` (préfixe et `synthetic = TRUE`).
- nemeton a `ranger` en Imports ; pas de `src/` Rust aujourd'hui. foretaccess sert de modèle (`src/rust/`, `extendr`, `cargo test`). Conteneur : cargo 1.97, rustc ; `rextendr` absent (l'installer si nécessaire, ou écrire les wrappers à la main comme le fait le modèle de foretaccess).

## Ce qui est attendu

1. `src/rust/` (crate `nemeton`, extendr) : `cr_swir()` et `cr_re()` vectorisés sur des bandes en `f64`, NA propagés, dénominateur nul → 1. `cargo test` avec des valeurs écrites à la main.
2. R : `reconfort_indices(bands)` (bandes en `SpatRaster` ou matrice) qui appelle Rust s'il est compilé, sinon le repli R ; option `nemeton.rust = FALSE` pour forcer le repli. Test : Rust et repli R égaux à 1e-12 près sur des valeurs aléatoires et sur les cas limites.
3. R : `reconfort_etiquettes(placettes)` : contrôle du format amont (refus de `dep_cor = 0`, de `DEPERIS_pe` hors [0, 1], d'un `id_unique` en double la même année), classes recalculées depuis `DEPERIS_pe` (seuils 0,20 et 0,50), propagation Y-2..Y+2 sans écraser une vraie observation, conflit signalé et non tranché en silence.
4. R : masques — retrait des pixels hors chênaie (couche fournie, BD Forêt v2 en pratique) et des coupes rases (raster ou polygones au format nemetonsar/SUFOSAT, dates `YYDDD`) **après** l'année de coupe.
5. R : `reconfort_entrainer()` : `ranger` sur les séries CRswir/CRre ; validation croisée **spatiale par blocs** (aucune placette d'un bloc dans l'apprentissage de ce bloc) ; rendu : modèle, matrice de confusion, précision globale, seed fixée.
6. R : `reconfort_comparer_amont()` : accord pixel à pixel avec une carte de classes fournie (celle du modèle v3 amont en pratique) ; sur fichiers `synth_` dans les tests.
7. Un document `specs/070-reconfort-reentrainement-spike/spec.md` court : ce que fait le spike, ce qui manque (notes DEPERIS réelles), critère pour amender la spec 021 (au moins l'accord du modèle amont sur des placettes de terrain tenues à l'écart).
8. CI : la chaîne Rust installée dans les workflows qui construisent le paquet ; `R CMD check` vert. `SystemRequirements` déclaré ; installation sans cargo possible (repli). Configure (`configure`/`Makevars`) qui saute la compilation proprement si cargo manque.
9. Tests sans réseau, entrées `synth_` dans `tests/testthat/` ou `inst/extdata/`. NEWS (développement), `PLAN.md` (entrée datée). `DESCRIPTION` reste en `2026.11.45.9000`.

## Cas limites (un test par cas)

1. Rust = repli R (aléatoire + dénominateur nul + NA).
2. `dep_cor = 0` refusé ; `DEPERIS_pe = 1.2` refusé.
3. Saine 2022 ⇒ lignes 2020 et 2021 saines ; dépérissante 2022 ⇒ 2023 et 2024 ; observation réelle 2021 « dépérissante » non écrasée par une propagation « saine » (conflit listé).
4. Pixel coupé en 2021 (`21150`) gardé en 2020, retiré en 2021 et après.
5. Validation croisée : aucun `id_unique` dans l'apprentissage et le test d'un même pli.
6. Sans cargo (`nemeton.rust = FALSE`) : mêmes sorties.

## Commandes de preuve

- `cargo test --manifest-path src/rust/Cargo.toml`
- `Rscript -e 'devtools::test(filter = "reconfort", stop_on_failure = TRUE)'` (avec `LANG=C.UTF-8 LC_ALL=C.UTF-8`)
- `R CMD build` + `R CMD check --no-manual` sur le paquet construit (ou `devtools::check()`), au moins jusqu'à l'installation et aux tests `reconfort`.
Pour chacun : sha, commande, code de sortie, durée, nombre de tests réussis, échoués, sautés.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), worktree de nemeton. Relu par le `relecteur`.
- **Moyens :** budget 5 $.
- **Ce qui ne lui est pas demandé :** toucher la production RECONFORT (`R/reconfort_ingest.R`, `R/reconfort_postprocess.R`, R5) ; télécharger Sentinel-2 ; release ; ouvrir la PR ; autre dépôt.
- **Dépend de / rouge attendu jusqu'à :** rien.
