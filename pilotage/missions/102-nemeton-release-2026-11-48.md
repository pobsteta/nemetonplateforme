# Mission 102 — nemeton-release-2026-11-48

> Ouverte le 2026-11-28 sur la décision de Pascal (« Oui, publie 2026.11.48 »). Il s'agit de publier la release du cœur qui contient P4 (spec 072, mission 101, PR #717), pour que l'app puisse ensuite exposer P4 (jalon M4).
> Dépôt : `nemeton`, branche `ccr-b52c1910-gjp34w`, partie d'`origin/main` e036f3aca (DESCRIPTION 2026.11.47.9001). Dernière release : `v2026.11.47` (2026-11-28).

## Mission

**En une phrase :** Préparer la release stable `2026.11.48` du 2026-11-28, selon les consignes de release du `CLAUDE.md` de nemeton : DESCRIPTION, tête de NEWS et CITATION.cff identiques, PLAN.md à jour. La fusion sur `main` fera alors poser le tag et la release par `release.yml`.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. **Version stable `2026.11.48`.**
   - `DESCRIPTION` passe en `2026.11.48`.
   - `NEWS.md` : les sections de développement depuis `2026.11.47` (`.9000` est vide, `.9001` contient P4) deviennent une seule entrée `# nemeton 2026.11.48 (2026-11-28)`. Tout leur contenu est gardé, avec un résumé court en tête : indicateur conditionnel P4 (rendement net du risque, spec 072), synthèse forêt, risque de ruine, Pareto, sélection des axes, refus des `R*_norm` incohérents.
   - Vérifier qu'aucune PR fusionnée depuis `v2026.11.47` ne manque dans l'entrée (`git log v2026.11.47..origin/main --merges` : #715, #717).
   - `CITATION.cff` passe en `2026.11.48`, avec la date du 2026-11-28.
2. **Changements cassants.** Les examiner, sans trancher, et les dire dans le rapport. À signaler à coup sûr, même si l'API n'est pas cassée :
   - 45 indicateurs, dont 14 conditionnels ;
   - `yaml` passe en Imports ;
   - les nouvelles erreurs `nemeton_p4_*`.
3. **`PLAN.md`** : une ligne datée au journal.
4. **Garde-fou local** : lancer le contrôle `version-consistency` tel que la CI le fait, et montrer qu'il passe.
5. **Interdits.** Pas de `git tag`, pas de `gh release`, pas de passage en `.9000`.

## L'Homme

`dev`, worktree nemeton ; cohérence contrôlée par l'orchestrateur. Budget 1,5 $.
