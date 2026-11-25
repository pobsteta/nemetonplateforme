# Mission 065 — sommier-plants-aller-pointage

> Ouverte le 2026-11-25 au cycle 18 sur les décisions de Pascal du même jour (journal, ligne « Pascal · décisions (questions posées une par une) », points 4 et 5). Origine : brief Surculus → sommieR `surculus/pilotage/briefs/vers-sommier/2026-10-15-travaux-2-plants.md`, restes « Non fait » de `sommieR/NEWS.md` (l. ~72).
> Dépôt : `sommieR`, branche imposée `ccr-b52c1910-gjp34w`, partie d'`origin/main` (démo Couchey avec plants déjà fusionnée, #90). **Pas de release.** Fusion en squash.

## Mission

**En une phrase (quoi, et pourquoi) :** Verser dans le projet QField d'un contrôle suivant les plants vivants déjà pointés avec leur dernier état (`sommier_projet_qfield_travaux()`), et fixer `SOMMIER_METHODES_POINTAGE` aux valeurs reprises de Surculus, pour que le forestier retrouve et renote chaque plant au contrôle suivant et que la méthode de pointage d'une position soit dite avec un vocabulaire fermé.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les décisions (font foi)

1. **Plants à l'aller : les plants vivants (dernier état `sain` ou `atteint`), avec leur dernier état**, dans les couches que Surculus lit déjà (schéma réel : `surculus` lecture seule, formats `docs/formats/`, couches `plants`, `etats_plants` ; fixtures de la mission 054). Les morts et absents restent au registre et ne partent pas. Un regarni vivant part comme un plant. Une placette sans plant part comme avant.
2. **`SOMMIER_METHODES_POINTAGE`** = `c("relatif_boussole", "relatif_saisie", "gnss_plant", "construit")`, d'après Surculus (`docs/formats/journal-valeurs-v1.md`, `source_azimut` = `boussole_telephone` / `saisie` ; ADR 0003 : plants relatifs au piquet ; `construit` = position de démonstration ou reconstituée). Là où le registre ou l'import porte une méthode de pointage, une valeur hors liste est refusée (faute listée, rien écrit), comme les autres référentiels du dépôt. Si aucune colonne ne porte encore la méthode, l'ajouter selon le patron des migrations du dépôt (`inst/sql/`, `sommier_init_schema()`), en ajout seul et sans changer le hachage des entrées existantes ; la démo Couchey prend `construit`.

## Les sources

- `sommieR/CLAUDE.md` (registres en ajout seul, chaîne de hachages, tests PostGIS réels, `.claude/test-command`, ne pas relancer `devtools::document()`).
- `R/travaux_qfield.R` (`sommier_projet_qfield_travaux()` l. 96, import `sommier_importer_qfield_travaux()`), `R/travaux_plants.R`, `R/registre6.R`, la spec `specs/brief_travaux-2_plants.md` (l. 9, 93), NEWS des missions 054 et 057.

## Cas limites (un test par cas, contre une vraie base PostGIS)

1. Un contrôle suivant reçoit les plants vivants, leur numéro, leur position et leur dernier état ; les morts et absents ne partent pas ; un regarni vivant part.
2. Aller-retour : projet préparé → (états du nouveau contrôle) → import : aucun plant dupliqué, aucun numéro changé, chaîne intacte.
3. Projet d'une placette sans plant : identique à avant (non-régression).
4. Méthode de pointage hors liste refusée à l'import et à l'écriture ; chaque valeur de la liste acceptée.

## Commandes de preuve

`.claude/test-command` de sommieR (PostgreSQL 16 + PostGIS : `pg_ctlcluster 16 main start` ; base de test déjà créée : `SOMMIER_TEST_HOST=/var/run/postgresql SOMMIER_TEST_USER=root SOMMIER_TEST_DB=sommier_test_m062`) et `R CMD check`. sha, code, durée, réussis/échoués/sautés (aucun test de base sauté) ; contre-épreuve.

## L'Homme

- **Agent :** `dev`, worktree de sommieR. Relu par le `relecteur`.
- **Moyens :** budget 4 $.
- **Ce qui ne lui est pas demandé :** le modèle QField PyQGIS (`data-raw/qfield_modele.py`, PyQGIS absent) ; les demandes complémentaires du brief (EPSG:9794, codes ONF, « hors entreprise ») ; release ; PR ; modifier surculus.
- **Dépend de :** rien.
