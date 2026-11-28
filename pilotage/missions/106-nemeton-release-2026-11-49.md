# Mission 106 — nemeton-release-2026-11-49

> Ouverte le 2026-11-28 sur la décision de Pascal (« Oui, publie 2026.11.49 »). Il s'agit de publier la release du cœur qui contient les actions candidates P4 (mission 104, PR #719), pour que l'app puisse lancer la 105 (arbitrage par le LLM et validation).
> Dépôt : `nemeton`, partie d'`origin/main` 4b81e1d06 (DESCRIPTION 2026.11.48.9000). Dernière release : `v2026.11.48` (2026-11-28).

## Mission

**En une phrase :** Préparer la release stable `2026.11.49` du 2026-11-28, selon les consignes de release du `CLAUDE.md` de nemeton : DESCRIPTION, tête de NEWS et CITATION.cff identiques, PLAN.md à jour. La fusion sur `main` fera alors poser le tag et la release par `release.yml`.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. **Version stable `2026.11.49`.**
   - `DESCRIPTION` passe en `2026.11.49`.
   - `NEWS.md` : la section `2026.11.48.9000 (development)` devient `# nemeton 2026.11.49 (2026-11-28)`. Tout son contenu est gardé, avec un résumé court en tête : étage 2 du plan d'actions P4 (actions candidates, options, priorité, contexte pour le LLM), matrice signal-action provisoire.
   - Vérifier qu'aucune PR fusionnée depuis `v2026.11.48` ne manque (`git log v2026.11.48..origin/main --merges` : seule la #719).
   - `CITATION.cff` passe en `2026.11.49`, avec la date du 2026-11-28.
2. **Changements cassants.** Aucun attendu (ajouts seuls, aucune fonction existante modifiée) : le vérifier et le dire dans le rapport.
3. **`PLAN.md`** : une ligne datée au journal.
4. **Garde-fou local** : lancer le contrôle `version-consistency` tel que la CI le fait, et montrer qu'il passe.
5. **Interdits.** Pas de `git tag`, pas de `gh release`, pas de passage en `.9000`.

## L'Homme

`dev`, worktree nemeton ; cohérence contrôlée par l'orchestrateur. Budget 1,5 $.
