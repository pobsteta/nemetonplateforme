# Mission 092 : Sen2Cor contre MAJA sur CRswir et CRre

Statut : **mesure faite sur les scènes MAJA locales de Couchey** (calcul fourni par Pascal) contre Sen2Cor de Planetary Computer, 12 dates 2024-2025. Verdict chiffré en fin de rapport. Le chemin THEIA en ligne (`--cote=les-deux`) reste non exécuté (catalogue injoignable) ; il n'est plus nécessaire pour la mesure.

## Ce qui a été fait

- `comparer.R` : deux modes. (1) `--maja-dir=<extracted/T31TFN>` : côté MAJA local, scènes déjà découpées (Lambert-93, 10 m), appariées par jour à la scène Planetary Computer de T31TFN. (2) `--cote=pc|pc-pc|les-deux` (THEIA en ligne, autotest, dispersion).
- Réutilisation de nemeton (`origin/main`, 2026.11.45.9005) : `stac_search_s2_pc`, `.dedup_s2_reprocessed`, `.s2_boa_offset` (offset -1000 des baselines >= 04.00), `.terra_rast_with_pc_retry`, `reconfort_indices()`.
- Grille = celle des scènes MAJA locales (1 150 x 886 pixels de 10 m, soit 11,5 x 8,9 km), lecture au plus proche voisin des deux côtés (20 m dupliqué).
- Masques : SCL 4 et 5 côté Sen2Cor ; CLM_R2, SAT_R2, EDG_R2 égaux à 0 côté MAJA (FRE, nodata -10000). Pixels valides des deux côtés seulement.
- Masque forêt : ESA WorldCover « arbres » ET masque feuillus OSO de l'archive (`masks/mask_oso_deciduous_compress.tif`, décalé de 0,3 m, ramené sur la grille par plus proche voisin) : 517 358 pixels.
- Sélection des dates : 30 jours ont une scène des deux côtés (Sen2Cor à moins de 15 % de nuages) ; on garde celles où au moins 60 % des pixels forestiers sont clairs côté MAJA (21), puis 12 réparties de janvier 2024 à novembre 2025.
- Statistiques : n, biais, écart-type, RMSE, corrélation, régression (Sen2Cor sur MAJA), quantiles 1 à 99 % (`ecarts_par_date.csv`, `ecarts_total.csv`, `dispersion_par_date.csv`).

## Résultats (d = Sen2Cor - MAJA, pixels forêt feuillue, 12 dates)

| | CRswir | CRre |
|---|---|---|
| biais moyen par date (min à max) | +0,011 (+0,002 à +0,022) | +0,026 (+0,005 à +0,051) |
| RMSE par date (min à max) | 0,038 (0,029 à 0,050) | 0,051 (0,039 à 0,068) |
| corrélation par date | 0,89 à 0,94 | 0,74 à 0,88 |
| pente de Sen2Cor sur MAJA (moyenne) | 0,90 | 0,83 |
| total (240 000 pixels, 20 000 par date) : biais / écart-type / RMSE / corrélation | +0,011 / 0,036 / 0,038 / 0,98 | +0,026 / 0,046 / 0,053 / 0,97 |
| total : quantiles 5 % à 95 % de d | -0,042 à +0,062 | -0,035 à +0,086 |

Le total mélange les saisons (écart-type spatial 0,19 et 0,18), d'où sa corrélation plus haute : lire les valeurs par date. Le biais de CRre est le plus fort en août-octobre 2024 et en novembre 2025 (+0,04 à +0,05), le plus faible en janvier et septembre (+0,005 à +0,012).

## Comparaison aux repères de dispersion

Du côté MAJA, sur la même forêt feuillue :
- écart-type spatial dans une date : 0,085 (CRswir) et 0,072 (CRre) en moyenne, 0,08 pour les deux en été (juin à septembre, 6 dates) ;
- variation saisonnière de la moyenne de zone, en été : écart-type 0,021 (CRswir) et 0,056 (CRre) ; sur toute l'année 0,18 (CRswir) et 0,17 (CRre).

