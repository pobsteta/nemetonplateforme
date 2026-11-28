# Mission 098 — nemeton-release-2026-11-47

> Ouverte le 2026-11-28 sur la décision de Pascal (« Oui publie ») : publier la release du cœur qui contient les missions 095, 089 et 096, pour que l'app (`Remotes: pobsteta/nemeton@*release`) puisse ensuite régler et afficher la source Sentinel-2.
> Dépôt : `nemeton`, branche `ccr-b52c1910-gjp34w`, partie de `origin/main` f63346fc1 (DESCRIPTION 2026.11.46.9002). Dernière release : `v2026.11.46` (2026-11-27).

## Mission

**En une phrase :** Préparer la release stable `2026.11.47` du 2026-11-28 selon les consignes de release du `CLAUDE.md` de nemeton (DESCRIPTION = tête de NEWS = CITATION.cff, PLAN.md), pour que la fusion sur `main` fasse poser le tag et la release par `release.yml`.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. Version stable `2026.11.47` :
   - **`DESCRIPTION`** : `Version: 2026.11.47`.
   - **`NEWS.md`** : les trois sections de dev (`2026.11.46.9000`, `.9001`, `.9002`) deviennent une seule entrée `# nemeton 2026.11.47 (2026-11-28)`. Garder tout leur contenu et vérifier qu'aucune PR fusionnée depuis `v2026.11.46` n'y manque (`git log v2026.11.46..origin/main --merges`, PR #711, #712, #713). En tête de l'entrée, un résumé court : RECONFORT sur Sen2Cor (indicatif) et modèle v3 hors IOTA² ; repli THEIA → GEODES → Sen2Cor ; source Sentinel-2 au choix (`source_s2`), avec un défaut propre à chaque méthode ; fifos du superviseur processx.
   - **`CITATION.cff`** : `version: "2026.11.47"`, `date-released: "2026-11-28"`.
2. **Changements cassants.** Examiner les PR depuis `v2026.11.45` (#711 à #713). S'il y a retrait ou changement incompatible d'une fonction exportée stable, ouvrir une section « Changements cassants » en tête de l'entrée NEWS et le DIRE dans le rapport, sans trancher. À signaler même si ce n'est pas cassant au sens de l'API : comportements nouveaux par défaut, comme le repli automatique de RECONFORT et les sondes réseau ; clés ajoutées à `run_meta.json` (`acquisition`, `causes_repli`) ; `validee` absent (jamais publié).
3. **`PLAN.md`** : ligne datée au journal (release 2026.11.47, contenu).
4. **Garde-fou local** : lancer le contrôle `version-consistency` comme le fait la CI (voir `.github/workflows/r.yml` et le script qu'il appelle) et montrer qu'il passe.
5. Pas de `git tag`, pas de `gh release` : la CI s'en charge à la fusion. Pas de passage en `.9000` dans cette PR.

## Ce qui est attendu

Commit `chore(release): nemeton 2026.11.47` (message en français, avec les deux lignes de fin habituelles), push sans force ; sha. Tests : le contrôle de version ; `R CMD build` + vérification que NEWS se lit (`utils::news()` sur le paquet ou équivalent). L'orchestrateur ouvre la PR et fusionne quand la CI est verte.

## L'Homme

`dev`, worktree nemeton ; contrôle de cohérence par l'orchestrateur. Budget 1,5 $.
