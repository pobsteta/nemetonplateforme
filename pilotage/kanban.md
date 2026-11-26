# Kanban de nemetonplateforme

> Cinq colonnes (fiche n° 8). Chaque carte porte l'Homme (qui), la Mission (quoi, quand,
> combien) et les Moyens (comment, où, avec qui), et renvoie à sa fiche dans
> `pilotage/missions/`. Elle note aussi depuis quel cycle de `/boucle` elle est dans sa
> colonne ; on change ce numéro chaque fois qu'elle change de colonne.
> **Une carte qui ne bouge pas est souvent la mauvaise nouvelle à dire tout de suite.**
>
> Ce kanban est commun à tous les projets pilotés : chaque carte nomme son **dépôt**. Une
> mission propre à un projet qui a son `pilotage/` reste dans le kanban de ce projet ;
> ici, sa carte y renvoie par un lien, sans la recopier.

**Dernier cycle :** 17 _(augmenté de 1 à la fin de chaque `/boucle`, même quand elle n'a
rien lancé. Une carte est immobile quand dernier cycle − N ≥ 2.)_

_Modèle de carte :_

```
- [NNN-titre](missions/NNN-titre.md) · dépôt · depuis le cycle N
  - Homme : qui
  - Mission : quoi, quand, combien
  - Moyens : comment, où, avec qui
  - Dépend de : mission ou release en amont, ou « rien »
```

## Bac à sable

## Validé

## Planifié

- 078 nemetonshiny · vue « Ce que les modèles voient » (écart 25) · après 077

## En cours

- [080-nemetonshiny-source-alphaearth-n5](missions/080-nemetonshiny-source-alphaearth-n5.md) · nemetonshiny · depuis le cycle 18
  - Homme : `dev`, relu par le `relecteur` · Mission : source AlphaEarth, N5 calculé, B4/L3 embedding · Moyens : 4 $ · Dépend de : rien

## Terminé

- [081-alphaearthnemeton-release](missions/081-alphaearthnemeton-release.md) · alphaearthnemeton · PR #2 fusionnée (5d35ed6), release v2026.11.1 posée par la CI
- [077-nemetonshiny-n5-embedding-ndp](missions/077-nemetonshiny-n5-embedding-ndp.md) · nemetonshiny · PR #345 fusionnée (90923f4), pas de release
- [079-sommier-brief-surculus-aller](missions/079-sommier-brief-surculus-aller.md) · sommieR → surculus · PR sommieR #92 fusionnée en squash (dfac77e), issue surculus#185 ouverte
- [070-nemetonshiny-marculus-choix-export](missions/070-nemetonshiny-marculus-choix-export.md) · nemetonshiny · PR #344 fusionnée (721215c), pas de release
- [069-nemetonshiny-itineraires-pente-desserte-protection](missions/069-nemetonshiny-itineraires-pente-desserte-protection.md) · nemetonshiny · PR #343 fusionnée (a7a38a7), pas de release
- [073-nemetonshiny-fordead-tout-calculer-hors-calibration](missions/073-nemetonshiny-fordead-tout-calculer-hors-calibration.md) · nemetonshiny · PR #342 fusionnée (fc5dd83), pas de release
- [076-nemeton-reconfort-carte-spike](missions/076-nemeton-reconfort-carte-spike.md) · nemeton · PR #707 fusionnée (cf29142), pas de release
- [075-nemetonshiny-arret-reel-moteurs-plafonnes](missions/075-nemetonshiny-arret-reel-moteurs-plafonnes.md) · nemetonshiny · PR #341 fusionnée (45057e1), pas de release
- [074-nemeton-icd-decoloration](missions/074-nemeton-icd-decoloration.md) · nemeton · PR #706 fusionnée (7a06ef0), pas de release ; mesure réelle sur Sentinel-2 avant release
- [072-nemetonshiny-toast-reconfort-arret](missions/072-nemetonshiny-toast-reconfort-arret.md) · nemetonshiny · PR #340 fusionnée (2276e44), pas de release
- [071-nemeton-reconfort-lecture-fenetree](missions/071-nemeton-reconfort-lecture-fenetree.md) · nemeton · PR #705 fusionnée (ca1a252), pas de release
- [068-nemetonshiny-reprises-itineraires-effet](missions/068-nemetonshiny-reprises-itineraires-effet.md) · nemetonshiny · depuis le cycle 18 · PR #339 fusionnée (de24628), pas de release
  - Homme : `dev` dans un worktree de nemetonshiny, relu par le `relecteur`
  - Mission : détail des exclusions traduit, libellés complets, référence choisie, UGF exclues affichées, bouton à bordure
