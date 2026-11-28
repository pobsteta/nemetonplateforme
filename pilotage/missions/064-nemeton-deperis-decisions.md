# Mission 064 — nemeton-deperis-decisions

> Ouverte le 2026-11-25 au cycle 18 sur les décisions de Pascal du même jour (journal, ligne « Pascal · décisions (questions posées une par une) », points 1 à 3), qui soldent les trois questions de sens de la mission 061 (PR nemeton #703, 8862e55).
> Dépôt : `nemeton`, branche imposée `ccr-b52c1910-gjp34w`, partie d'`origin/main`. **Pas de release.** Lecture seule sur ramulus.

## Mission

**En une phrase (quoi, et pourquoi) :** Appliquer dans `creer_tournee_deperis()` / `importer_deperis()` les trois décisions de Pascal (aucun délai de contre-notation, seuil « centre éloigné » de 30 m retenu, graine du tirage des 5 % dérivée du code de tournée) et écrire le brief de retour vers Ramulus, pour que la tournée DEPERIS n'ait plus de valeur provisoire et que Ramulus sache que nemeton lit `deperis-v1`.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les décisions (font foi)

1. **Délai de contre-notation : aucun.** `delai_contre_notation_jours` reste vide par défaut ; la doc le dit comme une décision (plus « provisoire »).
2. **Seuil « centre éloigné » : 30 m**, retenu. `R/deperis.R:25` perd sa mention « PROVISOIRE … non tranché par Pascal » ; le message du motif ne dit plus « seuil provisoire ». Les motifs (codes) attendus par les cas communs ne changent pas.
3. **Graine du tirage des 5 % dérivée du code de tournée** : par défaut, la graine est une fonction déterministe du code de tournée (ex. entier tiré d'un hachage SHA-256 du code, documenté) ; même code ⇒ même tirage, codes différents ⇒ tirages indépendants ; un `graine =` explicite reste possible (rejouer un cas). **Ne pas ajouter de colonne** à la table `tournee` si le schéma `deperis-v1` copié l'interdit (vérifier `inst/schemas/deperis-v1.schema.json` : `additionalProperties`) ; dans ce cas la graine se recalcule depuis `code`, déjà écrit, et c'est dit dans la doc et dans le brief.

## Le brief de retour vers Ramulus

Écrire la copie de référence côté émetteur (nemeton), selon la convention du dépôt pour un brief sortant (chercher l'existant : `specs/*/brief-*.md` ou `briefs/vers-*/`), daté 2026-11-25 : nemeton lit et écrit `deperis-v1` (`creer_tournee_deperis()`, `importer_deperis()`, nemeton #703), copie du schéma et des cas communs avec empreintes (commit Ramulus d'origine fb5739a), T2 sauté (saisie Ramulus), GeoPackage écrit par RSQLite (GDAL déclare MEDIUMINT), décisions de Pascal (pas de délai, 30 m retenu, graine dérivée du code), et le comportement à connaître (conflit d'`uuid` entre paquets = signalement, pas refus). Pas de dépôt dans `~/dev/briefs/` (hors conteneur) : le dire.

## Cas limites (un test par cas)

1. Graine : même code ⇒ mêmes placettes marquées ; deux codes ⇒ tirages différents sur un plan assez grand ; `graine =` explicite garde la priorité.
2. A1 et A2 (instantanés) restent identiques — si A2 dépend de la graine, la reproduire avec `graine =` explicite et le dire.
3. Le motif `centre_eloigne` se déclenche au-delà de 30 m et pas en deçà ; le texte ne contient plus « provisoire ».
4. Tous les cas communs restent au verdict et aux motifs attendus.

## Commandes de preuve

`LANG=C.UTF-8 LC_ALL=C.UTF-8 Rscript -e 'devtools::test(filter = "deperis", stop_on_failure = TRUE)'` ; et, comme #703 l'a appris, rejouer `test-deperis.R` sur le **paquet construit et installé** (le schéma doit se lire par `system.file`). sha, code, durée, réussis/échoués/sautés ; contre-épreuve.

## L'Homme

- **Agent :** `dev`, worktree de nemeton. Relu par le `relecteur`.
- **Moyens :** budget 3 $. Pas de caractères non ASCII dans le code R (`\uXXXX`), nouvelle fonction exportée ⇒ `_pkgdown.yml`.
- **Ce qui ne lui est pas demandé :** bilan vers sommieR ; RECONFORT ; release ; PR ; modifier ramulus.
- **Dépend de :** rien.
