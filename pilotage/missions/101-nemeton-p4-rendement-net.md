# Mission 101 — nemeton-p4-rendement-net

> Ouverte le 2026-11-28 sur la décision de Pascal : « fais le dev de la spec 072 côté cœur ». La spec 072 (« Proposée ») est ainsi validée pour le développement.
> Source : `specs/072-p4-rendement-net-risque/spec.md` v0.2.0 de nemeton, sur la branche `origin/claude/spec-072-p4-rendement-net`, commits da000494c et f5f923d21 (documentation seule, non fusionnée). Le brief app du même dossier vient après (jalon M4) et n'est pas dans cette mission.
> Dépôt : `nemeton`, branche `ccr-b52c1910-gjp34w`, partie d'`origin/main` e7eea9076 (DESCRIPTION 2026.11.47.9000), **avec les deux commits de la spec fusionnés en premier** (`git merge --no-ff origin/claude/spec-072-p4-rendement-net`). Pas de release.

## Mission

**En une phrase :** Implémenter dans `nemeton` l'indicateur conditionnel P4 (rendement net du risque) et ses analyses, selon la spec 072, jalons M0 à M3. Cela couvre le fichier de paramètres et son validateur, `indicateur_p4_rendement_net()`, `p4_synthese_foret()`, `p4_ruine_foret()`, le branchement Pareto, `p4_selectionner_axes()`, puis le capital et le gain calculés depuis P1, P2 et les prix, et la déclaration dans `INDICATOR_FAMILIES`. Le jeu de référence du § 10 doit être reproduit exactement, et les projets existants ne doivent pas changer.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

Suivre la spec à la lettre et **jalon par jalon** (§ 12). Un commit par jalon, chacun avec ses tests verts avant de passer au suivant.

1. **M0.**
   - Lire le code de la famille P (`indicateur_p1_volume()`, `indicateur_p2_station()`), de la normalisation (`normalize_indicator()`, règles dédiées, suffixe `_norm`), de Pareto (`identify_pareto_optimal()`), d'`INDICATOR_FAMILIES` et d'`indicator-config.R`, ainsi que la manière dont un indicateur conditionnel (B4, R5, T3) est déclaré et ignoré quand sa source manque.
   - Écrire une **note d'alignement** courte : les noms de la spec qui diffèrent de l'existant et le choix fait. Elle va dans `specs/072-p4-rendement-net-risque/alignement.md`.
   - Écrire `inst/extdata/p4_parametres.yml` tel que le § 5, avec `provisoire: true`, et le validateur : erreur explicite si une vocation, un aléa ou un champ manque, ou si une valeur sort de son domaine. Le fichier doit pouvoir être surchargé par projet.
2. **M1.** `indicateur_p4_rendement_net()` avec capital et gain fournis, et toutes les colonnes du § 6.
   - Garde contre la colonne brute : refuser `R1` sans `R1_norm`.
   - Pour la sécheresse et le sanitaire, prendre `min(R3_norm, R5_norm)` quand R5 est présent.
   - `perte_saisie` remplace le calcul des pertes.
   - Les cas manquants donnent `NA` et un avertissement `cli`.
   - La règle de normalisation de `P4_norm` est dédiée et bornée.
3. **M2.** `p4_synthese_foret()` (§ 7), `p4_ruine_foret()` (§ 7 bis : quatre mesures, somme ou maximum selon la portée, plafond d'exposition, UGF concentrante), le branchement Pareto (§ 8, entrée `P4` brut) et `p4_selectionner_axes()`. Les dépendances factorielles vont en `Suggests`, avec un repli propre et la garde d'effectif.
4. **M3.**
   - Capital et gain calculés depuis `P1`, `P2` et les prix du fichier. Les prix y restent provisoires, et l'absence de prix donne `NA` avec un avertissement.
   - Drapeau `p4_signal_seulement` sous NDP 3 ; NDP hérité de l'entrée la plus faible.
   - Déclaration dans `INDICATOR_FAMILIES` et `indicator-config.R` : famille P, conditionnel, « haut = bon ».
   - **Non-régression stricte** : sans les sources de P4, `famille_production` reste identique sur `massif_demo_units`, et `list_indicators(conditionnels = FALSE)` rend toujours 31 indicateurs.
   - Mettre à jour le décompte « 44 indicateurs / 13 conditionnels » partout où il est vérifié (CLAUDE.md compris, dans ce dépôt).
5. **Jeu de référence du § 10.** Il devient une fixture et un test d'acceptation de M1 et de M2, tolérance 0,005 point. **Si un chiffre attendu de la spec ne se retrouve pas** par le calcul défini dans la spec, ne pas ajuster le test pour qu'il passe : le signaler dans le rapport, avec le calcul à la main, car c'est peut-être la spec qui se trompe.
6. Toutes les fonctions exportées sont documentées (roxygen en anglais) et testées, et listées dans `_pkgdown.yml`.
   - NEWS de développement, DESCRIPTION en `2026.11.47.9001`, PLAN.md (journal daté).
   - Pas de release.

## Hors périmètre

Le côté app (M4, `brief-nemetonshiny.md`). Les questions ouvertes du § 13 : leurs valeurs restent celles du § 5, marquées provisoires.

## L'Homme

`dev`, worktree nemeton ; relu par le `relecteur`. Budget 8 $. Si le budget est dépassé, livrer les jalons terminés, propres et testés, et dire ce qui reste.
