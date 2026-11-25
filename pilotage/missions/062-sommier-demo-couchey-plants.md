# Mission 062 — sommier-demo-couchey-plants

> Ouverte le 2026-11-25 au cycle 18, sur la question de Pascal (« il n'y a plus de brief à coder ? ») et sous sa consigne de continuer les briefs restants. Origine : brief Surculus → sommieR `surculus/pilotage/briefs/vers-sommier/2026-10-15-travaux-2-plants.md` l. 104-105 (« Démo Couchey : les 3 placettes de l'UG 35 reçoivent leurs plants pointés, contrôlés en 2023 et 2025 »), resté « Non fait » dans `sommieR/NEWS.md` (l. 72) après les missions 054 et 057.
> Dépôt : `sommieR`, branche imposée `ccr-b52c1910-gjp34w`, partie d'`origin/main`. **Pas de release.** Fusion en squash (règle de sommieR).

## Mission

**En une phrase (quoi, et pourquoi) :** Compléter `sommier_demo_couchey()` pour que les 3 placettes de la plantation 2022 de l'UG 35 reçoivent des plants pointés (`sommier_pointer_plant()`) et leurs états aux contrôles de 2023 et 2025, afin que la démo exerce tout le lot 2 « plants » (vues `v_plant`, `v_etat_plant`, mortalité entre passages, regarnis) et serve de jeu d'essai de bout en bout.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources

- `sommieR/CLAUDE.md` (registres en ajout seul, chaîne de hachages, tests PostGIS obligatoires, `.claude/test-command`, ne pas relancer `devtools::document()`).
- `R/demo.R` (`sommier_demo_couchey()`, l. 152 : plantation 2022 de l'UG 35 et ses contrôles), `R/travaux_plants.R` (`sommier_pointer_plant()`, états, regarnis), `R/travaux_suivi.R` (`sommier_suivi_plantations()`), NEWS du lot 2 (missions 054, 057) et la spec du lot 2 dans `specs/`.
- Règles des plants : `surculus/fixtures/regles/plants/*.json` (lecture seule).

## Ce qui est attendu

1. Dans la démo : pour chacune des 3 placettes de l'UG 35, des plants pointés (numéros uniques par placette, positions dans la placette, essence de la plantation), puis un état par plant vivant à chaque contrôle 2023 et 2025 (règle de la mission 054 : un plant mort ou absent a un état à chaque contrôle), avec au moins un mort et un regarni pour que la mortalité entre passages et `nb_regarnis` soient non nuls. Valeurs plausibles, **marquées comme données de démonstration**, sans inventer de code hors des référentiels du dépôt.
2. Les totaux du contrôle restent cohérents avec les états (sinon l'import les refuserait).
3. Tests contre une vraie base PostGIS (`SOMMIER_TEST_*`) : la démo s'écrit, `v_plant` et `v_etat_plant` ont les lignes attendues, `sommier_suivi_plantations()` rend une mortalité et des regarnis non nuls pour 2025, la chaîne de hachages se vérifie, la démo reste rejouable si elle l'était.
4. NEWS (développement) : retirer « démo Couchey » de la liste « Non fait ». Version selon `CLAUDE.md` de sommieR (cycle dev).

## Commandes de preuve

- `.claude/test-command` de sommieR (échoue si un test de base est sauté) : PostgreSQL 16 + PostGIS dans le conteneur (`pg_ctlcluster 16 main start`). sha, code, durée, réussis/échoués/sautés.
- `R CMD check` si le temps le permet (la CI échoue sur un avertissement).

## L'Homme

- **Agent :** `dev`, worktree de sommieR. Relu par le `relecteur`.
- **Moyens :** budget 3 $.
- **Ce qui ne lui est pas demandé :** modèle QField, plants versés à l'aller, `SOMMIER_METHODES_POINTAGE` (en attente de décision) ; release ; PR.
- **Dépend de / rouge attendu jusqu'à :** rien.
