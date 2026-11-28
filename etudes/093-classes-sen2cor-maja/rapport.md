# Mission 093 : classes du modèle v3, MAJA contre Sen2Cor

Étude en lecture seule, 2026-11-27. Aucun code produit dans un projet ; rien dans `nemeton` n'a été modifié.

**Redite de la mission.** Sur 1 000 pixels feuillus de Couchey, appliquer le prédicteur prototype du modèle v3 (étude 091) à deux piles de 134 caractéristiques bâties de la même façon, l'une avec les scènes MAJA du run de Pascal, l'autre avec les scènes Sen2Cor de Planetary Computer, puis mesurer la part de pixels qui changent de classe et l'écart des votes, en la situant par rapport au désaccord prototype / IOTA² déjà présent.

## Verdict (prudent)

**Non partageable tel quel, sans que l'étude permette de chiffrer l'écart de justesse.** Avec des réflectances Sen2Cor, **24,3 % des pixels changent de classe** (IC 95 % : 21,7 à 27,1 %), contre **19,6 %** (17,3 à 22,2 %) de désaccord entre le prototype nourri de MAJA et IOTA². Au sens strict de la fiche (« nettement supérieur »), le seuil n'est pas franchi : 24,3 contre 19,6, les intervalles se touchent presque. Mais le « bruit » de référence est lui-même grand et orienté, et l'épreuve la plus parlante est appariée : la classe Sen2Cor s'accorde avec IOTA² sur **69,7 %** des pixels, la classe MAJA sur **80,4 %** (McNemar : 152 pixels perdus contre 45 gagnés, z = 7,6). Aucune correction affine simple de la 092 ne ramène l'accord au niveau MAJA (de 60,5 à 76,3 %). Un pixel sur quatre qui change de classe n'est pas un détail ; il faudrait réentraîner ou recalibrer le modèle sur Sen2Cor, ou accepter ce flou en le disant. Rien ici ne dit laquelle des deux classes est juste : il n'y a pas de vérité terrain.

## Ce qui a été mesuré