Rapportés à ces repères :
- RMSE / écart-type spatial intra-date : environ 0,45 (CRswir) et 0,70 (CRre) : l'écart est de l'ordre de la moitié à presque toute la dispersion entre pixels d'une même date ; ce n'est pas négligeable ;
- biais d'été / variation saisonnière d'été de la moyenne : 0,014 / 0,021 (CRswir) et 0,026 / 0,056 (CRre) : le décalage moyen vaut la moitié de la variation saisonnière de la zone ;
- plancher de bruit du protocole (deux traitements Sen2Cor de la même prise de vue, autotest `pc-pc`, ci-dessous) : RMSE 0,005 à 0,027 ; l'écart Sen2Cor/MAJA est de 1,5 à 8 fois plus grand, donc il vient bien de la chaîne atmosphérique, pas du protocole de mesure.
- Les seuils internes du modèle v3 n'ont pas été lus : on ne sait pas dire de combien de classes l'écart déplace un pixel.

## Verdict (prudent)

**Non partageable tel quel.** Sen2Cor et MAJA FRE ne sont pas interchangeables pour le modèle v3 sans recalibration : biais positif et réponse comprimée (pente 0,83 à 0,90, ordonnée 0,07 à 0,28), surtout pour CRre, dont la corrélation tombe à 0,74. À confirmer par Pascal :
- si les classes du modèle sont séparées par plus que ce RMSE (0,04 à 0,07), l'écart pourrait être toléré ; seuls les seuils du modèle le disent ;
- une correction affine par date ou par saison (pente et ordonnée) réduirait le biais mais pas la dispersion résiduelle (écart-type de d 0,03 à 0,05) ;
- limites : une seule tuile et une zone feuillue de 11 x 9 km ; 12 dates ; la nature de l'écart (correction du relief FRE contre BOA non corrigée, aérosols) n'est pas démontrée ici ; sélection des dates par ciel clair côté MAJA et filtre nuages PC.

Relance : `Rscript etudes/092-sen2cor-contre-maja/comparer.R --maja-dir=<extracted/T31TFN> --oso=<masks/mask_oso_deciduous_compress.tif> --cache=<hors dépôt> --sortie=etudes/092-sen2cor-contre-maja`.

## Ce qui est mesuré côté Sen2Cor seul (zone de Couchey, 3 x 4 km, été 2023)

### Dispersion de référence (7 dates, forêt, `dispersion_sen2cor.csv`)

| Indice | moyenne de zone sur la saison | écart-type des moyennes entre dates | écart-type spatial intra-date (moyen) | p05 à p95 |
|---|---|---|---|---|
| CRswir | 0,894 à 1,011 | 0,047 | 0,119 | 0,76 à 1,23 |
| CRre | 0,574 à 0,688 | 0,038 | 0,107 | 0,46 à 0,88 |

### Plancher de bruit du protocole (autotest `pc-pc`, `autotest_pc_pc.csv`)

Même prise de vue, retraitement Sen2Cor (baseline 05.10) contre le traitement initial (05.09), 5 dates :

- biais de |0,0000| à 0,0014 ; RMSE de 0,005 à 0,011 par temps clair (n = 80 582) ;
- RMSE jusqu'à 0,023 (CRswir) et 0,027 (CRre) les jours partiellement nuageux (n = 47 735 et 70 705), corrélation >= 0,968 ;
- le pipeline (grille, offset, masques, statistiques) fonctionne donc ; ce n'est pas une mesure Sen2Cor contre MAJA.

## État du côté THEIA en ligne

Catalogue `api.stac.teledetection.fr`, `signing.` et `gate.` injoignables (000) au début et à la fin ; clés `TLD_*` absentes ; pas de voie publique de lecture. Le chemin `--cote=les-deux` n'a jamais été exécuté.
