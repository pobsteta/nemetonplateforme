# Mission 081 — alphaearthnemeton-release

> Ouverte le 2026-11-26 sur la décision de Pascal (même jour) : « publier une release 2026.11.1 » d'`alphaearthnemeton`, pour que nemetonshiny le tire par `@*release` comme `nemeton` et `foretaccess` (mission 080).
> Dépôt : `pobsteta/alphaearthnemeton` (public, attaché en écriture à la session), branche `ccr-b52c1910-gjp34w`. La session ne sait pas créer une release GitHub directement : la release sera posée par la CI au merge, comme dans les autres dépôts de la plateforme.

## Mission

**En une phrase :** Ajouter à `alphaearthnemeton` le workflow `release.yml` des autres dépôts de la plateforme (porté de `nemeton/.github/workflows/release.yml`), déclenché par la fin réussie de son R-CMD-check sur `main`, qui pose le tag `v2026.11.1` et la release GitHub (`--generate-notes`) pour la version stable de DESCRIPTION, pour que l'app puisse tirer `pobsteta/alphaearthnemeton@*release`.

## Attendu

1. `.github/workflows/release.yml` porté de nemeton : même logique (version lue dans DESCRIPTION, stable `X.Y.Z` seulement, idempotent si le tag existe, `GITHUB_TOKEN` `contents: write`, déclenché par `workflow_run` du workflow de check de CE dépôt — lire le `name:` de `.github/workflows/R-CMD-check.yaml` et l'utiliser tel quel — plus `workflow_dispatch`). Actions épinglées par sha comme dans nemeton.
2. Vérifier la cohérence de version : DESCRIPTION `2026.11.1`, tête de NEWS `2026.11.1` ; s'il existe `CITATION.cff`, même version ; sinon ne pas en créer (hors périmètre), le dire.
3. Lire `CLAUDE.md` du dépôt s'il existe et le respecter. Pas de changement de code R.
4. Valider la syntaxe YAML (`python3 -c 'import yaml; yaml.safe_load(open(...))'`) et, si possible, `actionlint` ; sinon le dire.

## Ce qui est attendu

Commit et push sur la branche ; sha par `git rev-parse HEAD`. L'orchestrateur ouvre la PR, la fusionne quand le check est vert, puis vérifie que la release `v2026.11.1` existe.

## L'Homme

`dev` ; relu par l'orchestrateur (fichier unique). Budget 1 $.
