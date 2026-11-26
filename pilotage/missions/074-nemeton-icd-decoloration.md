# Mission 074 — nemeton-icd-decoloration

> Ouverte le 2026-11-26 sur la décision de Pascal du même jour (onglet ICD après RECONFORT, comparaison avec FAST, poids modifiables) et ses quatre réponses (somme des poids renormalisée à 1 ; seuls les poids modifiables ; pas d'ICD hors des 4 peuplements purs ; ICD dans « Tout calculer »).
> Dépôt : `nemeton`, branche `ccr-b52c1910-gjp34w`, partie d'`origin/main` (ca1a252 ou plus récent, après fusion de #705). Pas de release.

## Mission

**En une phrase :** Écrire la spec `specs/071-icd-decoloration/` puis implémenter dans le cœur le calcul de l'indicateur composite de décoloration (ICD) par zone de suivi — indices, composites mensuels, anomalies, ICD aux poids modifiables, alertes et niveaux, série d'un pixel, comparaison avec FAST — selon la note de méthode de Pascal, pour que l'app puisse ensuite ouvrir son onglet ICD.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Ce qui fait foi

1. **Le brief** `nemetonplateforme/pilotage/briefs/brief-nemeton-icd-decoloration.md` : lire en entier, tout ce qui y est écrit est attendu (§§ 1 à 7, tests, décisions de Pascal).
2. **La note de méthode** : `/root/.claude/uploads/4ded9d2a-b1a5-536b-b61c-a2885923659c/38165fff-methode_suivi_decoloration_bfc.pdf` (« Suivi de la décoloration anormale du feuillage », v2 du 29 octobre 2026), §§ 3 à 8 et 15. La copier dans `specs/071-icd-decoloration/methode_suivi_decoloration_bfc.pdf`.
3. Le brief côté app (`brief-nemetonshiny-icd-decoloration.md`) : à copier dans `specs/071-icd-decoloration/brief-nemetonshiny.md` (copie de référence, convention du dépôt) ; il dit ce que l'app attendra du cœur (série d'un pixel, événements `icd:*` dont `icd:cancelled`, comparaison FAST, poids renormalisés rendus).

## Découpage conseillé (une PR)

spec → indices et masque SCL (réutiliser `reconfort_indices()` pour CRSWIR/CRre, `.s2_boa_offset()`, le cache et le lecteur fenêtré de FAST, bandes ajoutées à l'union sans changer ce que lit FAST) → composite mensuel → anomalie z → ICD (`icd_poids_defaut()`, poids validés, renormalisés à 1 par essence et dits) → classes et niveaux 0-4, indice à date (reprendre `niveaux_decoloration()` de `data-raw/etude_fast_decoloration/`) → rasters par zone, masque UGF, alertes `icd_decoloration` → série d'un pixel → `comparer_fast_icd()` (reprendre `classes_fast()` de l'étude) → événements de progression et annulation coopérative (`cancel_path`, sondé par scène et par mois).

## Ce qui est attendu

Code, tests sans réseau (liste du brief), spec, copies de référence ; nouvelles fonctions exportées dans `_pkgdown.yml` et testées ; aucun caractère non ASCII dans le code R hors commentaires (`\uXXXX`) ; `system.file()` pour `inst/` ; FAST inchangé (ses tests verts sans modification) ; tests ciblés (`icd|decoloration|sentinel2|reconfort_indices|fast`) puis la suite complète, en distinguant les échecs préexistants d'environnement (rejouer sur `origin/main`) ; contre-épreuve ; `DESCRIPTION` cycle dev suivant, NEWS, `PLAN.md` ; commit et push. L'orchestrateur ouvre la PR. Mesure réelle seulement si le réseau STAC répond depuis la session (sinon : dit).

## L'Homme

- **Agent :** `dev`, worktree de nemeton ; relu par le `relecteur`.
- **Moyens :** budget 8 $ (mission plus large que les autres).
- **Ce qui ne lui est pas demandé :** l'onglet de l'app ; les §§ 9 à 14 de la note (coupes, volumes, risque, IFN, indicateurs régionaux) ; modifier FAST ; release ; PR.
- **Dépend de :** #705 fusionnée (fait, ca1a252).
