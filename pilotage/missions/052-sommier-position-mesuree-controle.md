# Mission 052 — sommier-position-mesuree-controle

> Ouverte le 2026-11-25 au cycle 18, sous la délégation de Pascal du jour (« continue le dev des briefs restants dans les projets en validant les meilleurs choix pour la plateforme par toi même »). Origine : brief `surculus/pilotage/briefs/vers-sommier/2026-10-22-position-mesuree-du-controle.md` (complément du 2026-11-02), non traité (inventaire du 2026-11-25 : `R/registre6.R` sans géométrie pour le contrôle, 0 occurrence de `positions_controles` dans sommieR).
> Le brief devait être « déposé » par Pascal dans `specs/` de sommieR : sa délégation du jour couvre ce dépôt, que la mission fait elle-même.
> Dépôt : `sommieR`, depuis la session cloud (branche `ccr-b52c1910-gjp34w`). Fusion par l'orchestrateur quand les six contrôles de `docs/spec.md` § 5 sont verts (`sommieR/pilotage/equipe.md` § Délégation). **Pas de rupture** : ajouts seulement (champs facultatifs, colonnes de vue ajoutées).

## Mission

**En une phrase (quoi, et pourquoi) :** Faire garder par sommieR la position mesurée de chaque contrôle de placette venu de Surculus (géométrie facultative, précision, rattachement par identité, absence de mesure), la lire à l'import de la tournée et l'exposer dans `v_controle_plantation`, pour que le registre sache où chaque contrôle a réellement été fait.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- Le brief, en entier : `/home/user/surculus/pilotage/briefs/vers-sommier/2026-10-22-position-mesuree-du-controle.md` (points 1 à 6). Les noms de Surculus : `precision_m`, `rattache_par_identite`, `sans_position_mesuree`, clé `controle_uuid` ; la couche `positions_controles` de la tournée. Le schéma de l'export de Surculus fait foi pour les noms de colonnes de la couche (le chercher dans `/home/user/surculus`, lecture seule).
- `CLAUDE.md` de sommieR (invariants : ajout seul, chaîne de hachages JCS ; tests contre une vraie base PostGIS ; `R CMD check` sans avertissement ; **ne pas relancer `devtools::document()`** : écrire la roxygen et le `.Rd` à la main si besoin), `pilotage/`.
- Les endroits cités par le brief : `R/registre6.R:150-180`, `R/travaux_qfield.R:262-305`, `inst/sql/003_geometrie.sql:26-31`, `inst/sql/002_vues.sql:366-398`.

## Choix de l'orchestrateur (délégation)

- Garder les noms de Surculus (`precision_m`, `rattache_par_identite`, `sans_position_mesuree`) dans le payload du contrôle : un seul vocabulaire entre les deux dépôts. La géométrie passe par `payload->'geometrie'` comme les autres entrées (POINT WGS 84), pour que `entree_sommier.geom` la reprenne sans nouvelle règle.
- Tout est **facultatif** : un contrôle sans ces champs (anciens appels, anciennes tournées sans la couche) s'écrit comme aujourd'hui. Une tournée sans couche `positions_controles` s'importe comme aujourd'hui.
- Une ligne de `positions_controles` à géométrie NULL donne un contrôle **sans** `geometrie` et `sans_position_mesuree = TRUE` ; jamais un point (0, 0), jamais un POINT EMPTY.
- `v_controle_plantation` gagne des colonnes à la fin (position mesurée, précision, rattachement, `a_position_mesuree` ou équivalent) ; aucune colonne existante ne change de nom, de type ni de place.
- Le brief est déposé dans `specs/brief_travaux-2b_position_controle.md` (nom demandé par le brief), recopié tel quel avec en tête l'origine et la date du dépôt.

## Cas limites (un test par cas, contre la vraie base PostGIS du conteneur ; qui échoue sans le changement)

1. Contrôle avec position, précision et rattachement : payload, `entree_sommier.geom` (en Lambert-93 ou SRID de la table, selon `003_geometrie.sql`), et vue `v_controle_plantation` les rendent. Un contrôle français tombe en France (test de coordonnées).
2. Contrôle sans position mesurée (`sans_position_mesuree = TRUE`, géométrie absente) : geom NULL, drapeau vrai dans la vue, aucun (0, 0).
3. Contrôle à l'ancienne (aucun des nouveaux champs) : identique à aujourd'hui, chaîne de hachages vérifiée (`sommier_verifier` ou équivalent).
4. Import d'une tournée GeoPackage synthétique avec `positions_controles` (une ligne avec POINT, une à géométrie NULL) : les deux contrôles reçoivent ce qu'il faut, clé `controle_uuid`.
5. Import d'une tournée sans couche `positions_controles` : comme aujourd'hui.
6. Une position non WGS 84 ou hors bornes dans le payload : refusée avec un message clair (pas d'écriture partielle ; ajout seul respecté).

## Ce qui est attendu

1. Le code (R et SQL), la roxygen et le `.Rd` tenus à la main si une signature exportée change, les tests ci-dessus.
2. `.claude/test-command` de sommieR **avec la base jointe** (l'orchestrateur installe PostgreSQL et PostGIS dans le conteneur et donne les variables `SOMMIER_TEST_*`) : sha, code de sortie, durée, réussis/échoués/sautés, et « sauts pour base injoignable : 0 ». Plus les fichiers de base touchés hors niveau rapide (`travaux-qfield-db`, `db`, `geometrie-db` au besoin).
3. `R CMD check` sans avertissement (`Rscript -e 'devtools::check(document = FALSE, error_on = "warning")'`).
4. Version : cycle dev selon le `CLAUDE.md` de sommieR (`AAAA.M.N.9000`), entrée NEWS en développement ; pas de release.
5. Contre-épreuve : chaque test rougit sur `origin/main`.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), dans un worktree de sommieR. Relu par le `relecteur`.
- **Moyens :** budget 3 $.
- **Ce qui ne lui est pas demandé :** toucher surculus ; release ; ouvrir ou fusionner la PR.
- **Dépend de / rouge attendu jusqu'à :** rien.
