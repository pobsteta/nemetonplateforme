# Mission 084 — nemetonshiny-synthese-sous-onglets

> Ouverte le 2026-11-26 sur la demande de Pascal : « Dans l'onglet synthèse faire 2 sous-onglets, un premier "Synthèse du projet" et un deuxième "Gestion sur ce massif", ce dernier onglet regroupe le bloc "Ce que la gestion a produit sur ce massif" ». Question posée le même jour, réponse de Pascal : la carte « Ce que les modèles voient » (sondes, mission 078) va aussi dans « Gestion sur ce massif ».
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, après fusion de la PR #348 (mission 083). Pas de release.

## Mission

**En une phrase :** Découper la vue Synthèse (Atlas → Synthèse) en deux sous-onglets — « Synthèse du projet » (tout ce qui s'y trouve aujourd'hui sauf les deux blocs du bas) et « Gestion sur ce massif » (le bloc « Ce que la gestion a produit sur ce massif » de `mod_effet_gestion`, puis la carte « Ce que les modèles voient » de `mod_sondes_embedding`) — sans rien changer à leur contenu ni à leur comportement.

**Redite par l'agent :** _à compléter avant d'agir._

## Sources (lecture)

- `R/app_ui.R` : `mod_synthesis_ui()` (fin de fonction, vers les lignes 650-656 : `mod_effet_gestion_ui(ns("effet_gestion"))` puis `mod_sondes_embedding_ui(ns("sondes_embedding"))`) ; la Synthèse est déjà un sous-onglet d'Atlas (`navset_card_underline(id = "atlas_nav")`, valeur `synthesis`).
- `R/mod_synthesis.R` (serveurs des deux modules), `R/service_navigation.R` (les onglets logiques : ne pas casser la navigation vers `synthesis`), `R/mod_effet_gestion.R`, `R/mod_sondes_embedding.R`.
- Règles UI de `CLAUDE.md` (i18n `\uXXXX`, couleurs de boutons, pas de littéral).

## Attendu

1. Un `bslib::navset_card_underline` (ou `navset_underline`, cohérent avec les autres sous-onglets de l'app) à l'intérieur de `mod_synthesis_ui`, avec deux `nav_panel` : valeurs `synthese_projet` et `gestion_massif` (NMT), titres i18n `synthese_sous_projet` = « Synthèse du projet » / « Project summary », `synthese_sous_gestion` = « Gestion sur ce massif » / « Management on this forest » (clés ≤ 30 caractères, accents en `\uXXXX`). Icônes bsicons sobres.
2. Le premier sous-onglet est sélectionné par défaut ; tout lien interne qui mène à la Synthèse continue d'y mener (et donc au premier sous-onglet).
3. Les deux modules gardent leurs identifiants (`effet_gestion`, `sondes_embedding`) : leurs serveurs, caches et tâches ne changent pas. Vérifier qu'un rendu dans un onglet caché ne bloque rien (sorties suspendues tant que l'onglet n'est pas affiché : acceptable, à dire) et qu'un calcul lancé dans « Gestion sur ce massif » se poursuit si l'on revient sur « Synthèse du projet ».
4. Pas de nouvelle logique : déplacement d'UI seulement.

## Cas limites (tests)

1. `mod_synthesis_ui("synthesis")` contient les deux sous-onglets, dans cet ordre, avec les bons titres FR et EN.
2. Le premier sous-onglet ne contient ni `effet_gestion` ni `sondes_embedding` ; le second contient les deux, dans cet ordre.
3. Les tests existants de `test-mod_synthesis.R`, `test-mod_effet_gestion.R`, `test-sondes_embedding.R`, `test-i18n_keys_used.R`, `test-utils_i18n.R` et de la navigation restent verts.

## Ce qui est attendu

Code, tests, contrôle non ASCII dans `R/`, tests des fichiers touchés, `.claude/test-command`, contre-épreuve sans `git stash` nu, cycle dev (`.9023`), NEWS ; commit et push ; sha par `git rev-parse HEAD`. Une capture de l'app (Playwright, Chromium préinstallé) des deux sous-onglets si l'app démarre dans le conteneur ; sinon le dire. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 2 $. Dépend de : PR nemetonshiny #348 fusionnée.
