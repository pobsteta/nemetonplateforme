# Mission 078 — nemetonshiny-sondes-embeddings

> Ouverte le 2026-11-26 (« continue le dev des briefs restants »). Ferme l'écart n° 25 du `PLAN.md` de nemeton : vue « Ce que les modèles voient » (`nemeton::probe_indicator()`, cœur **2026.11.3**, spec `nemeton/specs/066-sondes-embeddings/spec.md` § 6, lecture seule).
> Dépôt : `nemetonshiny`, après la mission 077 (même branche de session). Pas de release.

## Mission

**En une phrase :** Ajouter la vue « Ce que les modèles voient » : la table des sondes du projet (`probe_indicator()`), triée par R², avec la lecture `voit` / `partiel` / `angle_mort` et le marqueur `source_commune`, pour que l'utilisateur sache quels indicateurs un embedding retrouve et lesquels il ne voit pas.

## Attendu

1. Lire la spec 066 (§ 4 à 6) et l'aide de `probe_indicator()` (pièges) ; placer la vue là où la spec la propose (ou, à défaut, dans la vue famille / synthèse, à dire).
2. Service (`service_*`) qui appelle `probe_indicator()` sur les unités et l'embedding du projet (mêmes sources que N5/B4/L3 de la mission 077) ; calcul long → `ExtendedTask` ; résultat mis en cache par projet.
3. Table triée par R² décroissant, colonnes traduites, lecture `voit` / `partiel` / `angle_mort` en clair, `source_commune` signalé (l'indicateur et l'embedding partagent une source : le R² ne prouve rien).
4. Sans embedding : message clair, pas de table.

## Cas limites (tests, cœur simulé)

1. Tri par R², traductions des trois lectures, marqueur `source_commune` visible.
2. Sans embedding → message, aucun appel au cœur.
3. Erreur du cœur → message, pas de plantage.

## Ce qui est attendu

Code, tests, i18n, contrôle non ASCII, tests des fichiers touchés, `.claude/test-command`, contre-épreuve, cycle dev, NEWS ; commit et push. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 3 $. Dépend de : 077 fusionnée.
