# Mission 094 — marculus-correction-emerge

> Ouverte le 2026-11-27 sur la demande de Pascal (« regarde dans le dépôt de marculus il y a un brief à faire ») : brief `docs/specs/2026-11-27-correction-emerge-volumes.md`, aujourd'hui seulement sur la branche `origin/claude/brief-correction-emerge` (commit cbf084a, fichier + une ligne de journal), transmis par la session NEMETON (dépôt tarif-nemeton, mission 010) avec deux décisions de Pascal intégrées. Décision complémentaire de Pascal (même jour) sur les formats : **renommer les colonnes et relire l'ancien nom**.
> Dépôt : `marculus`, branche `ccr-b52c1910-gjp34w`, partie de `origin/main` 41a01f7. Lire `CLAUDE.md` et `pilotage/pre-fusion.md` de marculus.

## Mission

**En une phrase :** Corriger le cubage EMERGE de Marculus selon le brief : exposer et nommer quatre volumes (bois fort tige, houppier, bois fort total, volume aérien total `formTot · volCyl`), remplacer la recherche d'essence par préfixe ou sous-chaîne par une table de rattachement explicite (« Chêne » → chêne sessile/pédonculé, aucun repli silencieux), et écrire les tests de non-régression contre les valeurs publiées des arbres du brief.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. Verser le brief sur la branche (cherry-pick de cbf084a, ou copie du fichier et de la ligne de journal) pour qu'il soit dans `main` avec la correction.
2. `core/…/Cubage.kt` : `VolumesEmerge` gagne `volumeAerienTotal = formTot * volCyl` ; l'actuel `total` devient `boisFortTotal` ; commentaires (l. 79, l. 165) et tests corrigés. `EmergeCoefs.kt` reste généré, **ne pas l'éditer à la main**.
3. Rattachement explicite : table écrite à la main (nom saisi normalisé → clé EMERGE), dont « chene » → chêne sessile/pédonculé (clé de `Quercus robur_petraea` dans `EmergeCoefs.kt` : vérifier comment elle s'y nomme) ; suppression des correspondances par préfixe et par sous-chaîne (`coefEmerge` l. 40-50 et `codeEssence` l. 61-62) ; nom inconnu → pas de volume EMERGE et un statut visible (ou repli sur le modèle gris feuillus/résineux **déclaré**, celui que le code prévoit déjà l. 48-49), jamais une essence arbitraire.
4. Propagation : `VolumesMartelage.kt`, `CsvFoncier.kt`, `ParParcelle.kt`, `export/ExportCsv.kt`, `SauvegardeRepository.kt`, `StatutHistoriqueScreen.kt`, `strings.xml` (FR et EN) : quatre volumes affichés et exportés sous leur nom (libellés du tableau « Décision de Pascal : quatre volumes affichés » du brief). Formats : colonnes écrites `VolumeBoisFortTotalM3` et `VolumeAerienTotalM3` (et les colonnes tige/houppier si elles existent sous un nom ambigu) ; à la lecture d'une ancienne sauvegarde ou d'un ancien CSV, `VolumeTotalM3` est compris comme bois fort total (test de relecture d'un fichier ancien).
5. Tests (JUnit, `:core:test` au moins) : `volumeAerienTotal` à ±2 % du publié pour les six arbres du brief (hêtre 62,8/10 ; « Chêne » 125/20 rattaché au chêne sessile → 1,6099 publié, 1,5941 attendu ; arbres A à D) ; « Chêne » ne retombe plus sur le chêne rouge ; un nom générique inconnu ne retombe sur aucune essence ; contre-épreuve sur l'ancien `Cubage.kt`. Confirmer par exécution Kotlin les valeurs « avant » du brief (hêtre : tige 0,1557, houppier 0,0251, total 0,1808) : le brief les a obtenues par traduction Python.
6. Points secondaires du brief (fct négatif aux petites hauteurs, règle `fct > 0,95 → 0,8`, seuil `H ≤ 1,4`) : **hors périmètre**, les lister dans le rapport, ne pas les changer.
7. Écran modifié : captures (clair et sombre, FR et EN, 384 et 360 dp) si un moyen existe dans la session (Roborazzi, Paparazzi, tests de capture déjà en place) ; sinon le dire, la vérification se fera sur le téléphone de Pascal (pre-fusion n° 4).

## Ce qui est attendu

Code, tests, `.claude/test-command` adapté au conteneur si besoin (sans modifier le fichier versionné : lancer `./gradlew :core:test …` avec le JDK et le SDK du conteneur ; dire ce qui n'a pas pu tourner faute de SDK Android), journal de marculus (`pilotage/journal.md`, ajout seul) ; commits en français (Conventional Commits) ; push sur `ccr-b52c1910-gjp34w` ; sha. Pas de modification des numéros de version à la main. L'orchestrateur ouvre la PR (squash au merge, titre conventionnel).

## L'Homme

`dev` + `testeur` (tests écrits depuis le brief), worktree marculus ; relu par le `relecteur`. Budget 4 $.
