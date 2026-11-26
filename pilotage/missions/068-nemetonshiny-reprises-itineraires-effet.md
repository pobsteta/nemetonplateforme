# Mission 068 — nemetonshiny-reprises-itineraires-effet

> Ouverte le 2026-11-26 sur les décisions de Pascal du même jour (journal, ligne « Pascal · décisions (11 questions…) », points 2, 4, 5, 6, 9). Suites des missions 066 (PR #336) et 067 (PR #338), fusionnées.
> Dépôt : `nemetonshiny`, branche imposée `ccr-b52c1910-gjp34w`, partie d'`origin/main` (e717220 ou plus récent). **Pas de release.**

## Mission

**En une phrase (quoi, et pourquoi) :** Appliquer cinq décisions de Pascal aux vues Itinéraires et Effet de la gestion — détail des exclusions affiché traduit, libellés complets des 15 profils, sélecteur de la référence de comparaison, effectif des UGF exclues affiché, bouton « Calculer l'effet » en bouton à bordure — pour que ces vues disent pourquoi, à qui et contre quoi elles comparent.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les décisions (font foi)

1. **Itinéraires, détail traduit** : le `detail` rendu par `nemeton::itineraires_admissibles()` pour une exclusion s'affiche en infobulle sur la raison, en français et en anglais, valeur observée contre seuil, codes remplacés par des noms lisibles (essences : libellé de l'essence ; SER : nom de la sylvoécorégion si l'app l'a, sinon le code avec « SER »). Lire la forme réelle de `detail` dans le cœur (`nemeton/R/itineraires.R`) et traduire par motif ; un `detail` de forme inconnue s'affiche tel quel plutôt que d'être perdu. Aucun littéral : i18n `\uXXXX`.
2. **Itinéraires, libellés complets** : les 15 profils du sélecteur ont leur nom complet (Propriétaire privé, Propriétaire public, Gestionnaire ONF, …, Chasseur, …), FR/EN, sans alias ambigu. Le sélecteur reste propre à la vue (décision 1 : profils séparés).
3. **Effet, sélecteur de référence** : liste des types de gestion renseignés (hors `non_renseigne`), défaut = le plus fréquent ; la valeur est passée en `reference =` à `nemeton::effet_gestion()` ; changer de référence efface le tableau (même règle que pour les types, décision 8).
4. **Effet, UGF exclues** : sous le tableau (ou avant le calcul), « n UGF sans type déclaré, exclues » quand n > 0.
5. **Effet, bouton** : « Calculer l'effet de la gestion » passe en `btn-outline-primary` (le PDF reste l'action principale de la Synthèse) ; toujours `input_task_button` lié à l'`ExtendedTask`.

## Les sources

`nemetonshiny/CLAUDE.md` (i18n, ASCII dans le code R, couleurs de boutons, pas de logique métier dans `mod_*`, cycle dev, NEWS) ; `R/mod_itineraires.R`, `R/service_itineraires.R`, `R/mod_effet_gestion.R`, `R/service_effet_gestion.R`, `R/utils_i18n.R`, `inst/experts/*.yml` ; cœur en lecture : `nemeton/R/itineraires.R`, `nemeton/R/effet_gestion.R`.

## Cas limites (un test par décision, sans réseau)

1. Une exclusion `essence_absente` (et une `station_insuffisante`, `pente`…) a son infobulle traduite, sans code brut ; un `detail` inconnu ressort tel quel.
2. Les 15 libellés de profil existent en FR et EN, aucun ne vaut « Propriétaire » seul.
3. Le cœur reçoit `reference = <choix>` ; défaut = type le plus fréquent ; changer de référence efface le tableau.
4. Avec 3 UGF `non_renseigne`, le texte « 3 UGF … exclues » apparaît ; avec 0, rien.
5. Le bouton porte `btn-outline-primary` et pas `btn-primary`.

## Ce qui est attendu

Code et tests ; `LC_ALL=C grep -nP '[^\x00-\x7F]' R/*.R | grep -v ':\s*#'` vide ; tests ciblés (`itineraires|effet_gestion|i18n`) et `.claude/test-command` (échec préexistant connu : `test-service_marculus_ortho.R`) ; contre-épreuve ; cycle dev suivant, NEWS ; commit et push sur `ccr-b52c1910-gjp34w`. L'orchestrateur ouvre la PR.

## L'Homme

- **Agent :** `dev`, worktree de nemetonshiny. Relu par le `relecteur`.
- **Moyens :** budget 4 $.
- **Ce qui ne lui est pas demandé :** sources pente/desserte/protection (mission 069) ; Marculus (mission 070) ; release ; PR.
- **Dépend de :** rien.
