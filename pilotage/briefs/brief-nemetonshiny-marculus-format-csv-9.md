# Brief vers nemetonshiny — Marculus format CSV 9 (volumes EMERGE renommés)

> Émis le 2026-11-27 par l'orchestrateur de nemetonplateforme, sur la demande de Pascal (« fais le brief format CSV 9 pour nemeton et nemetonshiny »).
> Source : Marculus PR #82 (squash 1e7c0a0), publiée dans la release **v2026.11.4** ; brief d'origine `marculus/docs/specs/2026-11-27-correction-emerge-volumes.md` ; décisions de Pascal du 2026-11-27 (journal de nemetonplateforme).

## Ce qui change dans les fichiers que Marculus produit

**CSV de contexte (`ExportCsv.kt`), `FormatCsv;9`** (était 8) :

| Où | Avant (format ≤ 8) | Format 9 |
|---|---|---|
| En-tête | `VolumeTotalM3` (= tige + houppier, découpe 7 cm) | **`VolumeBoisFortTotalM3`** (même contenu, nom exact) |
| En-tête | — | **`VolumeAerienTotalM3`** : volume aérien total EMERGE sans découpe (`formTot · volCyl`, Deleuze 2014 p. 26) ; **vide** si le contexte n'a aucune tige cubée en EMERGE |
| En-tête | — | **`NbTigesVolumeAerien`** : nombre de tiges sommées dans `VolumeAerienTotalM3` (contexte mixte EMERGE + Schaeffer : l'aérien ne couvre que les tiges EMERGE) ; vide hors EMERGE |
| Journal (par tige) | colonne `VolumeTotalM3` (position 18) | **`VolumeBoisFortTotalM3`** à la même position |
| Journal (par tige) | — | **`VolumeAerienTotalM3`** en **dernière colonne** (23e), vide hors EMERGE |

Les autres colonnes (`VolumeTigeTotalM3`, `VolumeHouppierTotalM3`, `VolumeTigeM3`, `VolumeHouppierM3`, `AffouageLotM3`, `PartsLot`…) ne changent ni de nom ni de place.

**Sauvegarde `.marsync`** : contextes et tiges écrivent `volumeBoisFortTotalM3` au lieu de `volumeTotalM3` ; `volumeAerienTotalM3` (et `nbTigesVolumeAerien` au niveau contexte) seulement s'il y a de l'EMERGE (au niveau tige : seulement si `cubage == EMERGE`).

**CSV foncier (`CsvFoncier.kt`)** : `Total_m3` devient `BoisFortTotal_m3`, et `AerienTotal_m3` est ajouté en fin de ligne.

**Rattachement des essences** : « Chêne » saisi seul est désormais cubé comme le chêne sessile (avant : chêne rouge, par préfixe) ; 38 noms courts ont un rattachement écrit (`marculus/docs/specs/2026-11-27-rattachement-essences.md`) ; un nom inconnu est cubé par coefficient de forme (`Cubage = FORME:…`), jamais par une essence arbitraire. Les volumes **bois fort** d'une tige ne changent que si son essence change de rattachement.

## Ce que nemetonshiny doit faire

Lecteur concerné : `R/service_marculus_import.R` (champ `volumeTotalM3` du modèle de tige, l. ~60 ; `MARCULUS_VOLUMES_CONTEXTE`, l. ~114 ; lecture CSV et `.marsync`), et ses affichages (`R/mod_action_plan.R`).

1. **Lire les deux noms** : `VolumeBoisFortTotalM3` / `volumeBoisFortTotalM3` en priorité, sinon l'ancien `VolumeTotalM3` / `volumeTotalM3`, **compris comme bois fort total** (jamais comme volume aérien). C'est la règle de `LectureVolumes.kt` côté Marculus ; un fichier ancien doit continuer à s'importer à l'identique.
2. **Renommer le champ interne** `volumeTotalM3` → `volumeBoisFortTotalM3` (ou garder le nom interne mais corriger tout libellé qui dirait « volume total » : c'est du bois fort, découpe 7 cm).
3. **Lire le volume aérien total** (`VolumeAerienTotalM3` / `volumeAerienTotalM3`, et `NbTigesVolumeAerien` au niveau contexte) quand il est présent ; NA sinon (fichiers ≤ 8, contextes sans EMERGE). Si l'app l'affiche : libellé « Volume aérien total (sans découpe, EMERGE) », et en contexte mixte « sur N tige(s) EMERGE » ; ne jamais le sommer avec des volumes Schaeffer.
4. **Accepter `FormatCsv;9`** partout où le numéro de format est contrôlé (le sens d'`AffouageLotM3` dépend déjà du format, `formatCsv` conservé par tige) ; ne pas refuser un format inconnu plus récent sans message clair.
5. **CSV foncier** : si l'app le lit (rapport « Lot;Tiges;… » l. ~397-401 ou autre), accepter `BoisFortTotal_m3` et `AerienTotal_m3` en plus des anciens en-têtes.
6. Tests : un CSV format 8 (ancien nom) et un CSV format 9 (nouveaux noms, aérien présent, contexte mixte) de la même opération donnent le même bois fort ; un `.marsync` ancien et un nouveau idem ; un contexte sans EMERGE laisse l'aérien à NA. Fixtures écrites à la main d'après ce brief (ou exportées depuis Marculus v2026.11.4).

## Ce qui ne change pas

Identifiants, clés (`ContexteId`, `Uuid`, `Statut`, `DateMartelage`, `Modifie`), tarifs, affouage, parts de lot.
