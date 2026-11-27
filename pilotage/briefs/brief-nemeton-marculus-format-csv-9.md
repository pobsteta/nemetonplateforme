# Brief vers nemeton — Marculus format CSV 9 (pour information)

> Émis le 2026-11-27 par l'orchestrateur de nemetonplateforme, sur la demande de Pascal. Source : Marculus PR #82 (1e7c0a0), release **v2026.11.4** ; détail du format dans `pilotage/briefs/brief-nemetonshiny-marculus-format-csv-9.md`.

## Constat

Marculus passe au `FormatCsv;9` : `VolumeTotalM3` (bois fort, découpe 7 cm) devient `VolumeBoisFortTotalM3`, et un volume aérien total EMERGE sans découpe apparaît (`VolumeAerienTotalM3`, `NbTigesVolumeAerien`) ; le `.marsync` suit (`volumeBoisFortTotalM3`, `volumeAerienTotalM3`) ; le CSV foncier passe de `Total_m3` à `BoisFortTotal_m3` + `AerienTotal_m3`.

**Le cœur ne lit aucun de ces fichiers aujourd'hui** : recherche faite sur `origin/main` (2026-11-27) de `VolumeTotalM3`, `volumeTotalM3`, `Total_m3`, `FormatCsv`, `marsync` dans `R/`, `inst/`, `tests/` de nemeton : aucun résultat. L'import des fichiers Marculus vit dans nemetonshiny (`R/service_marculus_import.R`).

## Ce que nemeton doit faire

Rien pour l'instant. Si le cœur se met à lire des volumes Marculus (par exemple pour comparer les volumes EMERGE à ses propres tarifs, ou dans tarif-nemeton qui a émis le brief d'origine), appliquer la même règle que nemetonshiny : nouveau nom d'abord, ancien nom lu comme **bois fort total**, jamais comme volume aérien ; le volume aérien total n'existe que pour les tiges cubées en EMERGE.

À noter pour les comparaisons de volumes avec EMERGE publié : comparer au **volume aérien total** (`VolumeAerienTotalM3`), pas au bois fort.
