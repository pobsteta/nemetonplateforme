# Mission 088 — nemetonshiny-onglet-icd

> Planifiée le 2026-11-27, lancée le même jour après la fusion de la release du cœur (PR nemeton #710, 2b3dd8d ; tag `v2026.11.46` posé par `release.yml` après la CI de `main`). Brief : `pilotage/briefs/brief-nemetonshiny-icd-decoloration.md` (décisions de Pascal du 2026-11-26 : FAST inchangé ; onglet ICD après RECONFORT, graphiques au clic ; poids modifiables dans Sources & paramètres, somme renormalisée à 1, seuls les poids ; pas d'ICD hors des 4 peuplements purs ; ICD dans « Tout calculer » ; comparaison avec FAST).
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, partie de `origin/main`. Pas de release.

## Mission

**En une phrase :** Réaliser dans l'app tout le brief ICD (onglet ICD après RECONFORT avec calcul asynchrone et carte, graphiques des cinq indices et de l'ICD au clic, comparaison avec FAST, poids dans Sources & paramètres, étape `sante_icd` de « Tout calculer »), en appelant uniquement les fonctions exportées du cœur 2026.11.46.

**Redite par l'agent :** _à compléter avant d'agir._

## Sources (lecture seule)

- Brief app ci-dessus (contrat complet, sections 1 à 5 et règles) et brief cœur `pilotage/briefs/brief-nemeton-icd-decoloration.md`.
- API du cœur (nemeton `origin/main`, 2026.11.46) : `run_icd_decoloration()`, `icd_indices()`, `icd_poids_defaut()`, `icd_poids_valider()`, `read_icd_raster()`, `read_icd_pixel_series()`, `comparer_fast_icd()` ; leur documentation (`man/`) et la spec `specs/071-icd-decoloration/`.
- Modèles dans l'app : onglets FAST/FORDEAD/RECONFORT de `R/mod_monitoring.R`, modales plotly des cartes pixel, nettoyage centralisé des notifications (missions 072 et 075), `mod_sources_config.R` (paramètres ONF, AlphaEarth), `service_pipeline.R`, messages d'erreur lisibles (mission 090).

## Attendu

Le brief en entier, plus : `Imports: nemeton (>= 2026.11.46)` (l'app consomme une nouvelle API du cœur) ; tests `testServer` listés au brief avec le cœur simulé (`local_mocked_bindings(..., .package = "nemeton")`) ; un test d'intégration avec le vrai cœur sur un petit jeu fabriqué si faisable sans réseau ; i18n complète ; cycle dev, NEWS ; captures de l'onglet et de la modale si l'app démarre dans le conteneur (sinon le dire).

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 5 $.
