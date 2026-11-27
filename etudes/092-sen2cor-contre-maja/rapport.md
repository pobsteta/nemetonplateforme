# Mission 092 : Sen2Cor contre MAJA sur CRswir et CRre

Statut : **le côté MAJA n'a pas été mesuré** (catalogue THEIA injoignable). Le script est prêt et testé côté Planetary Computer ; l'écart Sen2Cor - MAJA reste à mesurer.

## Ce qui a été fait

- `comparer.R` : zone par défaut = forêt de Couchey (bbox 4,935 / 47,215 / 4,975 / 47,250, tuile T31TFN, 314 x 397 pixels de 10 m en Lambert-93), été 2023 (1er juin au 31 août), scènes à moins de 30 % de nuages.
- Réutilisation de nemeton (`origin/main`, 2026.11.45.9005), sans réécriture : `stac_search_s2_pc`, `.dedup_s2_reprocessed`, `.s2_boa_offset` (offset -1000 des baselines >= 04.00), `.terra_rast_with_pc_retry`, signature PC, `.reconfort_fenetre_lister` et `_signer` pour THEIA, `reconfort_indices()` (exporté).
- Même grille pour les deux côtés, lecture au plus proche voisin (10 m natif, 20 m dupliqué).
- Masques : SCL 4 et 5 côté Sen2Cor ; CLM_R2, SAT_R2, EDG_R2 égaux à 0 côté MAJA (bandes FRE, nodata -10000). Seuls les pixels valides des deux côtés comptent.
- Masque forêt : ESA WorldCover 2021, classe 10 (65 % de la zone, soit 80 582 pixels). C'est « arbres », pas « chênaie » : BD Forêt n'est pas lue ici.
- Statistiques par date et par indice : n, biais, écart-type, RMSE, corrélation, pente, ordonnée, quantiles 1 à 99 %.

## THEIA

- `api.stac.teledetection.fr`, `signing.` et `gate.` : pas de réponse (000) au début et à la fin ; aucune clé `TLD_*` dans le conteneur.
- Pas de voie publique : les objets S3 de MESO@UM ne se lisent que signés par la passerelle, qui exige la clé (voir `theia_stac.R`). Le catalogue `catalogue.theia.data-terra.org` répond (200) mais ne donne pas les rasters.
- Donc : aucun chiffre MAJA. Le chemin `les-deux` (appariement par jour, ses assets et ses masques) n'a **pas** pu être exécuté ; il est écrit d'après les clés d'assets de `reconfort_fenetre.R` (B04, B8A, CLM_R2...) et devra être confirmé au premier passage.

## Ce qui est mesuré côté Sen2Cor

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

## Comparaison à l'ordre de grandeur des classes

Les seuils internes du modèle v3 ne sont pas lus ici. À défaut : un écart RMSE Sen2Cor/MAJA serait « négligeable » s'il restait de l'ordre du plancher ci-dessus (quelques 0,01) et bien en dessous de la dispersion spatiale d'une date (0,11 à 0,12) et de la variation saisonnière de la moyenne de zone (écart-type 0,04 à 0,05). Un biais constant de quelques centièmes serait déjà du même ordre que la variation saisonnière.

## Verdict

**À confirmer.** On ne peut pas dire si le cache Sen2Cor peut nourrir RECONFORT : l'écart entre deux chaînes d'atmosphère différentes (Sen2Cor/MAJA, FRE plate contre BOA non corrigée du relief) peut dépasser largement l'écart entre deux traitements Sen2Cor, qui ne mesure que le plancher. Limites : une seule zone, un seul été, masque « arbres » et non chênaie, pas d'accès aux seuils du modèle.

## Ce que Pascal lance chez lui

Avec nemeton installé (version à jour), `~/.Renviron` contenant `TLD_ACCESS_KEY` et `TLD_SECRET_KEY` et le catalogue THEIA de nouveau joignable :

```
Rscript etudes/092-sen2cor-contre-maja/comparer.R --cote=les-deux --cache=$HOME/cache092 --sortie=etudes/092-sen2cor-contre-maja
```

Sorties : `ecarts_par_date.csv` et `dispersion_par_date.csv` (CSV légers, rien de lourd à commiter). Ajouter `--max-scenes=2` pour un premier essai.
