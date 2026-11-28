# Mission 054 — sommier-lot2-plants

> Ouverte le 2026-11-25 au cycle 18, sous la délégation de Pascal du jour (« continue le dev des briefs restants dans les projets en validant les meilleurs choix pour la plateforme par toi même »). Origine : brief `surculus/pilotage/briefs/vers-sommier/2026-10-15-travaux-2-plants.md` (lot 2, « plants pointés et suivis »), non traité : sommieR n'a pas de type d'entrée `plant` ni de registre 6 en `r6-1.3.0` (inventaire du 2026-11-25 ; seul `R/travaux_qfield.R:861` cite `"plant"` comme sujet de photo).
> Dépôt : `sommieR`, depuis la session cloud (branche `ccr-b52c1910-gjp34w`, repartie de `origin/main` après la fusion de #87). Fusion par l'orchestrateur quand les six contrôles sont verts (délégation de `sommieR/pilotage/equipe.md`). **Pas de release.** La mission 052 (position mesurée du contrôle, #87, fusionnée) en est voisine : ne pas la défaire.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire tenir par sommieR les plants pointés et suivis de Surculus (un type d'entrée `plant` au registre 6, l'état des plants porté par le contrôle, des totaux qui en découlent et concordent), lus à l'import de la tournée, pour que le registre garde la trace plant par plant de chaque plantation contrôlée.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- Le brief, **en entier** : `/home/user/surculus/pilotage/briefs/vers-sommier/2026-10-15-travaux-2-plants.md` (décisions de conception 1 à 6, livrables, « Ce que Surculus écrit déjà », demandes complémentaires, critères d'acceptation, questions ouvertes). Il fait foi, sauf sur les trois questions tranchées ci-dessous.
- Dans `/home/user/surculus` (lecture seule) : le schéma réel des couches de plants de l'export (`docs/spec.md` § 5, et le code d'export : `Couches.kt`, `ExportTravaux.kt` ou équivalents). Les noms de couches et de champs de Surculus font foi.
- `CLAUDE.md` et `pilotage/` de sommieR (invariants : ajout seul, chaîne JCS, versions de payload ; `R CMD check` sans avertissement ; ne pas relancer `devtools::document()`), `R/registre6.R`, `R/travaux_qfield.R`, `inst/sql/`, les tests de registre 6 et d'import QField, et la mission 052 (`specs/brief_travaux-2b_position_controle.md`, NEWS).

## Choix de l'orchestrateur sur les questions ouvertes du brief (délégation)

1. **Essence au plant**, préremplie par l'essence objectif des travaux suivis (la proposition du brief) : une plantation mélangée doit pouvoir être tenue.
2. **Numérotation** par azimut depuis le nord, sens horaire, fixée au premier pointage et jamais recalculée (règle de Groma, proposée par le brief) ; sommieR la reçoit de Surculus et la garde telle quelle, il ne la recalcule pas.
3. **Registre imprimé** : un décompte des plants sous leur placette (vivants, morts, absents), pas une ligne par plant ; le détail reste dans le registre numérique et ses vues. Moins de papier, et réversible.

## Cas limites (un test par cas, contre la vraie base PostGIS ; qui échoue sans le changement)

Ceux des « Critères d'acceptation » du brief, un test chacun, plus au moins :
1. Un plant s'inscrit (type `plant`, payload `r6-1.3.0`), rattaché à sa placette ; la chaîne se vérifie.
2. Un contrôle qui porte l'état de ses plants : les totaux en découlent et doivent concorder ; un total contradictoire est refusé avant toute écriture.
3. Un contrôle sans plants reste valide et s'écrit comme avant (anciens payloads `r6-1.2.0` relus sans changement de hachage).
4. Un plant mort ou absent le reste : un contrôle suivant qui le dirait vivant est refusé (ou signalé, selon le brief : suivre le brief).
5. Import d'une tournée GeoPackage synthétique avec les couches de plants : plants et états inscrits ; rejeu sans doublon ; tournée sans ces couches : comme avant.
6. Registre imprimé : décompte sous la placette.

## Ce qui est attendu

1. Code R et SQL, roxygen et `.Rd` à la main, tests ci-dessus, contre-épreuve réelle sur `origin/main`.
2. `.claude/test-command` avec la base jointe (0 échec, 0 saut de base), plus les fichiers de base touchés hors niveau rapide (`travaux-qfield-db`, `db`, `registre-imprime-db`, `carte-db` au besoin) ; `Rscript -e 'devtools::check(document = FALSE, error_on = "warning", args = "--no-tests")'`.
3. Version : cycle dev (`2026.11.2.9000` déjà posé par 052 ; ne pas le changer), entrée NEWS en développement ; spec déposée dans `specs/brief_travaux-2_plants.md` (le brief recopié, avec l'origine et les trois choix ci-dessus en tête).

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), dans un worktree de sommieR. Relu par le `relecteur`.
- **Moyens :** budget 4 $ (lot plus gros que 052). PostGIS local.
- **Ce qui ne lui est pas demandé :** toucher surculus ; release ; ouvrir ou fusionner la PR.
- **Dépend de / rouge attendu jusqu'à :** rien (052 fusionnée).
