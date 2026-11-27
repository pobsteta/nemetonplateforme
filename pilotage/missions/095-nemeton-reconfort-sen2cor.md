# Mission 095 — nemeton-reconfort-sen2cor

> Ouverte le 2026-11-27 sur la décision de Pascal (« fais le dev quand même pour reconfort avec les données sen2cor » ; question posée, réponse : **3e voie, marquée indicative**). Appuis : études 091 (modèle v3 hors IOTA², `etudes/091-modele-reconfort-v3/rapport.md`), 092 (Sen2Cor contre MAJA), 093 (classes : ~24 % de pixels qui changent, surtout vers la classe 3). Décision de l'orchestrateur sous délégation : **aucune correction radiométrique par défaut** (celle de la 093 est ajustée sur un seul site) ; correction « biais seul » disponible en paramètre, désactivée.
> Dépôt : `nemeton`. La branche de session porte la PR #710 (release, en attente de THEIA) : travailler sur une **branche locale** `reconfort-sen2cor` partie de `origin/main` (479ba13), **sans pousser** ; l'orchestrateur la poussera sur `ccr-b52c1910-gjp34w` après la fusion de #710. Pas de release.

## Mission

**En une phrase :** Ajouter à RECONFORT une troisième voie d'acquisition `acquisition = "sen2cor"` qui, sans IOTA² ni THEIA ni GEODES, applique le modèle amont v3 (lecteur et prédicteur SharkRF en R, ou Rust si le gain le justifie) à une pile de 134 caractéristiques (CRswir puis CRre sur 67 dates) construite depuis les scènes Sentinel-2 Sen2Cor de Planetary Computer (le cache de FAST/FORDEAD), et produit les mêmes sorties que la voie IOTA² (classes, votes/probabilités, masque), marquées partout « RECONFORT sur Sen2Cor, non validé, indicatif ».

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. **Lecteur et prédicteur SharkRF** (`R/reconfort_sharkrf.R`) : lecture du fichier texte `model_1_seed_0.txt` (`#RFClassifier with_dictionary`, archive Boost, 1000 arbres), prédiction vectorisée par blocs de pixels → votes par classe (somme 1000) et classe = argmax, comme `ProbabilityMap_seed_0` d'IOTA². Lecture mise en cache (le fichier fait 205 Mo). Tests sur un petit modèle fabriqué + un test qui, si le vrai modèle v3 est en cache, vérifie la cohérence (1000 arbres, 134 variables).
2. **Pile de caractéristiques v3** (`reconfort_caracteristiques_v3()`) : grille de 67 dates ancrée sur `start_date` (1er janvier N-1) au pas de 10 jours (règle lue dans l'étude 091), bandes interpolées linéairement puis CRswir et CRre (`reconfort_indices()`), ordre CRswir puis CRre ; règles de bord explicites et paramétrables ; rééchantillonnage 20 m → 10 m (plus proche voisin par défaut, c'est ce qui reproduit le mieux IOTA² dans la 091). Source des scènes : le cache Sentinel-2 de FAST/FORDEAD (Planetary Computer `sentinel-2-l2a`, offset BOA, masque SCL 4/5), réutilisé et non recopié ; si une scène manque, la chercher comme le fait déjà le cache.
3. **Voie `acquisition = "sen2cor"`** dans `run_reconfort_dieback()` : choisie explicitement, **ou en dernier recours** quand la voie fenêtre (THEIA) et la voie archive (GEODES) ont toutes deux échoué ou ne sont pas disponibles (avertissement `nemeton_reconfort_repli_sen2cor` qui dit les deux causes) ; pas d'environnement conda requis. Sorties aux mêmes noms et formats que la voie IOTA² (`Final_Classif_masked_<année>.tif`, carte de votes/probabilités, masque feuillus), plus un champ `source_reflectances = "sen2cor"` et `validee = FALSE` dans `run_meta.json`, et un attribut/tag GeoTIFF qui le dit. Paramètre `correction_sen2cor = c("aucune", "biais")` (défaut `"aucune"` ; `"biais"` applique les biais moyens de la 092, documentés comme ajustés sur Couchey).
4. **Validation contre le vrai run IOTA² de Pascal** (données : `/tmp/claude-0/-home-user/4ded9d2a-b1a5-536b-b61c-a2885923659c/scratchpad/zone63/ext/output_zone_63/`, lecture seule, ne pas commiter) : (a) avec les scènes MAJA du run en entrée, le prototype reproduit la carte IOTA² à X % (comparaison pixel à pixel sur tout le masque, pas 30 pixels) ; (b) avec Sen2Cor, le taux de changement de classe ; les deux chiffres dans le rapport et dans NEWS. Le test unitaire n'en dépend pas (données hors dépôt) ; un script `data-raw/` rejoue la validation.
5. NEWS (« indicatif, non validé », chiffres de la validation), PLAN.md, cycle dev (`2026.11.46.9000` après la release ; en attendant, `2026.11.45.9006` et l'orchestrateur ajustera).

## Cas limites (tests, sans réseau)

1. Prédicteur sur un modèle fabriqué de 3 arbres : votes et classe attendus écrits à la main.
2. Pile de caractéristiques : 134 colonnes dans l'ordre, interpolation et bords sur une série fabriquée.
3. `acquisition = "sen2cor"` : ni conda ni THEIA ni GEODES appelés (simulés) ; `run_meta.json` porte `source_reflectances = "sen2cor"`, `validee = FALSE`.
4. Repli : fenêtre et archive simulées en échec → avertissement de classe `nemeton_reconfort_repli_sen2cor`, voie sen2cor utilisée ; une seule des deux en échec → pas de repli sen2cor.
5. Contre-épreuve sur `origin/main`.

## Ce qui est attendu

Code, tests, contrôle non ASCII, tests des fichiers touchés (`test-reconfort-*.R`), `.claude/test-command`, rapport de validation (chiffres), commits **locaux** sur `reconfort-sen2cor` (Conventional Commits, français) ; sha. Ne pas pousser.

## L'Homme

`dev`, worktree nemeton ; relu par le `relecteur`. Budget 6 $ (mission de plusieurs étapes ; rendre un point d'étape si le budget s'épuise). La partie app (choix de la voie, marquage « indicatif » à l'écran) sera une mission nemetonshiny ensuite.
