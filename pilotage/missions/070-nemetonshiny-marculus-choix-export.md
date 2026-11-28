# Mission 070 — nemetonshiny-marculus-choix-export

> Ouverte le 2026-11-26 sur la décision 10 de Pascal (même jour) : « Marculus : choix à l'export (une fenêtre ; cochées par défaut les actions de l'année en cours et des années suivantes non faites) ». Rappel de l'état d'avant (réponse à Pascal du 2026-11-26) : le bouton « Télécharger vers Marculus » exporte toutes les actions éligibles (types éclaircie, coupe rase, dépressage, observation), quelle que soit leur année ou leur statut.
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, partie d'`origin/main` (a7a38a7 ou plus récent). Pas de release.

## Mission

**En une phrase :** Au clic sur « Télécharger vers Marculus » dans le Tableau des actions, ouvrir une fenêtre qui liste les actions éligibles avec une case à cocher chacune — cochées par défaut celles de l'année en cours et des années suivantes qui ne sont pas faites —, et n'exporter que les actions cochées, pour que le marteleur n'emporte sur le terrain que ce qu'il a à faire.

**Redite par l'agent :** _à compléter avant d'agir._

## Constat (origin/main)

`R/mod_action_plan.R` ~l. 2092 : `observeEvent(input$prepare_marculus)` prend `marculus_eligible_actions(plan_rv())` (toutes les éligibles), prépare ortho et tarifs, puis déclenche le téléchargement (`.telecharger_marculus()`, `download_marculus`). La construction du `.marsync` vit dans `R/service_marculus.R` (`marculus_context_from_action`, `marculus_sync_json`).

## Attendu

1. Le clic ouvre une `modalDialog` : tableau des actions éligibles (UGF, type, année, statut), une case chacune, cases « tout cocher » / « tout décocher » ; défaut = année ≥ année en cours ET statut ≠ fait (lire les valeurs réelles de statut du plan ; « fait » = le ou les statuts terminés). Boutons « Annuler » (`btn-secondary`) et « Exporter » (`btn-primary`), désactivé si rien n'est coché.
2. Seules les actions cochées passent à la suite existante (ortho manquantes, tarifs, téléchargement) : la sélection filtre la liste avant `marculus_ortho_manquants()` et avant la construction du fichier.
3. La règle de présélection est une fonction de service testable (`service_marculus.R`), pas dans le module ; la date « aujourd'hui » injectable pour les tests.
4. i18n `\uXXXX`, clés ≤ 30 caractères ; aucun littéral.

## Cas limites (tests `testServer` et service, sans réseau)

1. Plan avec actions 2025 faite, 2026 à faire, 2026 faite, 2027 à faire, aujourd'hui = 2026 → cochées par défaut : 2026 à faire et 2027 à faire seulement.
2. Décocher une action → le fichier exporté ne la contient pas (simulacre de la construction qui enregistre les actions reçues).
3. Rien coché → bouton Exporter désactivé, aucun export.
4. Aucune action éligible → message existant `marculus_export_empty`, pas de fenêtre.
5. Annuler → rien ne part.

## Ce qui est attendu

Code, tests, contrôle non ASCII, tests des fichiers R touchés (dont `test-service_marculus.R`, `test-mod_action_plan.R`), `.claude/test-command` (échec préexistant connu `test-service_marculus_ortho.R`), contre-épreuve sans `git stash` nu, cycle dev, NEWS ; commit et push. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 3 $. Dépend de : rien.
