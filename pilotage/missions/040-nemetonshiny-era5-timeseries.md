# Mission 040 — nemetonshiny-era5-timeseries

> Ouverte le 2026-11-23 au cycle 15, sur la consigne de Pascal (« code ce qu'il reste à faire jusqu'au bout que je puisse tester colombière »), sous sa délégation jusqu'à la fin. Origine : brief de livraison `~/dev/briefs/vers-nemetonshiny/2026-11-23-nemeton-2026-11-42-era5-timeseries.md` (nemeton v2026.11.42, mission 039).
> Dépôt : `nemetonshiny` (session ouverte dans le projet, ADR 0001). Fusion par l'orchestrateur quand les contrôles sont verts. **La release de nemetonshiny n'est pas posée par la mission** (l'orchestrateur la pose ensuite).
> Une autre PR est ouverte dans ce dépôt par sa propre session (nemetonshiny #323, fenêtre E-OBS, `R/service_regeneration.R`) : ne pas la toucher ; si `main` bouge, se remettre à jour par fusion de `origin/main`.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire suivre à nemetonshiny le forçage ERA5 `timeseries` de nemeton 2026.11.42 (plancher, message d'échec, compteur de progression, textes de durée), pour que Pascal lance la régénération de la Colombière et lise une progression et une durée vraies.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- Le brief de livraison, en entier (lien ci-dessus) : il fait foi.
- Dans `nemetonshiny` (vérifié le 2026-11-23 sur `origin/main`, `DESCRIPTION` en 2026.11.5, plancher `nemeton (>= 2026.11.40)`) : `CLAUDE.md` (version `.9000`, NEWS, i18n, « Consignes de release »), `pilotage/` du projet, `R/service_regeneration.R` (l. 850-900 : événements `regen_expo:era5_mois`, `era5_attente`, `biljou:era5_attente`, phase `era5_lot`), `R/mod_regeneration.R` (l. 75-120 : `.regen_micro_lbl()`, libellé `regen_phase_micro_mois`), `R/utils_i18n.R` (`regen_engine_tip` l. 6332, `regen_phase_micro_mois`, et tout texte qui annonce « plusieurs heures à deux jours », « ~12 requêtes par année » ou un compteur de mois ERA5).
- Dans nemeton v2026.11.42 (lecture seule) : `NEWS.md` (entrée 2026.11.42), la classe d'erreur `rsen_era5ts_echec` et l'option `nemeton.era5_source`.

## Contrat amont lu

nemeton v2026.11.42 : signatures et noms d'événements inchangés. Sur le chemin `timeseries`, `mois_i`/`mois_n` comptent des **mailles-années** (4 par point et par année). Pas de repli automatique : échec = erreur `rsen_era5ts_echec`, dont le message dit comment passer au chemin classique.

## Cas limites (un test par cas, qui échoue sans le changement)

1. **Plancher** : `DESCRIPTION` exige `nemeton (>= 2026.11.42)` ; le test de contrat avec nemeton (`test-contrat_nemeton*.R`) reste vert.
2. **Compteur** : un événement `regen_expo:era5_mois` (ou `era5_attente`) ne s'affiche plus « mois i/n » : libellé neutre ou « requêtes ERA5 i/n » (fr et en), dans `.regen_micro_lbl()` et partout où `regen_phase_micro_mois` sert. Le suffixe d'attente CDS reste inchangé.
3. **Échec `timeseries`** : une erreur de classe `rsen_era5ts_echec` levée par le moteur arrive à l'utilisateur avec son message tel quel (cause et option `nemeton.era5_source = "classique"`), dans l'état d'erreur que l'app affiche déjà pour un moteur en échec. L'app ne bascule jamais d'elle-même sur le chemin classique. Test avec un moteur simulé.
4. **Textes de durée** : `regen_engine_tip` (fr et en) et tout texte qui annonce plusieurs heures à deux jours ou ~12 requêtes par année disent désormais : quelques minutes par année et par point au premier calcul (4 requêtes au CDS), quelques secondes ensuite (cache). Pas de chiffre plus précis : la durée réelle n'est pas mesurée.
5. **ntfy** : la notification par année (`regen_ntfy_era5`) reste juste avec le nouveau compteur (test).
6. **Rien d'autre ne change** : E-OBS, BILJOU SAFRAN, les autres phases.

## Ce qui est attendu

1. Les changements des cas 1 à 5, tests compris.
2. `.claude/test-command`, **et aussi** `Rscript -e 'devtools::test(filter = "regeneration|mod_regeneration|service_regeneration|contrat_nemeton", stop_on_failure = TRUE)'` (le niveau rapide n'exécute pas les fichiers lents de la régénération). Noter les deux dans `tests`.
3. Version : `DESCRIPTION` en cycle dev (`2026.11.5.9000` ou la suivante selon `CLAUDE.md`), entrée `NEWS.md` en développement, journal et `PLAN.md` du projet selon son `CLAUDE.md`. Pas de version stable ni de tag.
4. Corps de la PR : pour chaque point « À faire côté app » du brief, ce qui est fait.
5. CI verte.

## L'Homme

- **Agent :** `dev`, dans une session ouverte dans `nemetonshiny`. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 3 $ ; worktree depuis `origin/main`.
- **Ce qui ne lui est pas demandé :** poser une release ; toucher nemeton ou un autre dépôt ; toucher la PR #323 ; lancer un vrai calcul ERA5 ; fusionner ; ranger le brief.
- **Dépend de / rouge attendu jusqu'à :** nemeton v2026.11.42, publiée le 2026-11-23. Rien d'autre.
