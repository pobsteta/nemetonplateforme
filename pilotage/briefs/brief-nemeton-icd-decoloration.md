# Brief vers nemeton — Indicateur composite de décoloration (ICD)

> De : orchestrateur de nemetonplateforme, le 2026-11-26, sur la demande de Pascal du même jour.
> Source de la méthode : « Suivi de la décoloration anormale du feuillage, forêts publiques et privées de Bourgogne-Franche-Comté — note de méthode », version 2 du 29 octobre 2026 (scripts `suivi_decoloration_bfc.R`, `rapport_decoloration_bfc.R`), §§ 3 à 8 et 15. Copie de la note à joindre à la spec (`specs/071-icd-decoloration/methode_suivi_decoloration_bfc.pdf`).
> Pendant : `brief-nemetonshiny-icd-decoloration.md` (onglet ICD de l'app). Ordre : cœur d'abord, release, puis l'app.

## Ce que Pascal a décidé (2026-11-26)

1. **FAST reste tel qu'il est.** L'ICD ne le remplace pas et ne le modifie pas.
2. Un **nouveau calcul, l'ICD**, vient s'ajouter aux trois méthodes du suivi sanitaire (FAST, FORDEAD, RECONFORT), et se **compare à FAST**.
3. Les **poids de la formule ICD sont modifiables** (dans l'app : Sources & paramètres). Le cœur les reçoit donc en argument ; les valeurs de la note sont les **défauts**.

## Ce qu'on attend du cœur

Une spec `specs/071-icd-decoloration/spec.md` (numéro à confirmer au moment de l'écrire) puis l'implémentation, à l'échelle d'une **zone de suivi** (`monitoring_zone`), comme FAST/FORDEAD/RECONFORT, et non de la région entière.

### 1. Données et indices (note §§ 3-4)

- Sentinel-2 L2A, **9 bandes** utiles : B03, B04, B05, B06, B07, B08, B8A, B11, B12, plus la couche **SCL** ; résolution **20 m**. Passer par le cache commun et le lecteur fenêtré de FAST (`ingest_s2_raw_bands_to_cache()`, `.get_s2_band_raster()`), en ajoutant les bandes manquantes à l'union de `.S2_STAC_BANDS` sans changer ce que lit FAST.
- Réflectance : correction d'offset scène par scène, **déjà présente** (`.S2_BOA_OFFSET`, `.s2_boa_offset()`, spec 055) : la réutiliser.
- Masque : SCL classes **0, 1, 3, 8, 9, 10, 11** (note § 4 ; différent de `.RECONFORT_SCL_MASK_CLASSES`, à ne pas confondre).
- Indices par image :

| Indice | Formule | Sens en dépérissement |
|---|---|---|
| GRVI | (B03 − B04) / (B03 + B04) | baisse |
| CIre | B07 / B05 − 1 | baisse |
| CRSWIR | B11 / (B8A + (B12 − B8A) × 0,56) | hausse |
| CRre | B05 / (B04 + (B06 − B04) × 0,51) | hausse |
| NDVI | (B08 − B04) / (B08 + B04) | baisse |

  CRSWIR et CRre existent déjà (`reconfort_indices()`, noyau Rust avec repli R, ADR 0003) : **les réutiliser**, vérifier que les coefficients 0,56 / 0,51 sont bien ceux-là, ne pas dupliquer.

### 2. Composite mensuel (§ 5)

- Avril à octobre, chaque année depuis 2017 : `x(pixel, mois, année) = médiane des valeurs valides des images du mois`.
- Scènes à moins de 70 % de nuages ; un mois sans image valide reste vide (NA).
- Mois en cours : gardé tel quel tant qu'il n'est pas terminé depuis 5 jours (`mois_en_cours = "garder"`).
- Écriture atomique (fichier temporaire puis renommage) ; un composite illisible est détecté, supprimé et refait au lancement suivant.

### 3. Anomalie standardisée (§ 6)

- `z = (x − médiane des autres années) / max(MAD × 1,4826 ; plancher)`, même pixel, même mois, toutes les autres années (« une année retirée »), ou une liste d'années saines fournie (`annees_reference`).
- Au moins **4 années de référence** valides, sinon NA.
- Planchers : 0,01 (GRVI, CRre, NDVI), 0,05 (CIre), 0,02 (CRSWIR).
- Un pixel est retiré du calcul à partir du mois de sa coupe rase (SUFOSAT, quand la couche est disponible — `sufosat_*` du cœur ; sinon le dire, ne pas bloquer).

### 4. ICD (§ 7)

`ICD = w1·z(GRVI) + w2·z(CIre) − w3·z(CRSWIR) − w4·z(CRre) + w5·z(NDVI)`, calculé **seulement sur les mois sensibles** de l'essence. Négatif = plus dégradé que la normale.

Défauts (fonction exportée `icd_poids_defaut()`, data.frame essence × indice + mois) :

| Essence | GRVI | CIre | CRSWIR | CRre | NDVI | Mois suivis |
|---|---|---|---|---|---|---|
| Chêne | 0,15 | 0,25 | 0,15 | 0,20 | 0,25 | juin – août |
| Hêtre | 0,30 | 0,25 | 0,15 | 0,15 | 0,15 | juillet – août |
| Sapin / épicéa | 0,35 | 0,15 | 0,35 | — | 0,15 | juin – octobre |
| Douglas | 0,45 | 0,15 | 0,25 | — | 0,15 | avril – septembre |

- **Les poids sont un argument** (`poids = icd_poids_defaut()`), validé : 4 essences, 5 indices, valeurs ≥ 0, **CRre nul pour les résineux** (la note : CRre seulement pour les feuillus). La somme vaut 1 dans les défauts ; ce que fait le cœur d'une somme ≠ 1 est une question ouverte (voir plus bas).
- Essence par pixel : BD Forêt V2, peuplements purs (TFV FF1G01-01 chêne, FF1-09-09 hêtre, FF2G61-61 sapin/épicéa, FF2-64-64 douglas), avec la lisière de 10 m retirée (§ 18, `buffer_interieur`). Les autres pixels n'ont **pas** d'ICD (statut dit, pas de valeur inventée).

### 5. Alerte annuelle et niveaux (§ 8)

- Classes : **Alerte** = ICD < −2 pendant au moins 2 mois valides consécutifs (date d'alerte = premier mois) ; **Surveillance** = ICD < −1,5 au moins un mois ; **Normal** sinon.
- Niveaux 0 à 4 : 0 normal ; 1 surveillance ; 2 alerte ; 3 alerte forte (alerte et ICD minimal < −3) ; 4 alerte répétée (alerte cette année et sur la saison complète de l'année précédente).
- Indice « à date » : chaque année recalculée sur les mêmes mois que ceux disponibles l'année en cours (un mois en cours n'est pris que s'il est entamé depuis au moins 20 jours).
- Seuils (−1,5 / −2 / −3) et persistance (2) en arguments, défauts de la note. `niveaux_decoloration()` existe déjà dans `data-raw/etude_fast_decoloration/fonctions_comparaison.R` : le reprendre dans `R/` plutôt que réécrire.

### 6. Sorties et accès (pour l'app)

- Rasters sur disque (ADR-002), par zone : composites, z par indice, ICD mensuel, classe et niveau annuels ; cache et reprise comme FAST.
- Masquage à l'UGF de la zone (`apply_zone_mask = TRUE`, parité avec les trois autres méthodes, ADR-013 A5/A6).
- Une fonction de **série d'un pixel** (pour le clic sur la carte de l'app) : pour un point, par année et par mois, valeur brute et z des 5 indices, ICD, mois sensibles, seuils, classe et niveau de l'année. Coût court (lecture locale des rasters déjà calculés, pas de réseau).
- Un événement de progression `icd:*` dans le même `progress_callback` que `s2:*`, avec un événement terminal **même en cas d'arrêt** (`icd:cancelled`) : l'app doit pouvoir retirer sa notification (leçon de la mission 072).
- Alertes : écrire les alertes annuelles dans la table `alert` avec un `alert_type` propre (`icd_decoloration`) si la base est là ; sinon rasters seuls.

### 7. Comparaison avec FAST (décision 2)

Une fonction `comparer_fast_icd(zone, annee)` (nom à confirmer) : croisement des classes FAST 0-4 et des niveaux ICD 0-4 en surfaces, accord global et kappa (indicateur), et la même comparaison **à surface alertée égale** que l'étude (`data-raw/etude_fast_decoloration/`, critère tranché dans la mission 045). Réutiliser `classes_fast()` de l'étude.

## Tests attendus (sans réseau)

Formules des 5 indices sur valeurs connues ; composite médiane et mois vide ; z avec plancher, année retirée, moins de 4 années → NA ; pixel coupé retiré dès le mois de coupe ; ICD avec poids par défaut et poids modifiés (le résultat change) ; CRre ignoré pour les résineux ; règles d'alerte (persistance, date d'alerte, 5 niveaux, indice à date) ; poids invalides refusés avec message ; série d'un pixel ; comparaison FAST × ICD sur petites cartes fabriquées. Aucun caractère non ASCII dans le code R.

## Questions ouvertes pour Pascal (à trancher avant la spec)

1. Poids dont la somme n'est pas 1 : refuser, renormaliser, ou accepter tels quels ?
2. Seuils, persistance et mois suivis : modifiables eux aussi, ou seulement les poids ?
3. Pixels hors des 4 peuplements purs : pas d'ICD (proposé), ou poids génériques feuillus/résineux ?
4. ICD dans « Tout calculer » : oui (proposé, après RECONFORT) ou non ?
