# Mission 080 — nemetonshiny-source-alphaearth-n5

> Ouverte le 2026-11-26 sur la décision de Pascal (même jour) : « brancher une source d'embedding : oui, AlphaEarth ». Suite de la mission 077 (affichage N5, méthode B4/L3, badge `embedding_ml`, prêt mais éteint faute de source).
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, après fusion de la PR de la 077. Pas de release.

## Mission

**En une phrase :** Brancher AlphaEarth comme source d'embedding de l'app — récupérer les embeddings annuels sur l'emprise du projet par `alphaearthnemeton::aef_fetch()`, les donner au calcul comme couche `aef_embedding` — pour que N5 se calcule, que B4/L3 passent en mode `embedding` et que le badge `embedding_ml` s'allume, sans rien changer quand la source est absente.

**Redite par l'agent :** _à compléter avant d'agir._

## Sources (lecture seule)

- `pobsteta/alphaearthnemeton` (clone de lecture : `/home/user/pobsteta/alphaearthnemeton`) : `aef_fetch(aoi, years, crs = 2154, buffer, cache_dir, index, overwrite)` → liste de SpatRaster par année (COG en cache), forme acceptée par `nemeton::indicateur_n5_distance_reference(embedding =)` ; accès anonyme HTTP (Google), repli Source Cooperative (`options(alphaearthnemeton.base_url =)`) ; R pur. **Aucun tag de release** : à dire dans la PR, et ne pas l'ajouter aux `Imports` (Suggests seulement).
- Cœur : `inst/datasources/FR.json` (source `aef_embedding`), `R/embeddings.R` (`.embedding_resolu` : SpatRaster, liste par année → la plus récente, ou couche `aef_embedding` des `nemeton_layers`), `R/indicateur_n5_distance_reference.R` (référence par défaut et statuts), `R/spectral_diversity.R` (B4/L3 `embedding =`), `R/ndp.R:331` (`attr(data, "embedding_source")`, valeurs `aef`, `maestro`, `forpt`).
- App : ce que la 077 a posé (`metadata$embedding_source`, `layers$embedding_source`, `project_augmented_flags()`), `R/service_compute.R` (couches et liste des indicateurs calculés), `R/service_python.R`/patron des sources optionnelles (Open-Canopy) pour la récupération optionnelle.

## Attendu

1. `alphaearthnemeton` en `Suggests` et dans `Remotes` (forme sans tag, faute de release ; le dire). Sans le paquet : comportement inchangé, et la vue dit que N5 demande AlphaEarth.
2. Récupération dans un `service_*` : `aef_fetch()` sur l'emprise du projet (Lambert-93, année la plus récente disponible, cache dans le dossier du projet), au moment du calcul des indicateurs (option dans Sources & paramètres, désactivée par défaut si le téléchargement est lourd — mesurer la taille sur une emprise type et le dire).
3. La couche passe au cœur comme `aef_embedding` ; N5 entre dans la liste des indicateurs calculés quand la couche existe ; B4/L3 reçoivent `embedding =` ; `embedding_source = "aef"` est posé (attribut et métadonnées) pour que `detect_ndp()` rende `embedding_ml`.
4. Échec du téléchargement (réseau, tuile absente) : message clair, calcul poursuivi sans N5, statut `skipped_no_embedding`.
5. Progression et arrêt : la récupération suit les règles des calculs longs (toast retiré à l'arrêt, missions 072 et 075).

## Cas limites (tests sans réseau : `aef_fetch` simulé, petit raster 64 bandes fabriqué)

1. Avec la couche : N5 calculé (`n5_status = calculated`), B4/L3 en `embedding`, badge `embedding_ml`.
2. Sans le paquet ou option désactivée : rien ne change (tests existants verts).
3. `aef_fetch` en erreur : calcul terminé, N5 `skipped_no_embedding`, message.
4. Le cache est réutilisé au second calcul (pas de second appel).

## Ce qui est attendu

Code, tests, i18n `\uXXXX`, contrôle non ASCII, tests des fichiers touchés (lents compris : `test-service_compute.R` et ses simulacres de `download_layers_for_parcels`), `.claude/test-command`, contre-épreuve sans `git stash` nu, cycle dev, NEWS ; commit et push ; sha par `git rev-parse HEAD`. Mesure réelle d'un `aef_fetch` si le réseau de la session le permet (sinon : dit). L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 4 $. Dépend de : PR de la 077 fusionnée.
