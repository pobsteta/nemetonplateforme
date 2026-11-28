# Mission 057 — sommier-plants-robustesse

> Ouverte le 2026-11-25 au cycle 18, sous la délégation de Pascal du jour. Origine : restes de la mission 054 (sommieR #88, fusionnée 29c3c62), relevés par le `relecteur` et le `dev` (journal du 2026-11-25, lignes `054`).
> Dépôt : `sommieR`, depuis la session cloud (branche `ccr-b52c1910-gjp34w`, repartie de `origin/main` 29c3c62). Fusion par l'orchestrateur quand les six contrôles sont verts. Pas de release.

## Mission

**En une phrase (quoi, et pourquoi) :** Durcir le suivi des plants livré par la 054 (unicité du numéro de plant par placette garantie par la base, jour de contrôle compté en heure de Paris comme Surculus, test d'import du plant mort omis), pour que le registre reste juste même en cas d'écritures concurrentes ou de contrôle fait tard le soir.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Choix de l'orchestrateur (délégation)

1. **Unicité (placette, numéro) en base** : un index unique partiel, ou une contrainte équivalente, sur les entrées `plant` (registre 6), en plus de la vérification applicative existante. **Ajout seul** : rien n'est réécrit ; si la base contient déjà un doublon, l'installation du schéma échoue avec un message clair, sans rien modifier.
2. **Jour de contrôle en Europe/Paris** : la date civile qui compare un regarni ou un pointage à un contrôle (`pointe_le` vs date du contrôle) se calcule en `Europe/Paris`, comme Surculus (jour civil Paris), et non plus en UTC. Le dire dans NEWS.
3. **Test d'import « mort omis »** : une tournée GeoPackage où un plant mort au passage 1 n'a pas d'état au passage 2 est refusée, sans aucune écriture (la règle (a) de la 054 passe déjà par la même fonction ; ce test le prouve à l'import).
4. **En-tête de `specs/brief_travaux-2_plants.md`** : mise en forme du bloc d'écart (sauts de ligne), sans changement de sens.

**Hors mission** (gardés, à trancher avec Surculus ou faute d'outil) : modèle QField (PyQGIS absent), versement des plants à l'aller, démo Couchey, `SOMMIER_METHODES_POINTAGE`.

## Cas limites (un test par cas, contre la vraie base ; qui échoue sans le changement)

1. Deux plants de même numéro dans la même placette écrits en contournant la vérification applicative (insertion directe ou deux transactions) : la base refuse le second.
2. Base existante sans doublon : installation du schéma sans erreur ; avec un doublon fabriqué : échec clair, rien modifié.
3. Un plant pointé le 2026-06-15 à 23 h 30 heure de Paris (21 h 30 UTC) et un contrôle daté du 2026-06-15 : accepté (même jour civil à Paris) ; et le cas symétrique qui changeait de jour en UTC.
4. Import « mort omis » refusé, nombre d'entrées inchangé.

## Ce qui est attendu

1. Code R et SQL, tests, contre-épreuve sur `origin/main` (base neuve).
2. `.claude/test-command` avec base jointe (0 échec, 0 saut de base) ; `devtools::check(document = FALSE, error_on = "warning", args = "--no-tests")`.
3. NEWS en développement ; DESCRIPTION reste `2026.11.2.9000`.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), dans un worktree de sommieR. Relu par le `relecteur`.
- **Moyens :** budget 2 $ ; PostGIS local.
- **Ce qui ne lui est pas demandé :** les points hors mission ; release ; PR ; fusion.
- **Dépend de / rouge attendu jusqu'à :** rien.
