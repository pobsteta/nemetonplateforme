# Mission 066 — nemetonshiny-itineraires

> Ouverte le 2026-11-25 au cycle 18 sous la consigne de Pascal de continuer les briefs restants, et sur sa décision du même jour (journal, « décisions », point 6 : l'app compare avec les poids provisoires de `profils_poids()`, affichés comme provisoires). Origine : brief `nemeton/specs/064-alphaearth-n5/brief-nemetonshiny.md` § « spec 065 », points 5 et 6 ; écarts n° 23 et 24 de `nemeton/PLAN.md`. Cœur livré en 2026.11.4, plancher de l'app suffisant.
> Dépôt : `nemetonshiny`, branche imposée `ccr-b52c1910-gjp34w`, partie d'`origin/main` (B5 fusionné, #335). **Pas de release.**

## Mission

**En une phrase (quoi, et pourquoi) :** Montrer dans le plan d'actions de nemetonshiny, pour chaque UGF, les itinéraires sylvicoles admissibles et la raison de chaque exclusion (`itineraires_admissibles()`), et les itinéraires classés sous le profil d'acteur choisi (`comparer_itineraires()` avec `profils_poids()`), poids présentés comme provisoires et classement comme un rang, pour que le gestionnaire voie ce qui est possible et ce qui convient à son profil.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Ce que disent le brief et les décisions (font foi)

1. **Admissibles par UGF** avec la raison de chaque exclusion, codes fermés : `station_insuffisante`, `hors_ser`, `essence_absente`, `pente`, `desserte`, `statut_protection`, `source_manquante`, `donnee_manquante` — chacun traduit FR/EN. `donnee_manquante` n'est jamais silencieux (spec 065). Vue : onglet plan d'actions.
2. **Comparaison pondérée sous un profil** : colonnes `rang`, `familles_evaluees` en plus. `score_global` est un **rang** (effets qualitatifs) : **ne jamais l'afficher comme une note sur 100**.
3. **Poids** : `nemeton::profils_poids(profil)` (15 profils, prioritaire = 3, autre = 1). Décision de Pascal : on s'en sert, et l'écran dit « poids provisoires ». Le profil est celui déjà choisi dans l'app (profil expert de la session ou du projet) — ne pas créer un second sélecteur s'il existe déjà.
4. Catalogue : `itineraires_catalogue()` du cœur ; il est livré en squelette (11 itinéraires, tous `a_sourcer`) : l'écran doit le dire (« catalogue en cours de sourçage ») sans le cacher. Desserte : colonne `desserte_m` fournie par l'appelant si l'app l'a (spec 065 D-3) ; sinon `donnee_manquante`.

## Les sources

- `nemetonshiny/CLAUDE.md` en entier (i18n `\uXXXX`, clés ≤ 30 car., pas de logique métier dans `mod_*` → service, couleurs de boutons, cycle dev `.900x`, NEWS ; ne pas toucher nemeton).
- Cœur en lecture : `nemeton/R/itineraires.R` (`itineraires_admissibles()` l. 134, `comparer_itineraires()` l. 265, `profils_poids()` l. 424), `specs/065-itineraires-catalogue/spec.md` (D-1 à D-4, codes).
- App : `R/mod_action_plan.R` (plan d'actions), la gestion du profil expert (`R/llm_prompts.R`, état de session), `R/utils_i18n.R`, la source de la desserte si elle existe (`service_desserte.R`).

## Cas limites (un test par cas, sans réseau ; cœur appelé pour de vrai quand c'est rapide, simulé sinon)

1. Une UGF avec itinéraires admissibles et exclus : chaque code d'exclusion est traduit, aucun code brut à l'écran.
2. Donnée manquante (ex. pas de desserte) : la ligne apparaît avec `donnee_manquante`, jamais absente.
3. Changer de profil change le classement (profil production contre naturaliste, comme le test du cœur) ; le rang est affiché comme un rang, aucun « /100 ».
4. La mention « poids provisoires » et « catalogue en cours de sourçage » est présente (FR/EN).
5. Sans UGF ou sans projet : message, pas d'erreur.

## Ce qui est attendu

1. Service(s) `R/service_itineraires.R` (ou équivalent) + module, tests ci-dessus.
2. `.claude/test-command` de nemetonshiny et un lot ciblé ; sha, commande, code, durée, réussis/échoués/sautés ; contre-épreuve.
3. Cycle dev suivant dans `DESCRIPTION`, entrée NEWS. Ne pas toucher `nemeton/PLAN.md`.
4. Commit sur `ccr-b52c1910-gjp34w`, push. L'orchestrateur ouvre la PR.

## L'Homme

- **Agent :** `dev`, worktree de nemetonshiny. Relu par le `relecteur`.
- **Moyens :** budget 5 $.
- **Ce qui ne lui est pas demandé :** remplir le catalogue ; modifier les poids ; écart 27 (type de gestion, mission suivante) ; release ; PR.
- **Dépend de :** rien (#335 fusionnée).
