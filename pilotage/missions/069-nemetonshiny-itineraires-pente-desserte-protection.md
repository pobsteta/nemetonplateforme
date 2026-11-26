# Mission 069 — nemetonshiny-itineraires-pente-desserte-protection

> Ouverte le 2026-11-26 sur la décision 3 de Pascal (même jour, journal « Pascal · décisions (11 questions…) ») : « mission pour fournir pente, desserte et aires protégées » à la vue Itinéraires.
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, partie d'`origin/main` (fc5dd83 ou plus récent). Pas de release.

## Mission

**En une phrase :** Fournir à `nemeton::itineraires_admissibles()` la pente moyenne de chaque UGF (`pente_pct`), sa distance de desserte (`desserte_m`) et les aires protégées qui la touchent (`protected_areas`), à partir de ce que le projet a déjà calculé ou mis en cache, pour que les itinéraires qui exigent ces données ne sortent plus en « donnée manquante ».

**Redite par l'agent :** _à compléter avant d'agir._

## Constat (origin/main)

`R/service_itineraires.R`, `.itin_unites()` (~l. 84-128) ne lit `pente_pct` et `desserte_m` que si le tableau des indicateurs du projet les porte déjà (« La distance de desserte n'est aujourd'hui calculée nulle part dans l'app »). L'appel au cœur (~l. 177) ne passe pas `protected_areas`. Le cœur (`nemeton/R/itineraires.R:109-139`, lecture seule) lit `pente_pct` (%), `desserte_m` (m, distance de débardage, spec 065 D-3) et un sf `protected_areas` à colonne de type (`type_protection`, `zone_type`, `type`, `statut`), même lecture que B1.

## Attendu (dans `R/service_itineraires.R`, sans logique métier dans `mod_*`)

1. **Pente** : moyenne de la pente (%) par UGF à partir du MNT déjà en cache du projet (celui qu'utilisent W3/TWI ou la Desserte ; le trouver, ne rien télécharger). Si le cœur expose une fonction de pente ou de statistique zonale, s'en servir ; sinon `terra::terrain(v = "slope", unit = "degrees")` converti en % (`100 * tan`), moyenne par UGF (`exactextractr` si déjà en dépendance, sinon `terra::extract`). Sans MNT en cache : colonne absente (le cœur dit « donnée manquante »), jamais de valeur inventée.
2. **Desserte** : distance (m) de chaque UGF à la desserte, tirée des résultats déjà en cache de la vue Desserte (`R/service_desserte.R` : réseau OSM, détection, optimisation, ou les couches foretaccess) ; définir et documenter la mesure (distance du centroïde de l'UGF à la route forestière la plus proche, ou moyenne des pixels ; préférer celle que foretaccess emploie si elle existe et le dire). Sans desserte en cache : colonne absente.
3. **Aires protégées** : passer `protected_areas =` la couche de zonages déjà téléchargée pour B1 (`service_compute.R`, `protected_areas`, cache du projet), avec sa colonne de type.
4. Un **bandeau** de la vue Itinéraires dit, pour chacune des trois données, si elle est fournie ou manquante (et comment l'obtenir : lancer le calcul des indicateurs, la vue Desserte), i18n `\uXXXX`.
5. Mise en cache des trois colonnes par projet (ne pas recalculer la pente à chaque ouverture de la vue).

## Cas limites (tests sans réseau, fixtures légères ou simulacres)

1. MNT fabriqué (plan incliné connu, ex. 10 %) et deux UGF → `pente_pct` ≈ 10, à 0,5 près.
2. Réseau de desserte fabriqué (une ligne) et deux UGF à distances connues → `desserte_m` juste.
3. Couche de zonages fabriquée touchant une UGF → le cœur reçoit `protected_areas` et l'exclusion `statut_protection` sort pour elle seule.
4. Rien en cache → colonnes absentes, bandeau « manquant », aucune erreur.
5. Le cœur reçoit bien les trois (simulacre de `itineraires_admissibles` qui enregistre ses arguments).

## Ce qui est attendu

Code, tests, i18n, contrôle non ASCII, tests des fichiers R touchés (dont `test-service_itineraires.R`, `test-mod_itineraires.R`), `.claude/test-command`, contre-épreuve, cycle dev, NEWS ; commit et push. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 4 $. Dépend de : rien.
