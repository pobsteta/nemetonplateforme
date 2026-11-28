# ADR 0003 — un noyau Rust dans nemeton, ouvert par le spike de ré-entraînement RECONFORT

- **Date :** 2026-11-25
- **Statut :** acceptée par Pascal le 2026-11-25 (réponses aux questions de l'orchestrateur, journal du jour)
- **Proposée par :** Claude (orchestrateur de nemetonplateforme)
- **Tranchée par :** Pascal

## La décision en une phrase

nemeton reçoit un crate Rust (`src/rust/`, liaison `extendr`, comme foretaccess) qui calcule
d'abord les indices CRswir et CRre de RECONFORT par pixel ; le paquet reste installable et
utilisable **sans Rust**, par un repli en R pur aux résultats identiques.

## Contexte

- Pascal rouvre, en spike, le ré-entraînement d'un Random Forest RECONFORT propre à Néméton,
  que la spec 021 de nemeton (§ 1.4) laissait hors périmètre ; il veut le calcul en Rust dès
  le spike (journal, 2026-11-25, « RECONFORT · décisions »).
- La chaîne amont (framagit fl.mouret/reconfort, Apache-2.0) passe par iota2 et un
  environnement conda : c'est le point fragile de la spec 021. Les formules des deux indices
  sont publiques (`iota2/external_features/custom_index.py`).
- nemeton n'a aucun code compilé en Rust aujourd'hui ; le portage RVT en Rust y est prévu
  (`nemeton/PLAN.md`, v1.18). foretaccess a déjà un crate `extendr`.

## Options

| | Option | Pour | Contre |
|---|---|---|---|
| A | crate dans nemeton | un seul paquet ; accueille RVT plus tard | cargo/rustc en CI et sur les postes |
| B | paquet R séparé | nemeton intact | un dépôt de plus à tenir |
| C | dans foretaccess | aucune chaîne nouvelle | mélange accessibilité et santé |

**Retenue : A**, avec repli R pur.

## Conséquences

- La CI de nemeton installe la chaîne Rust ; `R CMD check` passe avec et sans Rust.
- Toute fonction Rust a un test `cargo test` et un test R qui compare au repli R.
- `SystemRequirements: Cargo (Rust's package manager), rustc` est déclaré ; l'absence de
  Rust n'empêche pas l'installation (repli).
- Licence : le crate suit la GPL-3 de nemeton ; les formules reprises de RECONFORT
  (Apache-2.0) sont citées.

## Test du successeur

Un successeur sans Rust installe nemeton, obtient les mêmes indices (repli R), et lit dans
cet ADR pourquoi le crate existe.
