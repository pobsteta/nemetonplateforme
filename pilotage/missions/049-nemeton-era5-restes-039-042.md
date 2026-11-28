# Mission 049 — nemeton-era5-restes-039-042

> Ouverte le 2026-11-25 au cycle 18, sur la consigne de Pascal (« Lance le cycle 18 et les restes 039 et 042 »). Origine : mineurs laissés par le `relecteur` des missions 039 (journal, ligne `relecteur · 039 · à reprendre`, PR nemeton #684 e97957a) et 042 (ligne `relecteur · 042 · prête`, PR #689).
> Dépôt : `nemeton`, depuis la session cloud du 2026-11-25 qui a le dépôt cloné avec une branche de travail autorisée. La consigne de Pascal vaut réponse à l'écart du cycle 17 (journal, ligne `cycle 17 · écart`) pour cette mission. **Pas de release** : `DESCRIPTION` reste en `2026.11.45.9000`.
> Branche imposée par la session : `ccr-b52c1910-gjp34w` (la seule que la session peut pousser dans nemeton), au lieu de `mission/049`.

## Inventaire des restes (relu par l'orchestrateur sur `origin/main` d653b754, le 2026-11-25)

Soldés depuis, **hors mission** : année en cours retéléchargée (041, PR #687) ; liste d'années vide (PR #697) ; repli sur file pleine (caduc : plus de repli, décision (c) de la fiche 039) ; `ncdf4` sans `requireNamespace` (reprise 2 de 039) ; bissextile écrite deux fois (041) ; reprise refusée pour budget et contrôle de charge (044, 048) ; brief de livraison vers nemetonshiny (040) ; tests des cas 4, 7, 11 bis, 12 et 14 renforcés pendant les reprises de 039 (`tests/testthat/test-era5-timeseries.R` l. 69, 102, 155, 212, 378).

Restent, et c'est la mission :
1. **039** : le défaut `timeseries` n'est jamais testé à travers `regen_sensibilite()` (le seul appelant public de microclimf ; `R/regen_engines.R:1162` appelle `.rsen_forcage_era5()`). Aucun test de `test-regen-engines.R` ne passe par le forçage ERA5.
2. **042** : le refus d'une **variable illisible ou absente** n'est testé que sur les fixtures de l'ancienne forme (variables sur `longitude × latitude × valid_time`), pas sur la forme réelle du CDS (`.ts_fixture_cds()`, `latitude`/`longitude` scalaires, l. 543).

Hors mission : le cas 5 de 042 (vrai fichier CDS, test hors CI, l. 611) attend la décision de Pascal sur la règle de la réponse réelle (lieu durable, qui vérifie, cas sans réponse) ; la vraie réponse n'est pas dans ce conteneur.

## Mission

**En une phrase (quoi, et pourquoi) :** Ajouter à nemeton les deux tests laissés par les relectures de 039 et 042 (le forçage ERA5 `timeseries` par défaut vu à travers `regen_sensibilite()`, et le refus d'une variable illisible sur la forme réelle de la réponse CDS), pour que ces deux chemins ne puissent plus régresser sans rougir la CI.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- `CLAUDE.md` de nemeton (cycle `.9000`, `PLAN.md`, règles strictes).
- `R/regen_engines.R` : `regen_sensibilite()` (l. 1340), l'appel au forçage (l. 1162), `.rsen_forcage_era5()` et ses points d'injection `acces_ts`, `source`, `pause` (l. 935-1030), `.rsen_era5_nc_complet()`.
- `R/era5_timeseries.R` ; `tests/testthat/test-era5-timeseries.R` (`.acces_ts_faux()`, `.ts_fixture_cds()`, tests `m042`) ; `tests/testthat/test-regen-engines.R` (l. 142-200 : appels de `regen_sensibilite()` avec MNT/MNH synthétiques).

## Cas limites (un test par cas, qui échoue sans ce qu'il protège ; sans réseau)

1. **`regen_sensibilite()` par défaut** (option `nemeton.era5_source` non posée) : avec un accès CDS simulé injecté (`acces_ts` passé par `...`, ou `local_mocked_bindings()` sur `.rsen_era5_acces_cds()` si `...` ne le transmet pas jusqu'au forçage), le forçage part par le jeu `timeseries` (4 requêtes `dataset_short_name == .RSEN_ERA5TS_DATASET`, fichiers `era5ts_*`, aucun `era5_*`) et le calcul aboutit, ou s'arrête **après** le forçage si microclimf manque (`skip_if_not_installed("microclimf")` seulement pour la partie qui en dépend). Contre-épreuve à faire et à noter : le test rougit si le défaut de `.rsen_era5_source()` repasse à `"classique"`.
2. **Variable illisible, forme réelle** : un NetCDF de la forme de `.ts_fixture_cds()` auquel il manque une des 10 variables (ex. `fdir`) est refusé (`.rsen_era5ts_en_cache()` FALSE ou erreur `rsen_era5ts_echec`, selon le comportement actuel, à constater et à figer) ; un fichier de cette forme où une variable ne se lit pas (ex. valeurs écrites sur une longueur plus courte que `valid_time`, ou type incompatible) est refusé aussi. Si le code actuel **accepte** l'un de ces fichiers, c'est un défaut : le dire dans la PR, le corriger dans `R/` (correctif minimal) et le tester.
3. **Rien d'autre ne change** : les tests existants `era5-timeseries`, `regen-engines`, `load-biljou` restent verts.

## Ce qui est attendu

1. Les tests ci-dessus, dans `tests/testthat/test-era5-timeseries.R` (cas 2) et `test-regen-engines.R` ou `test-era5-timeseries.R` (cas 1).
2. `.claude/test-command` **et** `Rscript -e 'devtools::test(filter = "era5-timeseries|regen-engines|load-biljou", stop_on_failure = TRUE)'` ; les deux dans le rendu (sha, commande, code, durée). Si une dépendance manque dans le conteneur, le dire (fichiers sautés comptés) au lieu de conclure vert.
3. `DESCRIPTION` inchangé (`2026.11.45.9000`). Pas d'entrée `NEWS.md` si seuls des tests changent ; une entrée « fix » en développement si le cas 2 révèle un défaut corrigé dans `R/`. Entrée datée dans `PLAN.md` selon `CLAUDE.md`.
4. Commit sur la branche `ccr-b52c1910-gjp34w` de nemeton, partie de `origin/main` ; push. L'orchestrateur ouvre la PR (brouillon) et suit la CI.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), dans un worktree de nemeton. Relu par le `relecteur`.
- **Moyens :** budget 2 $ ; R installé dans le conteneur par l'orchestrateur (paquets Ubuntu ; les Suggests absents sont sautés).
- **Ce qui ne lui est pas demandé :** release ; appel réel au CDS ; le cas 5 de 042 ; toucher un autre dépôt ; ouvrir ou fusionner la PR.
- **Dépend de / rouge attendu jusqu'à :** rien.
