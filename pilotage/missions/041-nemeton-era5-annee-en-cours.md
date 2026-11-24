# Mission 041 — nemeton-era5-annee-en-cours

> Ouverte le 2026-11-23 au cycle 15, sur la consigne de Pascal (« code ce qu'il reste à faire jusqu'au bout que je puisse tester colombière »), sous sa délégation jusqu'à la fin. Origine : reste à solder de la mission 039 (relecture de 0cf3f85, mineur « année en cours »).
> Dépôt : `nemeton` (session ouverte dans le projet, ADR 0001). Fusion par l'orchestrateur quand les contrôles sont verts. **La release n'est pas posée par la mission.**

## Mission

**En une phrase (quoi, et pourquoi) :** Faire refuser par le chemin ERA5 `timeseries` une année qu'ERA5 ne couvre pas encore entièrement, avant tout appel au CDS et avec un message qui le dit, pour qu'un calcul qui demande l'année en cours ne retélécharge pas quatre requêtes à chaque appel avant d'échouer sur une erreur trompeuse.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- `~/dev/nemetonplateforme/pilotage/missions/039-nemeton-era5-timeseries.md` (contexte) et l'entrée 2026.11.42 de `NEWS.md`.
- Dans `nemeton` (`origin/main` après v2026.11.42) : `CLAUDE.md`, `R/era5_timeseries.R` (`.rsen_era5ts_couvre()`, contrôle de l'année complète, contrôle bissextile écrit deux fois), `R/regen_engines.R` (`.rsen_era5_assurer()` branche `timeseries`, `.rsen_era5ts_abort`), `R/load_biljou.R` (l. 90 : années acceptées jusqu'à l'année courante), `tests/testthat/test-era5-timeseries.R`.

## Contrat aval lu

nemetonshiny appelle `regen_sensibilite()` et BILJOU ; il affiche le message d'une erreur `rsen_era5ts_echec` tel quel (mission 040). Signatures, événements et classe d'erreur inchangés.

## Cas limites (un test par cas, qui échoue sans le changement ; sans réseau)

1. **Année en cours** (ou toute année dont le 31 décembre 23 h UTC n'est pas encore passé de 5 jours, la latence annoncée par le CDS ; `maintenant` injectable) : erreur `rsen_era5ts_echec` **avant** toute requête et tout effacement de cache, dont le message dit qu'ERA5 ne couvre pas encore l'année entière (latence d'environ 5 jours) et qu'il faut une année close. Le test vérifie qu'aucune requête ne part.
2. **Année future** : même refus.
3. **Année close** (ex. 2024) : comportement inchangé.
4. **Chemin classique** (`nemeton.era5_source = "classique"`) : inchangé (hors périmètre).
5. **Un seul contrôle bissextile** : la règle écrite deux fois dans `R/era5_timeseries.R` est mise en commun, sans changer son résultat (tests existants verts).

## Ce qui est attendu

1. Le refus des cas 1 et 2 dans le chemin `timeseries`, et le cas 5.
2. `.claude/test-command` **et** `Rscript -e 'devtools::test(filter = "era5-timeseries|regen-engines|load-biljou", stop_on_failure = TRUE)'` ; les deux dans `tests`.
3. `DESCRIPTION` en `2026.11.42.9000` ; entrée `NEWS.md` en développement ; `PLAN.md` selon `CLAUDE.md`. Pas de version stable ni de tag.
4. CI verte, codecov compris.

## L'Homme

- **Agent :** `dev`, dans une session ouverte dans `nemeton`. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 3 $ (plafond du lanceur) ; worktree depuis `origin/main`.
- **Ce qui ne lui est pas demandé :** release ; toucher un autre dépôt ; changer le chemin classique ; lancer un vrai calcul ERA5 ; fusionner.
- **Dépend de / rouge attendu jusqu'à :** la PR nemeton #686 (cycle dev 2026.11.42.9000), fusionnée avant le départ.

## Fin

> Ajoutée le 2026-11-24 (mission 046), d'après le journal et le kanban.

PR nemeton #687 fusionnée par commit de fusion (907c37e) le 2026-11-23 (dernier SHA de la branche : a1e3ca0) ; publiée en v2026.11.43 (PR de release nemeton #688, fusionnée 3e1e6b0, tag `v2026.11.43`). Coût : 1,11 $ cumulé pour 3 $ ; 1 aller-retour (reprise 1).
