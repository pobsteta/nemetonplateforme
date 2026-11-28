# Mission 087 — nemeton-release-2026-11-46

> Ouverte le 2026-11-27 sur la décision de Pascal (question « Onglet ICD », réponse : « Release du cœur d'abord ») : publier une release du cœur qui contient l'ICD (mission 074, PR #706), pour que l'app (`Remotes: pobsteta/nemeton@*release`) puisse ensuite offrir l'onglet ICD (mission 088).
> Dépôt : `nemeton`, branche `ccr-b52c1910-gjp34w`, partie de `origin/main` 479ba13ab (DESCRIPTION 2026.11.45.9005). Dernière release : `v2026.11.45` (2026-11-24).

## Mission

**En une phrase :** Préparer la release stable `2026.11.46` du 2026-11-27 selon les consignes de release de `CLAUDE.md` de nemeton (DESCRIPTION = tête de NEWS = CITATION.cff, PLAN.md), pour que la fusion sur `main` fasse poser le tag et la release par `release.yml`.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. Version stable `2026.11.46` : `DESCRIPTION` ; `NEWS.md` : la section de dev `# nemeton 2026.11.45.9001 (development)` devient `# nemeton 2026.11.46 (2026-11-27)` (garder tout son contenu ; vérifier qu'aucune entrée des PR #698 à #709 n'y manque, en comparant avec `git log v2026.11.45..origin/main` ; en tête de l'entrée, un résumé court : ICD décoloration (spec 071), RECONFORT par fenêtre et carte du spike, sondes et AlphaEarth côté cœur si présents, mosaïque de dalles et dalles IGN avant les produits dérivés) ; `CITATION.cff` : `version: "2026.11.46"`, `date-released: "2026-11-27"`.
2. **Changements cassants** : examiner les PR depuis `v2026.11.45` ; s'il y a retrait ou changement incompatible d'une fonction exportée stable, une section « Changements cassants » en tête de l'entrée NEWS et le DIRE dans le rapport (sans trancher : c'est à Pascal). Comportements devenus plus stricts à signaler même s'ils ne sont pas cassants au sens de l'API (par ex. mosaïque qui refuse un SRS réellement différent au lieu d'ignorer des dalles).
3. `PLAN.md` : ligne datée au journal (release 2026.11.46, contenu, clôtures de chantiers éventuelles, sans clore un chantier dont la release n'est pas celle-ci).
4. Garde-fou local : lancer le contrôle `version-consistency` tel que le fait la CI (voir `.github/workflows/r.yml` et le script qu'il appelle) et montrer qu'il passe.
5. Pas de `git tag`, pas de `gh release` : la CI s'en charge à la fusion. Pas de passage en `.9000` dans cette PR (ce sera après la release).

## Ce qui est attendu

Commit (`chore(release): nemeton 2026.11.46`, message en français, avec les deux lignes de fin habituelles), push sans force ; sha. Tests : `.claude/test-command` (rapporter les échecs déjà présents sur `origin/main`, identiques : `indicators-soil`, `indicators-frost`, `contrat-indicateurs`), plus `devtools::check()` si le temps le permet (sinon : dit). L'orchestrateur ouvre la PR et fusionne quand la CI est verte, sous la décision de Pascal.

## L'Homme

`dev`, worktree nemeton ; relu par le `relecteur` (cohérence des trois fichiers, NEWS complète). Budget 2 $.