- [067-nemetonshiny-effet-gestion](missions/067-nemetonshiny-effet-gestion.md) · nemetonshiny · depuis le cycle 18 · PR #338 fusionnée (e717220), pas de release
  - Homme : `dev` dans un worktree de nemetonshiny, relu par le `relecteur`
  - Mission : type de gestion saisi par UGF (liste fermée), tableau `effet_gestion()` dans la synthèse
  - Moyens : budget 5 $ ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien (#337 fusionnée)
- [066-nemetonshiny-itineraires](missions/066-nemetonshiny-itineraires.md) · nemetonshiny · depuis le cycle 18 · PR #336 fusionnée (02f36e2), pas de release
  - Homme : `dev` dans un worktree de nemetonshiny, relu par le `relecteur`
  - Mission : itinéraires admissibles par UGF (raisons d'exclusion) et comparés sous le profil, poids provisoires
  - Moyens : budget 5 $ ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien (#335 fusionnée)
- [065-sommier-plants-aller-pointage](missions/065-sommier-plants-aller-pointage.md) · sommieR · depuis le cycle 18 · PR #91 fusionnée (a586121), pas de release
  - Homme : `dev` dans un worktree de sommieR, relu par le `relecteur`
  - Mission : plants vivants versés à l'aller, `SOMMIER_METHODES_POINTAGE`
  - Moyens : budget 4 $ ; PostGIS dans le conteneur ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien
- [064-nemeton-deperis-decisions](missions/064-nemeton-deperis-decisions.md) · nemeton · depuis le cycle 18 · PR #704 fusionnée (04849a3), pas de release
  - Homme : `dev` dans un worktree de nemeton, relu par le `relecteur`
  - Mission : décisions DEPERIS de Pascal (délai, 30 m, graine du code) et brief de retour vers Ramulus
  - Moyens : budget 3 $ ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien
- [063-nemetonshiny-b5-stratification](missions/063-nemetonshiny-b5-stratification.md) · nemetonshiny · depuis le cycle 18 · PR #335 fusionnée (f71798b), pas de release
  - Homme : `dev` dans un worktree de nemetonshiny (session cloud), relu par le `relecteur`
  - Mission : B5 calculé avec le nuage, statuts traduits, couche carte, profil vertical dans la fiche UGF
  - Moyens : budget 5 $ ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien (#334 fusionnée)
- [062-sommier-demo-couchey-plants](missions/062-sommier-demo-couchey-plants.md) · sommieR · depuis le cycle 18 · PR #90 fusionnée (afba50b), pas de release
  - Homme : `dev` dans un worktree de sommieR (session cloud), relu par le `relecteur`
  - Mission : plants pointés et contrôlés (2023, 2025) dans la démo Couchey
  - Moyens : budget 3 $ ; PostGIS dans le conteneur ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien
- [061-nemeton-tournee-deperis](missions/061-nemeton-tournee-deperis.md) · nemeton · depuis le cycle 18 · PR #703 fusionnée (8862e55), pas de release
  - Homme : `dev` dans un worktree de nemeton (session cloud), relu par le `relecteur`
  - Mission : `creer_tournee_deperis()` et `importer_deperis()`, validées sur les cas communs de Ramulus
  - Moyens : budget 6 $ ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien (Ramulus 010 fusionnée)
- [060-nemeton-reconfort-spike-rust](missions/060-nemeton-reconfort-spike-rust.md) · nemeton · depuis le cycle 18 · PR #702 fusionnée (890bc55), pas de release
  - Homme : `dev` dans un worktree de nemeton (session cloud), relu par le `relecteur`
  - Mission : crate Rust CRswir/CRre + repli R, pipeline d'apprentissage RECONFORT sur placettes synth_
  - Moyens : budget 5 $ ; branche `ccr-b52c1910-gjp34w` ; ADR 0003
  - Dépend de : rien (notes DEPERIS réelles : plus tard)
- [059-nemeton-projet-video-parallele-suite](missions/059-nemeton-projet-video-parallele-suite.md) · nemeton · depuis le cycle 18 · PR #701 fusionnée (12e74eb), pas de release
  - Homme : `dev` dans un worktree de nemeton (session cloud), relu par le `relecteur`
  - Mission : placettes et dalles MNT en parallèle, un seul cluster par création
  - Moyens : budget 3 $ ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien (056 fusionnée)
- [058-nemetonshiny-progression-projet-video](missions/058-nemetonshiny-progression-projet-video.md) · nemetonshiny · depuis le cycle 18 · PR #332 fusionnée (aeb8e89), pas de release
  - Homme : `dev` dans un worktree de nemetonshiny (session cloud), relu par le `relecteur`
  - Mission : étape, compteur et temps de la création du projet vidéo affichés dans la vue
  - Moyens : budget 3 $ ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien (cœur simulé) ; effet réel avec nemeton #700
- [056-nemeton-projet-video-rapide-et-suivi](missions/056-nemeton-projet-video-rapide-et-suivi.md) · nemeton · depuis le cycle 18 · PR #700 fusionnée (f685248), pas de release
  - Homme : `dev` dans un worktree de nemeton (session cloud), relu par le `relecteur`
  - Mission : houppiers en parallèle, rasters ouverts une fois, progression par étape avec durée
  - Moyens : budget 3 $ ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien
- [057-sommier-plants-robustesse](missions/057-sommier-plants-robustesse.md) · sommieR · depuis le cycle 18 · PR #89 fusionnée (56291b0), pas de release
  - Homme : `dev` dans un worktree de sommieR (session cloud), relu par le `relecteur`
  - Mission : unicité du numéro de plant en base, jour de contrôle en heure de Paris, test d'import du mort omis
  - Moyens : budget 2 $ ; PostGIS dans le conteneur ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien (054 fusionnée)
- [055-nemetonshiny-cvat-erreur-codage](missions/055-nemetonshiny-cvat-erreur-codage.md) · nemetonshiny · depuis le cycle 18 · PR #331 fusionnée (2738d03), pas de release
  - Homme : `dev` dans un worktree de nemetonshiny (session cloud), relu par le `relecteur`
  - Mission : reprise sans relief et message quand nemeton refuse le codage du CVAT
  - Moyens : budget 2 $ ; branche `ccr-b52c1910-gjp34w` ; fusion par Pascal
  - Dépend de : rien (cœur simulé) ; à fusionner avant la prochaine release de nemeton
- [054-sommier-lot2-plants](missions/054-sommier-lot2-plants.md) · sommieR · depuis le cycle 18 · PR #88 fusionnée (29c3c62), pas de release
  - Homme : `dev` dans un worktree de sommieR (session cloud), relu par le `relecteur`
  - Mission : plants pointés et suivis de Surculus au registre 6 (`plant`, `r6-1.3.0`), import des couches de plants
  - Moyens : budget 4 $ ; PostGIS dans le conteneur ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien (052 fusionnée)
- [051-nemeton-cvat-conversion-foretaccess](missions/051-nemeton-cvat-conversion-foretaccess.md) · nemeton · depuis le cycle 18 · PR #699 fusionnée (ae887f6), pas de release
  - Homme : `dev` dans un worktree de nemeton (session cloud), relu par le `relecteur`
  - Mission : `cvat.tif` au codage de Groma (source foretaccess + 1, 255 → 0, format Groma recopié, autre codage refusé)
  - Moyens : budget 2 $ ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien
- [050-nemetonshiny-inventaire-video-carte-parametres](missions/050-nemetonshiny-inventaire-video-carte-parametres.md) · nemetonshiny · depuis le cycle 18 · PR #330 fusionnée par Pascal (e8ab0f1), pas de release
  - Homme : `dev` dans un worktree de nemetonshiny (session cloud), relu par le `relecteur`
  - Mission : carte des placettes sélectionnées ou non (clic = bascule), paramètres de génération dans Sources & paramètres, état du CVAT à l'écran
  - Moyens : budget 3 $ ; branche `ccr-b52c1910-gjp34w` ; fusion par Pascal
  - Dépend de : rien
- [053-foretaccess-cvat-nodata-distinct](missions/053-foretaccess-cvat-nodata-distinct.md) · foretaccess · depuis le cycle 18 · PR #173 fusionnée (1940e9c), pas de release
  - Homme : `dev` dans un worktree de foretaccess (session cloud), relu par le `relecteur`
  - Mission : CVAT précalculé en relief 0 à 254, 255 réservé au nodata déclaré (suite de la relecture de 051)
  - Moyens : budget 2 $ ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien
- [052-sommier-position-mesuree-controle](missions/052-sommier-position-mesuree-controle.md) · sommieR · depuis le cycle 18 · PR #87 fusionnée (988d6c8), pas de release
  - Homme : `dev` dans un worktree de sommieR (session cloud), relu par le `relecteur`
  - Mission : position mesurée du contrôle de placette gardée, importée de `positions_controles` et exposée dans `v_controle_plantation`
  - Moyens : budget 3 $ ; PostGIS dans le conteneur ; branche `ccr-b52c1910-gjp34w`
  - Dépend de : rien
- [049-nemeton-era5-restes-039-042](missions/049-nemeton-era5-restes-039-042.md) · nemeton · depuis le cycle 18 · PR #698 fusionnée (33e861a), défaut de cache corrigé, pas de release
  - Homme : `dev` dans un worktree de nemeton (session cloud), relu par le `relecteur`
  - Mission : deux tests laissés par 039 et 042 (défaut `timeseries` à travers `regen_sensibilite()`, variable illisible sur la forme réelle du CDS)
  - Moyens : budget 2 $ ; branche `ccr-b52c1910-gjp34w` ; R installé dans le conteneur
  - Dépend de : rien
- [048-plateforme-plafond-reprise](missions/048-plateforme-plafond-reprise.md) · nemetonplateforme · depuis le cycle 16 · relue « prête » après un aller-retour, PR de pilotage fusionnée
  - Homme : `dev` dans un worktree de ce dépôt (sonnet), relu par le `relecteur`
  - Mission : `relance.sh` refuse une reprise au-delà de 4 $ cumulés et borne la passe à ce qui reste
  - Moyens : budget 2 $ ; PR de pilotage, hors plafond
  - Dépend de : rien
- [047-plateforme-charge-restes-044](missions/047-plateforme-charge-restes-044.md) · nemetonplateforme · depuis le cycle 16 · relue « prête », PR de pilotage fusionnée
  - Homme : `dev` dans un worktree de ce dépôt (sonnet), relu par le `relecteur`
  - Mission : raison dite dans l'avertissement « disque non mesurable », exclusions exactes dans l'ADR 0001
  - Moyens : budget 1 $ ; PR de pilotage, hors plafond
  - Dépend de : rien
- [046-plateforme-rangement-bilan-era5](missions/046-plateforme-rangement-bilan-era5.md) · nemetonplateforme · depuis le cycle 16 · relue « prête » après un aller-retour, intégrée à la PR #55
  - Homme : `archiviste` dans un worktree de ce dépôt (sonnet), relu par le `relecteur`
  - Mission : trous de mémoire du test du successeur (carte, fiches 039 à 043, ADR 0001, kanban)
  - Moyens : budget 1,5 $
  - Dépend de : fin de 044 (ADR 0001)
- [045-plateforme-regle-reponse-reelle](missions/045-plateforme-regle-reponse-reelle.md) · nemetonplateforme · depuis le cycle 16 · relue « prête », intégrée à la PR #55
  - Homme : `archiviste` dans un worktree de ce dépôt (sonnet), relu par le `relecteur`
  - Mission : règle « fixture de la forme réelle, vraie réponse vérifiée hors CI » dans `docs/spec.md` § 5
  - Moyens : budget 1 $
  - Dépend de : rien
- [044-plateforme-charge-disque-et-lanceur](missions/044-plateforme-charge-disque-et-lanceur.md) · nemetonplateforme · depuis le cycle 16 · relue « prête », intégrée à la PR #55
  - Homme : `dev` dans un worktree de ce dépôt (sonnet), relu par le `relecteur`
  - Mission : seconde mesure du contrôle de charge (occupation réelle du disque), `lance.sh` qui s'arrête sans fiche
  - Moyens : budget 2 $ ; PR de pilotage, hors plafond
  - Dépend de : rien
- [043-nemetonshiny-plancher-nemeton-44](missions/043-nemetonshiny-plancher-nemeton-44.md) · nemetonshiny · depuis le cycle 15 · PR nemetonshiny #326 fusionnée (ca5072a8), `main` en 2026.11.6.9000
- [042-nemeton-era5ts-cache-scalaires](missions/042-nemeton-era5ts-cache-scalaires.md) · nemeton · depuis le cycle 15 · PR #689 fusionnée, publiée en v2026.11.44 ; essai réel de la Colombière vert (1,8 min par année)
- [041-nemeton-era5-annee-en-cours](missions/041-nemeton-era5-annee-en-cours.md) · nemeton · depuis le cycle 15 · PR #687 fusionnée, publiée en v2026.11.43
- [040-nemetonshiny-era5-timeseries](missions/040-nemetonshiny-era5-timeseries.md) · nemetonshiny · depuis le cycle 15 · PR nemetonshiny #324 fusionnée, publiée en v2026.11.6
- [039-nemeton-era5-timeseries](missions/039-nemeton-era5-timeseries.md) · nemeton · depuis le cycle 15 · PR #684 fusionnée (e55239b), publiée en v2026.11.42
  - Homme : `dev` d'une session ouverte dans `nemeton` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : forçage ERA5 horaire (microclimf et BILJOU) par le jeu CDS `timeseries` par défaut, même data.frame ; diffus juste (`ssrd − fdir`), caches séparés, pas de repli automatique (choix de Pascal et de l'orchestrateur, journal)
  - Moyens : budget 3 $, porté à 4 $ par Pascal pour la reprise 3 (3,65 $ dépensés, 3 allers-retours)
  - Dépend de : rien
- [038-nemeton-ci-cache-gdal](missions/038-nemeton-ci-cache-gdal.md) · nemeton · depuis le cycle 14 · PR #669 fusionnée (8d025e8)
  - Homme : `dev` d'une session ouverte dans `nemeton` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : clé du cache R de la CI avec les versions GDAL/GEOS/PROJ du runner ; tests adaptés à terra 1.9-60 (`init()`)
  - Moyens : budget 3 $ (1,33 $ dépensés)
  - Dépend de : rien
- [037-nemeton-relief-cvat-houppiers-foret](missions/037-nemeton-relief-cvat-houppiers-foret.md) · nemeton · depuis le cycle 14 · PR #668 fusionnée par Pascal (c2bc12d, 2026-11-22)
  - Homme : `dev` d'une session ouverte dans `nemeton` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : schéma 1.7.0 (dalles MNT de 1 km, relief CVAT, houppiers avec sommet sur toute la forêt, dans le `.qgz`)
  - Moyens : budget 3 $ (2,87 $ dépensés)
  - Dépend de : rien
- [036-terrain-agent-ntrip-obligatoire](missions/036-terrain-agent-ntrip-obligatoire.md) · terrain · depuis le cycle 13 · PR #36 fusionnée (73a0d54), tag `v2026.11.2` publié (release et JitPack)
  - Homme : `dev` d'une session ouverte dans `terrain` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : `agent` obligatoire dans `Ntrip.requete`, validé (vide, blanc, espace, caractère de contrôle refusés) ; rupture déclarée, briefs à Marculus et Surculus
  - Moyens : budget 2 $ (0,52 $ dépensés)
  - Dépend de : rien
- [035-groma-terrain-gnss-2026-11-1](missions/035-groma-terrain-gnss-2026-11-1.md) · groma · depuis le cycle 12 · PR #116 fusionnée en squash (f6e7c22) après un aller-retour ; release 2026.11.9 publiée par groma (jusqu'à 2026.11.12 au cycle 16)
  - Homme : `dev` d'une session ouverte dans `groma` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : terrain v2026.11.1 et `terrain-gnss` à la place de la copie GNSS de Groma, noms de terrain dans le code, GeoPackage inchangé (voie A)
  - Moyens : budget 3 $ (1,85 $ dépensés, coût cumulé)
  - Dépend de : terrain v2026.11.1 (fait)
- [034-plateforme-base-de-test-utile](missions/034-plateforme-base-de-test-utile.md) · nemetonplateforme · depuis le cycle 12 · PR #45 fusionnée (00e7eea)
  - Homme : `dev` dans un worktree de ce dépôt (sonnet), relu par le `relecteur`
  - Mission : base de test PostgreSQL préparée seulement pour les dépôts qui s'en servent (sommieR)
  - Moyens : budget 2 $
  - Dépend de : rien
- [033-terrain-version-calendaire](missions/033-terrain-version-calendaire.md) · terrain · depuis le cycle 11 · PR #35 fusionnée (39bba22) ; tag et release v2026.11.1 posés par l'orchestrateur, JitPack sert v2026.11.1
  - Homme : `dev` d'une session ouverte dans `terrain` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : tags, releases et versions de terrain en `vAAAA.M.N`, première v2026.11.1 (porte la 030) ; tag posé par l'orchestrateur après fusion
  - Moyens : budget 3 $ ; worktree depuis `origin/main`
  - Dépend de : rien
- [032-plateforme-outils-execution](missions/032-plateforme-outils-execution.md) · nemetonplateforme · depuis le cycle 10 · PR #40 fusionnée (9d6c16d), un aller-retour
  - Homme : `archiviste`, relu par le `relecteur`
  - Mission : outils d'exécution versés au dépôt et décrits dans l'ADR 0001 ; état de la plateforme à jour
  - Moyens : worktree de ce dépôt ; PR de pilotage, hors plafond
  - Dépend de : rien
- [031-nemetonshiny-hebergeur-hostinger](missions/031-nemetonshiny-hebergeur-hostinger.md) · nemetonshiny · depuis le cycle 10 · PR #307 fusionnée (c6f94cf7), documentation seule
  - Homme : `dev` d'une session ouverte dans `nemetonshiny` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : note datée Hostinger dans le brief et l'ADR 0003, documentation seule
  - Moyens : budget 1 $
  - Dépend de : rien
- [030-terrain-fix-horodate-lecteur-nmea](missions/030-terrain-fix-horodate-lecteur-nmea.md) · terrain · depuis le cycle 10 · PR #34 fusionnée (e49186a) ; tag v0.8.0 à poser par Pascal
  - Homme : `dev` d'une session ouverte dans `terrain` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : heure UTC du fix et lecteur NMEA demandés par Groma, additifs, aux noms de terrain
  - Moyens : budget 3 $ ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [029-sommier-version-calendaire](missions/029-sommier-version-calendaire.md) · sommieR · depuis le cycle 10 · PR #85 fusionnée en squash (df94a39) ; release v2026.11.1
  - Homme : `dev` d'une session ouverte dans `sommieR` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : versions, tags et releases en `AAAA.M.N` (convention de `nemeton`), première 2026.11.1
  - Moyens : budget 3 $ ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [028-sommier-import-comptages](missions/028-sommier-import-comptages.md) · sommieR · depuis le cycle 10 · PR #86 fusionnée en squash (fa558ed) après deux allers-retours ; release v2026.11.2
  - Homme : `dev` d'une session ouverte dans `sommieR` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : l'import QField lit `nb_plants_vivants` et `nb_plants_concurrences`
  - Moyens : budget 3 $
  - Dépend de : fusion de 029 (mêmes fichiers de version)
- [027-sommier-import-sans-blocage](missions/027-sommier-import-sans-blocage.md) · sommieR · depuis le cycle 9 · PR #84 fusionnée en squash (2ca88d8), 0.44.0 ; 3,15 $ pour un budget de 3 $ (coût cumulé de la dernière passe)
  - Homme : `dev` d'une session ouverte dans `sommieR` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : aucun écart de forme d'une tournée de terrain ne fait refuser l'import ; accepté et signalé
  - Moyens : quatre passes ; vert prouvé par l'orchestrateur sur 6a24a90 (568 s)
  - Dépend de : rien
- [026-sommier-photos-terrain](missions/026-sommier-photos-terrain.md) · sommieR · depuis le cycle 9 · PR #82 fusionnée en squash (88f7bdd), 0.42.0 ; remplace #81
  - Homme : `dev` d'une session ouverte dans `sommieR` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : photos de placette et de plant : EXIF (repère, précision, fuseau) et photos_terrain au schéma de Surculus ; réponse à Surculus
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [025-sommier-ortho-tuilee](missions/025-sommier-ortho-tuilee.md) · sommieR · depuis le cycle 9 · PR #83 fusionnée en squash (ab21e89), 0.43.0 ; remplace #79 ; rupture acceptée par Pascal
  - Homme : `dev` d'une session ouverte dans `sommieR` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : ortho de la tournée des travaux en MBTiles EPSG:3857, zooms 12 à 18, PNG à bords transparents, attribution et date
  - Moyens : budget 3 $ par passe ; cinq passes ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [024-sommier-demo-marsannay](missions/024-sommier-demo-marsannay.md) · sommieR · depuis le cycle 9 · PR #77 fusionnée en squash (f909f2e), 0.39.0
  - Homme : `dev` d'une session ouverte dans `sommieR` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : démo Marsannay : parcelles communales réelles, écritures inventées
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [023-sommier-symbologie-travaux](missions/023-sommier-symbologie-travaux.md) · sommieR · depuis le cycle 9 · PR #75 fusionnée en squash (14c54f4), 0.38.0
  - Homme : `dev` d'une session ouverte dans `sommieR` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : symbologie des travaux comme Marculus ; CI épinglée sur ubuntu-24.04
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [022-sommier-niveaux-concurrence](missions/022-sommier-niveaux-concurrence.md) · sommieR · depuis le cycle 9 · PR #78 fusionnée en squash (7db28dd), 0.40.0 ; remplace #76
  - Homme : `dev` d'une session ouverte dans `sommieR` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : trois niveaux de concurrence et règle plant → placette ; réponse à Surculus
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [021-sommier-actions-realisees](missions/021-sommier-actions-realisees.md) · sommieR · depuis le cycle 9 · PR #80 fusionnée en squash (02702cc), 0.41.0 ; remplace #74
  - Homme : `dev` d'une session ouverte dans `sommieR` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : sommier_actions_realisees() et action_id en liste de valeurs QField ; lien nemetonshiny ← sommieR confirmé
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [020-groma-modules-terrain](missions/020-groma-modules-terrain.md) · groma · depuis le cycle 9 · PR #115 fusionnée en squash (4cff183)
  - Homme : `dev` d'une session ouverte dans `groma` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : Position, Projections, Geodesie et FormatGpkg repris de terrain ; brief retour vers terrain (horodate et lecteur NMEA)
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [019-groma-texte-et-heure-utc](missions/019-groma-texte-et-heure-utc.md) · groma · depuis le cycle 9 · PR #113 fusionnée en squash (8859705)
  - Homme : `dev` d'une session ouverte dans `groma` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : styles typographiques Material3 communs ; heure UTC complète du fix GNSS
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [018-marculus-tarifs-et-style](missions/018-marculus-tarifs-et-style.md) · marculus · depuis le cycle 9 · PR #80 fusionnée en squash (8255b8f)
  - Homme : `dev` d'une session ouverte dans `marculus` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : tarifs IFN et style commun ; issue #2 fermée
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [017-nemetonmcp-suivre-nemeton](missions/017-nemetonmcp-suivre-nemeton.md) · nemetonmcp · depuis le cycle 9 · PR #38 fusionnée en squash (0f5c666)
  - Homme : `dev` d'une session ouverte dans `nemetonmcp` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : suivre nemeton 2026.11.32-34 : froid d'hiver en tâche de fond, erreur si E-OBS manque, cache avant le choix d'UG
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [016-contrat-nemeton-nemetonmcp](missions/016-contrat-nemeton-nemetonmcp.md) · nemetonmcp · depuis le cycle 9 · PR #37 fusionnée en squash
  - Homme : `testeur` d'une session ouverte dans `nemetonmcp` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : test de contrat de ce que nemetonmcp lit dans nemeton ; enable_rag et ingest verrouillés
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [015-contrat-nemeton-nemetonshiny](missions/015-contrat-nemeton-nemetonshiny.md) · nemetonshiny · depuis le cycle 9 · PR #306 fusionnée (6fe1df4d)
  - Homme : `testeur` d'une session ouverte dans `nemetonshiny` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : test de contrat de ce que nemetonshiny lit dans nemeton ; R-CMD-check et coverage relancés deux fois (runners lents)
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [014-contrat-nemeton-sommier](missions/014-contrat-nemeton-sommier.md) · sommieR · depuis le cycle 9 · PR #73 fusionnée en squash
  - Homme : `testeur` d'une session ouverte dans `sommieR` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : test de contrat de ce que sommieR lit dans nemeton
  - Moyens : budget 3 $ par passe ; vert prouvé par l'orchestrateur sur le SHA exact
  - Dépend de : rien
- [013-sommier-ci-dependances](missions/013-sommier-ci-dependances.md) · sommieR · depuis le cycle 8 · PR #72 fusionnée en squash (99984d6)
  - Homme : `dev` d'une session ouverte dans `sommieR` (sonnet, ADR 0001), relu par le `relecteur`
  - Mission : cause trouvée (apt des paquets -dev des Suggests, 117 Mo à 171 kB/s, hors du cache R) ; `PKG_SYSREQS=false` ; installation R de 12-20 min à 23-40 s
  - Moyens : budget 3 $ ; deux passes, environ 2,8 $ cumulés
  - Dépend de : rien
- [012-rangement-memoire](missions/012-rangement-memoire.md) · nemetonplateforme · depuis le cycle 8 · PR #27 fusionnée (120ccfe)
  - Homme : `archiviste` (sonnet)
  - Mission : README, renvois à l'ADR 0001, `fusion:` par projet dans la carte, projets observés, comptes, tableau des missions, boîtes de `~/dev/briefs/`
  - Moyens : un worktree de ce dépôt ; un écart relevé au passage (foretaccess #166 fusionnée en squash à tort)
  - Dépend de : rien
- [011-sommier-demarrer](missions/011-sommier-demarrer.md) · sommieR · depuis le cycle 6 · PR #70 fusionnée en squash (cce46d0)
  - Homme : orchestrateur d'une session ouverte dans `sommieR` (`/imperatrice:demarrer`, sonnet, ADR 0001)
  - Mission : méthode installée (brief et ADR dans `pilotage/`), plugin, `.claude/test-command` en niveau rapide (30 fichiers sur 45, base PostGIS jointe)
  - Moyens : budget 3 $ ; entre 1,55 et 2,18 $ estimés, trois passes, environ 78 min
  - Dépend de : rien
- [010-confirmer-liens-carte](missions/010-confirmer-liens-carte.md) · nemetonplateforme · depuis le cycle 5 · PR #20 fusionnée (691ebaa)
  - Homme : `archiviste` (sonnet), sous-agent dans un worktree de ce dépôt
  - Mission : 6 liens `confirme: non` relus dans le code : 2 retirés, 4 laissés à `non` avec une question pour Pascal
  - Moyens : lecture seule des clones et de `~/dev/briefs/`
  - Dépend de : 007 et 008 (fusionnées)
- [009-nemetonshiny-availablecores-tests](missions/009-nemetonshiny-availablecores-tests.md) · nemetonshiny · depuis le cycle 5 · PR #305 fusionnée (50de1fd)
  - Homme : `dev` (sonnet), dans une session ouverte dans `nemetonshiny` (ADR 0001)
  - Mission : les deux derniers `future::availableCores()` des tests passés à `parallelly`
  - Moyens : budget 3 $, 5400 s ; 0,43 $ et 261 s
  - Dépend de : 005 (fusionnée)
- [008-etat-cycle-yaml](missions/008-etat-cycle-yaml.md) · nemetonplateforme · depuis le cycle 4 · PR #18 fusionnée (562542d)
  - Homme : `archiviste` (sonnet), sous-agent dans un worktree de ce dépôt
  - Mission : `pilotage/etat-cycle.yaml`, état lu des 13 projets ; tags et versions retirés de la carte en prose
  - Moyens : `git ls-remote` et `gh` en lecture seule
  - Dépend de : 007 (fusionnée)
- [007-carte-yaml](missions/007-carte-yaml.md) · nemetonplateforme · depuis le cycle 4 · PR #17 fusionnée (37f507a)
  - Homme : `archiviste` (sonnet), sous-agent dans un worktree de ce dépôt
  - Mission : `docs/carte.yaml`, 13 projets et 20 liens (6 à confirmer), source unique des liens
  - Moyens : `docs/carte-dependances.md`, lecture seule des clones
  - Dépend de : rien
- [006-victor-tests-et-ci](missions/006-victor-tests-et-ci.md) · victor · depuis le cycle 3 · PR #1 fusionnée (1ac4cce)
  - Homme : `dev` (sonnet), dans une session ouverte dans `victor` (ADR 0001)
  - Mission : premiers tests `pytest` du cœur, `.claude/test-command`, plugin, CI minimale ; Pascal fusionne
  - Moyens : `uv` du projet ; budget 3 $, 3600 s
  - Dépend de : rien
- [005-nemetonshiny-service-monitoring-wiring](missions/005-nemetonshiny-service-monitoring-wiring.md) · nemetonshiny · depuis le cycle 3 · PR #304 fusionnée (3a00990)
  - Homme : `dev` (sonnet), dans une session ouverte dans `nemetonshiny` (ADR 0001)
  - Mission : `parallelly::availableCores()` au lieu de `future::availableCores()`, `service_monitoring_wiring` revenu dans le niveau rapide
  - Moyens : budget 3 $, 5400 s ; 0,56 $ et 464 s à la relance
  - Dépend de : rien
- [004-nemetonshiny-commande-de-tests](missions/004-nemetonshiny-commande-de-tests.md) · nemetonshiny · depuis le cycle 2 · PR #303 fusionnée (5b58734)
  - Homme : `testeur` (sonnet), dans une session ouverte dans `nemetonshiny` (ADR 0001)
  - Mission : versionner la `.claude/test-command` (niveau rapide, suite complète en CI)
  - Moyens : missions 001 et 002 en modèles ; budget 3 $
  - Dépend de : rien
- [003-nemetonmcp-plugin-et-tests](missions/003-nemetonmcp-plugin-et-tests.md) · nemetonmcp · depuis le cycle 1 · PR #36 fusionnée (cf89cd3)
  - Homme : `testeur` (sonnet), dans une session ouverte dans `nemetonmcp` (ADR 0001)
  - Mission : activer le plugin, versionner une `.claude/test-command` (JS et R)
  - Moyens : la CI du projet comme modèle ; budget 3 $ (provisoire)
  - Dépend de : rien
- [002-foretaccess-plugin-et-tests](missions/002-foretaccess-plugin-et-tests.md) · foretaccess · depuis le cycle 1 · PR #166 fusionnée (6c15472)
  - Homme : `testeur` (sonnet), dans une session ouverte dans `foretaccess` (ADR 0001)
  - Mission : activer le plugin, versionner une `.claude/test-command` (niveau rapide, suite complète en CI)
  - Moyens : la CI du projet comme modèle ; budget 3 $ (provisoire)
  - Dépend de : rien
- [001-nemeton-commande-de-tests](missions/001-nemeton-commande-de-tests.md) · nemeton · depuis le cycle 1 · PR #667 fusionnée (70618fd)
  - Homme : `testeur` (sonnet), dans une session ouverte dans `nemeton` (ADR 0001)
  - Mission : versionner une `.claude/test-command` (niveau rapide, suite complète en CI)
  - Moyens : la CI du projet comme modèle ; budget 3 $ (provisoire)
  - Dépend de : rien

## Abandonné

_Avec la raison, en une ligne._

## Livraisons

_Une ligne par cycle, ajoutée sous la précédente à la fin de chaque `/boucle`, et une
par `/bilan` : la livraison que Pascal a retenue, pour qui, et ce qu'elle apporte de plus
que la précédente du même rythme. Un cycle sans livraison neuve livre sa mauvaise
nouvelle, car
« une mauvaise nouvelle est une livraison sur laquelle on apprend » (Pascal) : on
l'inscrit avec ce qu'elle nous apprend._

```
- cycle N · livraison · pour qui · ce qu'elle apporte de plus que la précédente
- cycle N · mauvaise nouvelle : … · pour qui · ce qu'elle nous apprend
- bilan du AAAA-MM-JJ · livraison · pour qui · ce qu'elle apporte de plus que la précédente
- bilan du AAAA-MM-JJ · mauvaise nouvelle : … · pour qui · ce qu'elle nous apprend
```

- cycle 1 · `nemeton`, `foretaccess` et `nemetonmcp` ont une `.claude/test-command` versionnée (et le plugin pour les deux derniers) · pour l'orchestrateur et Pascal · leurs PR deviennent prouvables vertes, donc leurs fusions délégables ; la règle des deux niveaux (rapide au hook, complet en CI) est née de la mauvaise nouvelle des suites d'une heure
- cycle 2 · `nemetonshiny` versionne sa `.claude/test-command` (niveau rapide, 118 fichiers sur 181, par exclusion des lents) ; ADR-016 rangée, rejetée · pour l'orchestrateur et Pascal · quatre projets ont désormais leurs fusions délégables ; mauvaise nouvelle apprise : une session sur une suite longue dépasse 3600 s, la fiche doit prévoir sa limite
- cycle 3 · `victor` a ses premiers tests, sa `.claude/test-command` et sa CI ; `nemetonshiny` n'a plus de test rouge quand il passe seul, et son niveau rapide repasse à 119 fichiers · pour l'orchestrateur et Pascal · cinq projets ont désormais leurs fusions prouvables ; mauvaise nouvelle apprise : une session lancée en arrière-plan ne survit ni à l'archivage de la session qui l'attend ni à un redémarrage, ses traces vont hors de `/tmp`
- cycle 4 · `docs/carte.yaml` (13 projets, 20 liens sourcés, 6 à confirmer) et `pilotage/etat-cycle.yaml` (état lu des 13 projets) · pour l'orchestrateur · un cycle peut désormais partir de ce qui a changé et trouver l'aval dans un fichier lu par la machine ; critères n° 1 et 2 de la spec en place ; mauvaise nouvelle apprise : la carte en prose recopiait des tags et des versions, périmés en un jour (cinq tags sur treize)
- cycle 5 · plus aucun appel déprécié à `future::availableCores()` dans `nemetonshiny` ; carte relue dans le code (18 liens, 4 questions précises au lieu de 6 liens douteux) · pour l'orchestrateur et Pascal · la carte ne désigne plus d'aval qui n'existe pas (`surculus` n'est pas en aval de `nemetonshiny`) ; mauvaise nouvelle apprise : un trajet réel peut passer par un projet hors carte (sommieR), et une décision « seulement observé » peut perdre sa raison en un cycle (`sylvostation` a désormais un `main`)
- cycle 6 · sommieR, 14ᵉ projet, a la méthode, le plugin et une `.claude/test-command` (niveau rapide, base PostGIS jointe, échec si elle manque) ; carte entièrement tranchée par la règle « un lien suit la dépendance technique » ; `sylvostation` piloté · pour l'orchestrateur et Pascal · sept projets ont leurs fusions prouvables ; mauvaise nouvelle apprise : `/demarrer` pose ses questions à Pascal et ne se lance pas sans lui ; le gabarit met brief et ADR dans `docs/`, publié par pkgdown dans les paquets R ; le coût d'une session reprise est cumulé, pas additionnel
- cycle 7 · rien de neuf à livrer : aucun tag, aucun `main` changé hors de la fusion sommieR #71 (porte n° 3 de sommieR alignée sur la délégation) · pour Pascal · mauvaise nouvelle apprise : la CI de sommieR peut échouer deux fois de suite à l'installation des dépendances (apt, 30 min) sans qu'aucun test tourne ; relancer est la bonne réponse, et le bilan dira si la CI doit mettre ses dépendances en cache
- bilan du 2026-11-18 · carte entièrement tranchée (21 liens relus dans le code, un seul en attente de sommieR), 14 projets dont sommieR et `sylvostation` pilotés, sept projets aux fusions prouvables · pour Pascal et l'orchestrateur · au bilan précédent la carte gardait six liens douteux ; elle ne désigne plus d'aval qui n'en est pas un ; mais aucun changement réel n'a encore descendu la chaîne (aucune release de `nemeton` depuis le cycle 4)
- cycle 8 · la CI de sommieR ne perd plus 12 à 30 min avant le premier test (installation des dépendances R sous 40 s, tests en 4 min 41 s au lieu de 28 min) ; la mémoire de la plateforme est écrite là où elle fait foi (README, convention de fusion par dépôt dans la carte) · pour Pascal et l'orchestrateur · une PR de sommieR est prouvée verte en minutes ; mauvaise nouvelle apprise : un gain mesuré sur une seule étape peut cacher un temps déplacé dans une autre, c'est la durée totale du job qui compte ; et `Setup R` reste lent, hors de portée du workflow
- cycle 9 · 13 missions (014 à 026) fusionnées ; tests de contrat sur les trois liens de code de `nemeton` (vers sommieR, nemetonshiny, nemetonmcp) ; nemetonmcp suit `nemeton` 2026.11.32-34 ; sommieR de 0.38 à 0.43 (réalisé des travaux vers nemetonshiny, photos, symbologie, ortho MBTiles) · pour Pascal et le terrain · mauvaise nouvelle apprise : base de test commune entre sessions, `journal_intact` refuse le rattrapage de `main` par merge (4 PR remplacées), et la spec de l'aval doit être lue avant de coder
- bilan du 2026-11-19 (partiel, deux décisions de Pascal) · règle d'import « accepter et signaler, refuser seulement l'illisible » (mission 027) ; hébergeur du connecteur distant : Hostinger · pour Pascal et le terrain · aucune ligne de livraison n'avait été écrite à ce bilan (trou relevé le 2026-11-20)
- bilan du 2026-11-20 · sommieR de 0.38 à 0.44 sur les briefs du terrain (réalisé des travaux, photos, ortho sans réseau dans QField, import qui ne bloque plus la tournée) et contrats de `nemeton` testés · pour Pascal sur le terrain · au bilan du 2026-11-18 aucun changement réel n'avait descendu la chaîne ; cette fois des changements réels sont arrivés jusqu'aux applications de terrain
- cycle 10 · sommieR v2026.11.2 lit les comptages de plants à l'import (décision du bilan arrivée en release le jour même) et passe aux versions calendaires ; `terrain` porte l'heure UTC du fix pour Groma (v0.8.0 à taguer) ; le pilotage se reprend depuis le dépôt seul (`pilotage/outils/`, contrôle de charge) · pour Pascal sur le terrain et un successeur · mauvaise nouvelle apprise : la lecture des comptages ne sert à rien tant que Surculus n'écrit pas les deux colonnes ; le lanceur ne créait pas la base de la mission ; un disque saturé par une autre session retient tout le cycle
- cycle 12 · Groma 2026.11.9 · le forestier qui fait l'inventaire vidéo · première version de Groma sur la bibliothèque GNSS commune de terrain (v2026.11.1, heure UTC du fix), sans changement de fichier ni d'écran ; la livraison du cycle 11 était la bibliothèque elle-même
- cycle 13 · terrain v2026.11.2 · les applications de terrain (Groma, Marculus, Surculus) · livraison technique : chaque application doit donner son propre nom au caster NTRIP, aucune ne peut plus se présenter sous le nom d'une autre ; rien de nouveau pour le forestier, Groma 2026.11.9 se nommait déjà
- bilan du 2026-11-20 (cycles 10 à 13) · terrain v2026.11.1 et v2026.11.2 (bibliothèque GNSS commune, heure UTC du fix, agent NTRIP obligatoire), Groma 2026.11.9 dessus, sommieR v2026.11.2 (comptages de plants, versions calendaires) · le forestier en inventaire vidéo et Pascal sur le terrain · pour la première fois, un changement d'une bibliothèque commune descend jusqu'à une application publiée sans casser le fichier lu par nemeton ; au bilan précédent, les changements s'arrêtaient à sommieR ; appris : les comptages lus par sommieR ne servent pas tant que Surculus ne les écrit pas
- cycle 16 · nemeton 2026.11.44 et nemetonshiny 2026.11.6, installés et en service · Pascal dans l'onglet reGénération (Colombière) · le forçage climatique ERA5 horaire arrive par le jeu `timeseries` en 1,8 min par année, déjà en cache pour 2018 et 2020 ; la livraison précédente (cycle 13, terrain v2026.11.2) n'apportait rien de nouveau au forestier ; vaut si l'essai de Pascal dans l'app est concluant
- bilan du 2026-11-24 (fil ERA5, cycles 14 à 16) · nemeton 2026.11.44 et nemetonshiny 2026.11.6 en service : forçage climatique ERA5 horaire par le jeu `timeseries`, 1,8 min par année, en cache pour 2018 et 2020 sur la Colombière · Pascal dans l'onglet reGénération · au bilan du 2026-11-20, les changements descendaient jusqu'aux applications de terrain ; celui-ci est le premier à changer le calcul de régénération lui-même
- bilan du 2026-11-24 (fil ERA5) · mauvaise nouvelle : nemeton 2026.11.42 et 2026.11.43 ont été publiées et mises en service alors que leur chemin par défaut rejetait toute vraie réponse du CDS (variables `latitude` et `longitude` scalaires, absentes des fixtures) ; tests et CI verts, l'essai réel de la Colombière l'a trouvé, corrigé le jour même en 2026.11.44 · pour Pascal et un successeur · ce qu'elle nous apprend : un vert de tests ne prouve pas un chemin d'acquisition externe ; la fixture doit avoir la forme d'une vraie réponse, et une vraie réponse est lue une fois avant la fusion (règle de `docs/spec.md` § 5, mission 045)
- cycle 17 · nemeton 2026.11.45 · Pascal dans l'app, après réinstallation de nemetonshiny (qui tire la dernière release du cœur) · les bandes Sentinel-2 distantes se lisent par fenêtre, 3,2 s au lieu de 87 s sur la Colombière, résultat identique ; la livraison précédente (cycle 16) apportait le forçage ERA5, pas la lecture Sentinel-2
