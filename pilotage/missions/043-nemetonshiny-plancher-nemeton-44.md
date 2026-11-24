# Mission 043 — nemetonshiny-plancher-nemeton-44

> Ouverte le 2026-11-24 au cycle 15, sur l'accord de Pascal (« oui » à relever le plancher), sous sa délégation jusqu'à la fin.
> Dépôt : `nemetonshiny` (session ouverte dans le projet, ADR 0001). Fusion par l'orchestrateur quand les contrôles sont verts. **Pas de release posée par la mission.**
> Une autre PR est ouverte dans ce dépôt par sa propre session (nemetonshiny #323, fenêtre E-OBS) : ne pas la toucher ; si `main` bouge, se remettre à jour par fusion de `origin/main`.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire exiger à nemetonshiny `nemeton (>= 2026.11.44)`, parce que les versions 2026.11.42 et 2026.11.43 échouent sur une vraie réponse du CDS (variables scalaires, mission 042), et ouvrir le cycle de développement 2026.11.6.9000.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- Dans `nemetonshiny` (vérifié le 2026-11-24 sur `origin/main` : `Version: 2026.11.6`, `nemeton (>= 2026.11.42)`) : `CLAUDE.md` (version `.9000`, NEWS, « Consignes de release »), `pilotage/` du projet, `DESCRIPTION`, `tests/testthat/test-contrat_nemeton.R` (l. 259 : `expect_gte(packageVersion("nemeton"), "2026.11.35")`).
- Dans nemeton v2026.11.44 (lecture seule) : `NEWS.md`, entrées 2026.11.43 et 2026.11.44.

## Cas limites (un test par cas, qui échoue sans le changement)

1. **Plancher** : `DESCRIPTION` exige `nemeton (>= 2026.11.44)`.
2. **Test de contrat** : `test-contrat_nemeton.R` vérifie que la version de nemeton installée est au moins le plancher **lu dans `DESCRIPTION`** (et non un chiffre recopié), pour que les deux ne divergent plus ; il échoue avec l'ancien test si le plancher est relevé sans que nemeton suive.
3. **Rien d'autre ne change** dans le code de l'app.

## Ce qui est attendu

1. Les cas 1 et 2, test compris.
2. `.claude/test-command` et `Rscript -e 'devtools::test(filter = "contrat_nemeton", stop_on_failure = TRUE)'`. Noter les deux dans `tests`.
3. Version : `DESCRIPTION` en `2026.11.6.9000`, entrée `NEWS.md` en développement (plancher relevé et pourquoi), journal et `PLAN.md` du projet selon son `CLAUDE.md`. Pas de version stable ni de tag.
4. CI verte.

## L'Homme

- **Agent :** `dev`, dans une session ouverte dans `nemetonshiny`. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 3 $ ; worktree depuis `origin/main`.
- **Ce qui ne lui est pas demandé :** poser une release ; toucher nemeton ou un autre dépôt ; toucher la PR #323 ; fusionner.
- **Dépend de / rouge attendu jusqu'à :** nemeton v2026.11.44, publiée le 2026-11-24. Rien d'autre.

## Fin

> Ajoutée le 2026-11-24 (mission 046), d'après le journal et le kanban.

PR nemetonshiny #326 (db1e93dc) fusionnée (ca5072a8) le 2026-11-24 ; pas de release (cycle de développement 2026.11.6.9000). Coût : 0,71 $ pour 3 $ ; 0 aller-retour de relecture (un premier départ sans fiche, repris avec la fiche en place).
