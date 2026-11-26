# Mission 076 — nemeton-reconfort-carte-spike

> Ouverte le 2026-11-26 à la demande de Pascal (« écris la petite mission pour iota2 »), suite de la mission 071 (comparaison IOTA² contre spike) et de la spec 070 (§ « Ce qui manque » : « application du modèle à une zone, écriture de la carte (le spike s'arrête aux tables de séries) »).
> Dépôt : `nemeton`, branche `ccr-b52c1910-gjp34w`, **après fusion de la PR #705** (mission 071). Pas de release.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire produire au spike RECONFORT de la mission 060 une carte de classes (1 saine, 2 dépérissante, 3 très dépérissante) sur la zone et la grille exactes de la carte IOTA², à partir des scènes déjà découpées par la chaîne RECONFORT, pour que `comparer_cartes.R` (mission 071) compare enfin les deux méthodes pixel à pixel.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Attendu

1. **Une fonction `reconfort_carte_spike(modele, scenes_dir, annee, gabarit, ...)`** (nom à confirmer, interne ou exportée selon l'usage ; si exportée : `_pkgdown.yml`, test) qui :
   - lit les scènes MUSCATE déjà découpées à la zone (`extracted/<tuile>/<scène>/`, l'arborescence que les voies archive et fenêtre écrivent, mission 071), applique les masques MAJA (nuages, ombres, saturation, bord) comme la chaîne IOTA² le fait pour ses indices ;
   - calcule CRswir et CRre par scène avec `reconfort_indices()` (Rust ou repli R) ;
   - construit, **par pixel**, exactement les caractéristiques qu'utilise `reconfort_entrainer()` (36 pas de 10 jours × 2 indices, même interpolation et mêmes règles de trous que `.reconfort_caracteristiques()` : lire et réutiliser, ne pas réécrire) ;
   - applique le modèle (`reconfort_predire()` ou son cœur vectorisé) par blocs de pixels, mémoire bornée (le budget de blocs de la chaîne RECONFORT, `.reconfort_chunk_px_budget()`, sert de modèle) ;
   - écrit un GeoTIFF de classes **aligné au pixel près sur `gabarit`** (la carte IOTA² de la même zone et de la même année : même CRS, même origine, même résolution, même étendue), `NA` hors forêt/masque et là où la série est inutilisable ;
   - applique les masques du spike (`reconfort_masquer()` : hors chênaie, coupes rases à partir de l'année de coupe).
2. **Un script `data-raw/comparaison_reconfort/carte_spike.R`** qui enchaîne : modèle (fichier `.rds` d'un `reconfort_modele`), dossier des scènes, année, carte IOTA² comme gabarit → carte du spike → appel de `comparer_cartes.R` ; et le `README.md` de la mission 071 complété (commande exacte à lancer chez Pascal, durées attendues).
3. **Un rappel écrit dans le README et dans la sortie** : tant que le modèle n'est entraîné que sur des étiquettes `synth_` ou propagées, l'accord avec IOTA² mesure une **ressemblance**, pas une **justesse** ; la spec 070 (§ « Critère pour amender la spec 021 ») reste la règle (placettes de terrain tenues à l'écart).

## Les sources

`nemeton/CLAUDE.md` ; spec 070 ; `R/reconfort_apprentissage.R` (`reconfort_entrainer`, `reconfort_predire`, `.reconfort_caracteristiques`), `R/reconfort_indices.R`, `R/reconfort_masques.R`, `R/reconfort_outputs.R` (masques MAJA/SCL), `R/reconfort_crop.R`, `R/reconfort_fenetre.R`, `R/reconfort_comparaison.R`, `data-raw/comparaison_reconfort/` (mission 071) ; scripts IOTA² vendus (`inst/…/iota2/…`, `custom_index.py`) pour l'ordre des opérations (masques puis indices puis interpolation).

## Cas limites (un test chacun, sans réseau, jeux `synth_`)

1. Carte alignée : même `ext`, `res`, `crs` et origine que le gabarit ; un gabarit décalé d'un demi-pixel est refusé avec un message clair.
2. Égalité table / carte : pour quelques pixels, la classe écrite dans la carte est celle que `reconfort_predire()` rend sur la série du même pixel construite en table (même modèle, même seed).
3. Pixel masqué (nuage sur toutes les dates utiles, hors chênaie, coupé avant l'année) → `NA`.
4. Mémoire bornée : une zone plus grande que le budget passe par plusieurs blocs et donne la même carte qu'en un bloc.
5. Modèle absent ou d'une autre classe → erreur claire.

## Ce qui est attendu

Code, tests, script, README ; aucun caractère non ASCII dans le code R hors commentaires ; tests ciblés `reconfort` ; contre-épreuve (ex. caractéristiques construites autrement → cas 2 rougit) ; `DESCRIPTION` cycle dev suivant, NEWS, `PLAN.md` ; commit et push. L'orchestrateur ouvre la PR. La comparaison réelle se lance chez Pascal (scènes réelles, carte IOTA², modèle).

## L'Homme

- **Agent :** `dev`, worktree de nemeton ; relu par le `relecteur`. Budget 4 $.
- **Ce qui ne lui est pas demandé :** réentraîner le modèle ; trouver des étiquettes réelles ; modifier IOTA² ou la voie fenêtre ; release ; PR.
- **Dépend de :** fusion de nemeton #705.
