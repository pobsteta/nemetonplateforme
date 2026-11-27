# Mission 091 — Le modèle RECONFORT v3 hors IOTA²

Étude en lecture seule, 2026-11-27. Aucun code produit dans un projet.

**Redite de la mission.** Établir, preuves à l'appui, sous quelle forme le modèle v3 de RECONFORT est enregistré et appliqué par IOTA², ce qu'il attend en entrée, et s'il peut être chargé et appliqué hors d'IOTA² (R ou Python), avec l'effort estimé.

## Verdict

**Faisable avec réserve.** Le modèle est un fichier texte de 1000 arbres de décision, lisible sans OTB ni Shark. Mais aucune bibliothèque R ou Python courante ne le charge : il faut écrire un lecteur et un prédicteur (une quarantaine de lignes). La vraie difficulté est la pile de caractéristiques : le modèle attend **134 variables** (2 indices × 67 dates sur 22 mois), alors que la table du spike de nemeton en produit 72 (2 indices × 36 pas sur un an). Les deux ne sont pas interchangeables. La réserve est donc la fidélité de la reproduction du gap-filling IOTA², qui ne peut être prouvée qu'en comparant à une sortie IOTA² réelle.

## Sources et méthode

- Amont : `https://framagit.org/fl.mouret/reconfort`, cloné en profondeur 1, commit `25198c9aebcb2027f4eea3f2777461406095463a` (2025-04-15), dans un dossier neuf du scratchpad. Aucun script amont exécuté. Cité ci-dessous `amont:<chemin>:<ligne>`.
- nemeton : `origin/main` (`479ba13ab6f03372f45a2761cf3be664eafc2331`), lu par `git show origin/main:<chemin>`. Cité `nemeton:<chemin>:<ligne>`.
- Mes deux petits scripts d'inspection (texte seul, `python3 -I`) sont décrits en fin de rapport.

## 1. Les fichiers du modèle

| Version | Fichier amont | Taille (octets) | Arbres | Variables d'entrée | Classes |
|---|---|---|---|---|---|
| v3 | `amont:models/v3/model_1_seed_0.txt` | 205 876 256 | 1000 | 134 | 3 |
| v3_early_may | `amont:models/v3_early_may/model_1_seed_0.txt` | 206 198 055 | 1000 | 104 | 3 |
| v3_chestnut | `amont:models/v3_chestnut/model_1_seed_0.txt` | 14 216 359 | 1000 | 134 | 3 |
| v3_pine | `amont:models/v3_pine/model_1_seed_0.txt` | 5 933 217 | 1000 | 134 | 2 |

- Source des tailles : `find . -printf '%s %p\n'` sur le clone. Les tailles et les MD5 (`md5sum models/*/model_1_seed_0.txt`) sont identiques au registre de nemeton (`nemeton:R/reconfort_model.R:37-70`) : v3 = `9b58a13d7659e757e32298a4da4dd70c`.
- **Format** : texte brut, ni pickle ni fichier OpenCV. Première ligne `#RFClassifier with_dictionary`, deuxième ligne `3 1 2 3` (3 classes : 1, 2, 3), troisième ligne `22 serialization::archive 18 0 0 1000 0 0 1 0` : archive texte Boost de la bibliothèque Shark, 1000 arbres (`head -c` sur `amont:models/v3/model_1_seed_0.txt`, lignes 1-3). Le modèle est donc un « SharkRF » d'OTB.
- Pas de Git LFS : le fichier est dans l'arbre du dépôt, téléchargeable directement. nemeton le récupère par `https://framagit.org/fl.mouret/reconfort/-/raw/main/models/<version>/model_1_seed_0.txt` (`nemeton:R/reconfort_model.R:77-83`), le vérifie par taille et MD5 (`:88-100`), le met en cache (`:159-200`), puis le copie dans l'espace de travail (`nemeton:R/reconfort_pipeline.R:367-375`).
- Structure interne observée (3 lignes par arbre, lignes 4 à 3003 du fichier) : une ligne de nœuds (identifiant, nombre de nœuds, puis des quadruplets attribut / seuil / fils gauche / fils droit ; une feuille a un fils gauche à 0 et un fils droit égal à son numéro de feuille), une ligne de classe par feuille, une ligne de 5 jetons. Le v3 compte 2 883 279 nœuds internes. Cette structure est déduite de l'observation, pas d'une doc Shark : un contrôle de cohérence est donné plus bas (section 4).