- **Échantillon** : 1 000 pixels tirés au hasard (graine 93) parmi les 520 591 pixels du masque feuillus OSO du run (`Final_Classif_masked_2025.tif > 0`), grille 10 m Lambert-93 du run (1150 × 886). Le masque WorldCover de la 092 n'est pas ajouté, la fiche demandant le masque OSO. Liste des cellules, coordonnées et votes IOTA² dans `pixels.csv` ; résultats par pixel dans `classes_par_pixel.csv`.
- **Même grille de 67 dates** (`Sentinel2_T31TFN_interpolation_dates.txt` : 20240101 à 20251022, pas de 10 jours), **même interpolation linéaire** des six bandes (B4, B5, B6, B8A, B11, B12) avec prolongation constante aux bords, puis CRswir et CRre (formules de `custom_index.py`), ordre CRswir_1..67 puis CRre_1..67. Seule la source des réflectances change. Bandes 20 m prises au plus proche voisin des deux côtés (meilleur essai de la 091).
- **MAJA** : les 203 scènes du run (`s2_download/extracted/T31TFN/`), masque = bandes valides et CLM R1 et R2, EDG R1, SAT R1 et R2 égaux à 0 (celui de la 091). Sur la zone, 59 jours seulement ont au moins un pixel clair ; médiane de 40 observations claires par pixel (33 à 46).
- **Sen2Cor** : les 169 scènes de la tuile T31TFN de Planetary Computer du 2024-01-01 au 2025-12-31, après dédoublonnage des retraitements, sans seuil de nuages de scène (le masque est SCL 4 et 5, par pixel), offset BOA retiré (fonctions de nemeton et de la 092, relues, non modifiées). 103 jours ont au moins un pixel clair ; médiane de 53 observations claires par pixel (37 à 62). La période va au-delà du 29 octobre 2025 pour couvrir celle des scènes MAJA du run (jusqu'au 2025-12-30) ; une variante tronquée au 29 octobre des deux côtés donne le même résultat (24,1 %).
- **Prédicteur** : `shark_rf.py` (lecteur du format SharkRF et prédicteur vectorisé, 1000 arbres, vote de majorité). Le code de la 091 n'avait pas été commité ; il est repris du scratchpad et commité ici. **Vérifié avant emploi** (`reproduction_091.txt`) : sur les 30 pixels de la 091, votes identiques à ceux de la 091, 25 pixels sur 30 de même classe qu'IOTA², écart absolu moyen des votes 70,6. Le modèle utilisé est celui du run, `model_1_seed_0.txt` (identique à celui de l'amont, cf. 091 § 7.1).

## Résultats (1 000 pixels ; `resume.csv`, matrices dans `confusion_*.csv`)

| Comparaison | Part de pixels qui changent de classe (IC 95 %) | Écart absolu moyen des votes (sur 1000) |
|---|---|---|
| MAJA → Sen2Cor (brut) | **24,3 %** (21,7 à 27,1) | 60,3 |
| prototype sur MAJA → IOTA² (bruit du prototype) | **19,6 %** (17,3 à 22,2) | 64,9 |
| prototype sur Sen2Cor → IOTA² | 30,3 % (27,5 à 33,2) | 96,0 |
| MAJA → Sen2Cor corrigé, inverse de la régression par date (092, moyenne des 12 dates) | 29,8 % (27,0 à 32,7) | 78,6 |
| MAJA → Sen2Cor corrigé, inverse de la régression totale (092) | 22,1 % (19,6 à 24,8) | 54,2 |
| MAJA → Sen2Cor corrigé, biais moyen seul (092) | 20,8 % (18,4 à 23,4) | 52,8 |
| MAJA → Sen2Cor corrigé, régression inverse MAJA sur Sen2Cor | 31,7 % (28,9 à 34,6) | 73,0 |

Matrice de confusion MAJA (lignes) × Sen2Cor (colonnes), nombre de pixels :

| | classe 1 | classe 2 | classe 3 |
|---|---|---|---|
| classe 1 | 264 | 39 | 47 |
| classe 2 | 19 | 62 | 101 |
| classe 3 | 15 | 22 | 431 |

- Le changement est **orienté** : la classe 3 passe de 468 à 579 pixels, la classe 2 de 182 à 123 (101 des 182 pixels de classe 2 passent en classe 3), la classe 1 de 350 à 298. Les votes de la classe 3 gagnent 20 sur 1000 en moyenne, ceux de la classe 1 en perdent 20.
- Le changement se concentre sur les pixels déjà indécis : 46 % de changement parmi les 399 pixels dont l'écart de votes entre les deux premières classes est inférieur à 100, 10 % parmi les 601 autres.
- **Le « bruit » du prototype est systématique, pas aléatoire** : le prototype sur MAJA range 350 pixels en classe 1 là où IOTA² en range 501 (`confusion_maja_iota2.csv`, `repartition_classes.csv`). Le prototype ne reproduit donc pas exactement le gap-filling d'IOTA² (091 § 7.3) ; le chiffre de 19,6 % est un plancher de précision de l'outil, pas un bruit de mesure qu'on moyennerait.
- **Test apparié contre IOTA²** (`mcnemar.csv`) : accord de la classe avec IOTA² de 80,4 % pour MAJA et de 69,7 % pour Sen2Cor brut. Avec les corrections : 73,1 % (régression par date), 76,3 % (régression totale), 75,3 % (biais seul), 60,5 % (régression inverse). Aucune n'égale MAJA, toutes restent significativement en dessous (z de 3,0 à 12,2).
- **Effet de la correction affine demandée par la fiche** (pentes et ordonnées de la 092 appliquées aux indices Sen2Cor interpolés, en inversant S2C = a + b·MAJA) : **elle n'aide pas** avec les coefficients moyens par date (29,8 %, pire que le brut) ; elle aide un peu avec la régression totale de la 092, dont la pente est proche de 1 (22,1 %) ou avec le seul retrait du biais moyen (20,8 %). Raison probable, non démontrée : les pentes par date de la 092 (0,90 et 0,83) sont tirées vers le bas par le bruit de MAJA dans la régression, et leur inversion étire trop les indices ; la régression directe dans l'autre sens, qui corrige ce défaut, donne pourtant 31,7 %, de sorte que l'explication n'est pas établie. Un biais d'indice de 0,011 (CRswir) et 0,026 (CRre) suffit donc à déplacer environ un pixel sur cinq, ce qui montre la sensibilité du modèle à un petit décalage radiométrique.
- **Contrôles** : (a) MAJA restreint aux jours où Sen2Cor a une observation claire : 0,9 % de changement, 3,7 de différence de votes (les jours MAJA sont presque tous des jours Sen2Cor, contrôle de cohérence). (b) Sen2Cor restreint aux jours MAJA, puis comparé à MAJA : **26,9 %**, donc l'écart n'est pas dû à la plus forte densité de dates de Sen2Cor ; il vient de la radiométrie et des masques. (c) Sen2Cor aux jours MAJA contre Sen2Cor complet : 9,2 %, l'échantillonnage plus dense déplace donc à lui seul un pixel sur onze. (d) Tronquer les observations au 29 octobre change 1,7 % des classes MAJA ; MAJA contre Sen2Cor, tous deux tronqués : 24,1 %.

## Limites

- **Un seul site** (Couchey, tuile T31TFN), une seule fenêtre de 22 mois, forêt feuillue (masque OSO) ; 1 000 pixels tirés d'un million, donc l'incertitude d'échantillonnage est donnée par les intervalles (Wilson), mais non l'incertitude de site.
- **Prototype imparfait** : 19,6 % de désaccord orienté avec IOTA² (091 § 7). Les parts de changement ci-dessus sont celles du prototype, pas d'IOTA² ; il se peut qu'IOTA² réagisse autrement à un même décalage. Le prédicteur compare en double précision ; OTB peut convertir les caractéristiques en simple précision (non vérifié, effet probablement faible).
- **Aucune vérité terrain** : un changement de classe n'est pas une erreur de classe. L'étude mesure une instabilité, pas une justesse. La sémantique des classes 1, 2 et 3 n'est pas lue ici.
- **Radiométrie et masques confondus** : le masque nuages MAJA (CLM, SAT, EDG) et celui de Sen2Cor (SCL 4 et 5) ne retiennent pas les mêmes observations (53 contre 40 observations par pixel en médiane). Le contrôle (b) montre que l'écart persiste à jours égaux, sans séparer radiométrie et masque.
- **Correction affine ajustée sur l'échantillon qui la teste** : les coefficients viennent de 12 dates claires de la 092, sur le même site, appliqués ici à des indices interpolés (et non à des indices par scène). Ce n'est pas une validation de la correction.
- La bande 20 m est prise au plus proche voisin des deux côtés, comme en 091 et 092 ; le rééchantillonnage réel d'IOTA² n'est pas connu.

## Fichiers et relance

`shark_rf.py` (lecteur et prédicteur), `reproduire_091.py` (vérification), `echantillon_et_maja.R` (tirage et séries MAJA), `sen2cor_pixels.R` (séries Sen2Cor, réutilise `../092-sen2cor-contre-maja/comparer.R`), `exporter_series.R`, `classes.py` (piles, prédiction, statistiques). Sorties : `resume.csv`, `confusion_*.csv`, `repartition_classes.csv`, `mcnemar.csv`, `classes_par_pixel.csv`, `parametres.txt`, `reproduction_091.txt`, `pixels.csv`. Données intermédiaires (hors dépôt, non versionnées) : séries par scène et pixel (≈ 45 Mo), modèle converti en `.npz` (33 Mo).

```
export LANG=C.UTF-8 LC_ALL=C.UTF-8
python3 -I shark_rf.py convertir <output_zone_63>/results/iota2_results_classif_labels-z63-S2_2025/model/model_1_seed_0.txt <w>/v3.npz
Rscript echantillon_et_maja.R <output_zone_63> <w> 1000 93
Rscript sen2cor_pixels.R ../092-sen2cor-contre-maja/comparer.R <w> <une scène MAJA *_FRE_B4.tif> 2024-01-01 2025-12-31 <w>/cache_pc 4   # ≈ 10 min
Rscript exporter_series.R <w> && (maja : series_maja.rds -> series_maja.csv, de même sen2cor)
python3 -I classes.py <w> <w>/v3.npz <…/Sentinel2_T31TFN_interpolation_dates.txt> ../092-sen2cor-contre-maja/ecarts_par_date.csv ../092-sen2cor-contre-maja/ecarts_total.csv .
```

Les scripts R se lancent avec `R_LIBS` pointant la bibliothèque contenant nemeton 2026.11.45.9005 (celle de la 092). Aucun fichier des données non fiables n'a été exécuté : rasters et textes lus par `terra` et par un analyseur de texte.

## Ce qui reste à décider (Pascal)

Si Sen2Cor doit nourrir le v3 : réentraîner ou recalibrer le modèle sur Sen2Cor (le plus sûr), ou bien étendre cette mesure à une autre tuile et à un jeu de vérité terrain avant de trancher. L'étude ne tranche pas.
