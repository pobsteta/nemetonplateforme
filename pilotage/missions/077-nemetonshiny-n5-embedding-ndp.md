# Mission 077 — nemetonshiny-n5-embedding-ndp

> Ouverte le 2026-11-26 sur la demande de Pascal « continue le dev des briefs restants ». Ferme les écarts n° 20, 21 et 22 du `PLAN.md` de nemeton (ouverts le 2026-11-05), préavis `nemeton/specs/064-alphaearth-n5/brief-nemetonshiny.md` (lecture seule). Cœur livré en **2026.11.1** (vérifier que les fonctions sont dans un tag de release et que le plancher `Imports: nemeton` de l'app le couvre).
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, partie d'`origin/main` (721215c ou plus récent). Pas de release.

## Mission

**En une phrase :** Faire que l'app affiche et traite correctement les sorties « modèles de fondation » du cœur : l'indicateur N5 (statuts traduits et couche sur la carte), la méthode de B4/L3 (`biodivmapr` ou `embedding`) affichée à côté de la valeur et transmise à la normalisation, et le flag NDP `embedding_ml` dans le badge, pour qu'aucune de ces valeurs ne soit mal notée ni mal lue.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu (écart par écart, lire le brief du cœur et le code du cœur en lecture seule)

1. **Écart 20 — N5.** Les cinq statuts `n5_status` (`calculated`, `skipped_no_embedding`, `skipped_no_reference`, `skipped_reference_too_small`, `skipped_no_coverage`) traduits (même mécanisme que `r5_status`, bandeau `indicator_na_banner()` ou équivalent) ; N5 visible sur la carte de la famille N comme les autres indicateurs (libellés et sens lus de `nemeton::indicator_labels()` / `indicator_families()` — aucune table recopiée).
2. **Écart 21 — B4/L3 embedding.** Lire `b4_methode` / `l3_methode` ; passer le statut `calculated_embedding` à `nemeton::normalize_indicator(statut =)` comme pour P2 (écart n° 17 : retrouver le code existant et le suivre) ; afficher la méthode à côté de la valeur dans la fiche de l'UGF et la vue famille ; l'interdit de comparaison entre projets (écart n° 6) ne tombe que pour `embedding` — vérifier où il s'applique dans l'app et ne le lever que pour cette méthode.
3. **Écart 22 — NDP.** Le badge NDP (`R/ndp.R`) reconnaît `embedding_ml` dans `detect_ndp()$augmented`, au même titre que `height_ml` (libellé i18n, infobulle).
4. **Recalcul** : quand un projet reçoit un embedding (la famille N gagne un indicateur), un message à l'utilisateur le dit (i18n).

## Cas limites (tests, cœur simulé ou jeux légers)

1. Chaque statut N5 a sa traduction FR/EN ; un statut inconnu ressort tel quel.
2. B4 en `embedding` : `normalize_indicator` reçoit `statut = "calculated_embedding"` ; en `biodivmapr` : comme avant.
3. La fiche affiche la méthode ; sans méthode (NA) : rien d'inventé.
4. `detect_ndp()$augmented` contenant `embedding_ml` → badge avec le libellé ; sans : inchangé.
5. Comparaison entre projets : autorisée seulement si la méthode est `embedding` des deux côtés (ou selon la règle exacte du brief, à citer).

## Ce qui est attendu

Code, tests, i18n `\uXXXX`, contrôle non ASCII, tests des fichiers R touchés (lents compris), `.claude/test-command`, contre-épreuve sans `git stash` nu, cycle dev, NEWS ; commit et push ; sha relevé par `git rev-parse HEAD`. Brief définitif côté cœur : non demandé (l'app ne modifie pas nemeton). L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 4 $. Dépend de : rien.