## 2. Comment IOTA² l'applique

- **Deux passes IOTA²** pilotées par `amont:run_map_production_reconfort.py`. Partie 1 (échantillonnage, étapes jusqu'à 7, lignes 113-125). Entre les deux, le modèle amont est **copié par-dessus** le dossier `model/` de la sortie (lignes 127-132), ce qui court-circuite l'apprentissage. Partie 2 (classification, lignes 134-141).
- **Configuration** (`amont:utils/generate_cfg_file_classif_part2_classification_2y_nov_test_1tile.py`) :
  - classifieur `sharkrf`, `classifier.sharkrf.nodesize: 25` (lignes 62-63) ; cartes de probabilité activées (lignes 75-79) ;
  - étapes `first_step: classification`, `last_step: mosaic` (lignes 46-47) ; résolution 10 m, projection EPSG:2154 (lignes 43, 48) ;
  - fenêtre d'analyse : v3, v3_chestnut, v3_pine du 1er janvier de l'année N-1 au 29 octobre de l'année N ; v3_early_may jusqu'au 31 mai (lignes 9-16 et 33) ;
  - `features: []`, `features_from_raw_dates: False` (lignes 64-65) : aucune caractéristique IOTA² par défaut ;
  - `sensors_data_interpolation: auto_date: False` (lignes 81-84) ;
  - `external_features` : module `iota2/external_features/custom_index.py`, fonctions `get_crswir get_crre`, **`concat_mode: False`** (lignes 96-101).
- **Caractéristiques d'entrée** (`amont:iota2/external_features/custom_index.py`) :
  - CRswir = B11 / (B8A + (1610-865) × (B12-B8A) / (2190-865)) (lignes 8-14) ; CRre = B5 / (B4 + (704-665) × (B6-B4) / (741-665)) (lignes 29-35). Dénominateur nul remplacé par 1.
  - Les bandes utilisées sont les bandes **interpolées** (`get_interpolated_Sentinel2_B*`, lignes 8-12 et 29-32) : l'indice est calculé **après** le gap-filling des bandes, pas avant.
  - Étiquettes `CRswir_1..N`, `CRre_1..N` (lignes 16 et 37).
- **Nombre et ordre des variables** : avec `concat_mode: False`, seuls les indices externes entrent, dans l'ordre des fonctions du `.cfg` : probablement `CRswir_1..67` puis `CRre_1..67`. Cet ordre est **déduit** du `.cfg` ; le code d'IOTA² n'est pas dans le dépôt amont et n'a pas pu être lu. Le nombre, lui, est vérifié : 134 pour le v3 et 104 pour le v3_early_may (section 4). Il correspond à 2 × 67 dates (du 2021-01-01 au 2022-10-29, 666 jours, un pas de 10 jours donne 67 dates) et 2 × 52 dates (jusqu'au 2022-05-31, 516 jours, 52 dates). Ce pas de 10 jours est le **défaut d'IOTA²** : le dépôt amont ne définit aucun `temporal_resolution` (`grep -rn temporal_resolution` sur le clone : aucune occurrence hors `imblearn`). Le recoupement 134 = 2 × 67 le rend très probable, sans le prouver.
- **Gap-filling** : interpolation linéaire des bandes masquées par les nuages sur la grille de dates, d'après la documentation IOTA² (non vérifiée ici, hors dépôt). Le rééchantillonnage 20 m vers 10 m des bandes B5, B6, B8A, B11, B12 est fait par IOTA² ; la méthode n'est pas décrite dans le dépôt amont.
- **Normalisation** : aucune trouvée. Ni le `.cfg`, ni `custom_index.py`, ni le fichier modèle ne portent de statistiques de normalisation (ni `statistics`, ni moyenne/écart-type). Les seuils des arbres sont de l'ordre de 0,3 à 1,3 (valeurs lues dans la ligne d'arbre), cohérents avec des rapports d'indices bruts.
- **Du modèle à la carte finale** : `Classif_Seed_0.tif` et `ProbabilityMap_seed_0.tif` sortent d'IOTA² dans `final/` (`amont:run_map_production_reconfort.py:144-146, 158`). Puis `mask_rasters` met à 0 tout pixel hors masque feuillus OSO, donnant `Final_Classif_masked_<année>.tif` (lignes 143-155, 148-153 pour le choix du masque ; `amont:mask_and_compress_rasters.py:7-39`). Le score continu vaut (1001 − P1 + P2 + 2·P3) / 30, avec P1, P2, P3 les trois bandes de probabilité (`amont:run_map_production_reconfort.py:163-166`, `amont:mask_and_compress_rasters.py:61-65`). nemeton a corrigé ce calcul dans sa copie (`nemeton:inst/python/reconfort/PATCHES.md`, ligne `mask_and_compress_rasters.py`).

## 3. Faisabilité hors IOTA²

### (a) Charger le modèle

- **R** : aucun paquet ne lit ce format. `ranger` (utilisé par le spike, `nemeton:R/reconfort_apprentissage.R:125`) ne peut pas l'importer.
- **Python** : `scikit-learn` ne le lit pas non plus. Ce n'est pas un pickle, donc pas de risque d'exécution de code à l'ouverture.
- **OTB / Shark** : `otbApplication` n'est pas installé dans cette session (`python3 -I -c "import otbApplication"` : `ModuleNotFoundError`) ; `iota2` non plus ; `otbcli_ImageClassifier` absent. L'essai de chargement par OTB n'a donc pas pu être fait. Passer par OTB dans conda reviendrait à garder la dépendance qu'on veut mesurer.
- **Écrire un lecteur** : possible, le format est du texte structuré (section 4). Il faut un lecteur d'environ 40 lignes. 205 Mo de texte donnent 2,9 millions de nœuds internes : lecture en Python en quelques secondes (7,5 s mesurées pour la lecture et le contrôle de structure, voir section 4). En R, la lecture est faisable mais lente et gourmande ; mieux vaut convertir une fois en tableaux compacts (un format ouvert, par exemple Parquet ou des matrices) puis prédire en Rust (noyau de nemeton) ou en R vectorisé.

### (b) Reproduire la pile de caractéristiques

Écart avec la table du spike de nemeton :

| Point | IOTA² / modèle v3 | Spike nemeton |
|---|---|---|
| Fenêtre | 1er janv. N-1 au 29 oct. N (22 mois) | Une seule année civile (`nemeton:R/reconfort_carte_spike.R:21-24, 40`) |
| Pas | 10 jours (déduit : défaut IOTA², recoupé par 134 = 2 × 67) | 36 pas par jour de l'année : `(jour - 1) %/% 10 + 1` plafonné à 36 (`nemeton:R/reconfort_apprentissage.R:5, 21-22`) |
| Nombre de variables | 134 (2 × 67) | 72 (2 × 36) |
| Ordre | CRswir puis CRre (déduit du `.cfg`) | `CRswir_01..36` puis `CRre_01..36` (`:24-25`) |
| Opération | interpoler les bandes, **puis** calculer l'indice (`custom_index.py:8-12`) | calculer l'indice, **puis** moyenner par pas et interpoler (`reconfort_carte_spike.R:21-24` ; `reconfort_apprentissage.R:32-38`) |
| Trous | interpolation linéaire des bandes sur la grille | moyenne par pas puis `stats::approx(..., rule = 2)` (`:37`) |
| Masques | gérés par IOTA² à partir des masques MUSCATE | CLM, SAT, EDG (`reconfort_carte_spike.R:21-22`) |

Conclusion : le modèle v3 **ne peut pas** recevoir la table du spike telle quelle (nombre de variables différent). Il faut une seconde fonction de pile, propre au v3 : grille de 67 dates ancrée sur le 1er janvier N-1, interpolation linéaire des bandes B4, B5, B6, B8A, B11, B12 (après masque nuages), puis indices. Le calcul des indices lui-même existe déjà (`nemeton:R/reconfort_indices.R:1-9`, mêmes formules que l'amont).

Point à confirmer avant tout calcul : le décalage exact des dates de la grille et la façon dont IOTA² interpole aux bords de la fenêtre. Ce n'est pas dans le dépôt amont.

### (c) Ce qu'il faudrait

1. Un lecteur / prédicteur du format SharkRF (Python ou conversion puis R / Rust). Environ 1 jour, test de contrôle compris.
2. Une pile de caractéristiques « v3 » depuis les scènes MUSCATE : grille de 67 dates, interpolation des bandes avant indice. Environ 2 à 4 jours, car il faut lire dans le code d'IOTA² (non dispo ici) l'ancrage exact de la grille et la règle d'interpolation.
3. Une validation par comparaison avec une sortie IOTA² réelle sur la même zone (par exemple les cartes déjà produites pour la mission 071). Sans elle, on ne peut pas dire que la reproduction est fidèle. Environ 1 jour, et elle dépend de l'existence de cette sortie.
4. Environnement : Python 3.11 et `numpy` suffisent pour le lecteur ; pas de conda IOTA² / OTB. Le calcul sur une zone réelle coûte 1000 arbres de profondeur moyenne élevée (nœuds par arbre en moyenne 5763 pour le v3) par pixel : prévoir un prédicteur compilé (Rust déjà dans nemeton) ou vectorisé, pas une boucle Python pixel par pixel.

Estimation globale : **de 4 à 6 jours** d'un développeur, la validation (point 3) étant le seul moyen de lever la réserve. Cette estimation est la mienne, elle n'a pas de source.

## 4. Essai léger fait dans la session

Deux scripts texte, lancés par `python3 -I`, sans rien exécuter du dépôt amont (ils lisent le fichier comme du texte) :

- Comptage (trois lignes par arbre, quadruplets attribut / seuil / gauche / droite) : **1000 arbres** dans chaque modèle ; indice d'attribut maximal observé **133** pour v3, v3_chestnut et v3_pine (donc **134 variables**) et **103** pour v3_early_may (**104 variables**) ; v3 : 2 883 279 nœuds internes et 2 884 279 feuilles (une feuille de plus que de nœuds internes par arbre : arbres binaires complets, 1000 feuilles de plus au total, comme attendu).
- Contrôle de structure sur les 4 modèles : les numéros de feuilles de chaque arbre sont exactement 0 à n-1, la ligne de classes a une entrée par feuille, aucun fils hors de l'arbre. Classes de feuilles : {0,1,2} pour v3, v3_early_may et v3_chestnut ; {0,1} pour v3_pine, ce qui correspond aux 3 et 2 classes du registre (`nemeton:R/reconfort_model.R:37-70`).
- Prédiction par vote de majorité des 1000 arbres sur un vecteur constant de 0,8 : v3 donne 325 / 382 / 293 votes. Ce n'est **pas** une validation de justesse : cela prouve seulement que le format est correctement parcouru. La justesse exige de comparer aux probabilités d'IOTA² / OTB sur de vraies données, ce qui n'a pas été possible ici.

## 5. Ce qui n'a pas pu être vérifié

- L'ordre exact des 134 variables (CRswir puis CRre) et le pas de 10 jours : déduits du `.cfg` et du compte de variables, mais le code d'IOTA² n'est pas disponible.
- Les dates exactes de la grille d'interpolation et la méthode de rééchantillonnage 20 m vers 10 m.
- Le calcul des probabilités par OTB / SharkRF (vote normalisé ou autre) : le fichier ne le dit pas, aucun OTB dans la session pour l'observer.
- Le chargement par OTB / Shark : bibliothèque absente ; aucun essai fait avec elle.
- La justesse d'un port : aucune sortie IOTA² de référence dans la session.
- La licence du fichier modèle : le dépôt annonce Apache-2.0 (`amont:LICENSE.md`), nemeton le redistribue déjà sous cette hypothèse (`nemeton:inst/python/reconfort/README.md`) ; non revérifié mot à mot.

## 6. Commandes lancées

- `git clone --depth 1 https://framagit.org/fl.mouret/reconfort.git` (dossier neuf du scratchpad) ; `find` et `md5sum` sur le clone.
- `git -C /home/user/nemeton fetch origin` puis `git show origin/main:<chemin>` pour `R/reconfort_model.R`, `R/reconfort_pipeline.R`, `R/reconfort_apprentissage.R`, `R/reconfort_carte_spike.R`, `R/reconfort_indices.R`, `inst/python/reconfort/README.md`, `inst/python/reconfort/PATCHES.md`.
- Deux scripts de lecture texte (`parse_rf.py`, `check_rf.py`) lancés par `python3 -I`, hors du dossier du dépôt amont. Ils ne sont pas versionnés : ils ne servent qu'à reproduire les chiffres de la section 4.
