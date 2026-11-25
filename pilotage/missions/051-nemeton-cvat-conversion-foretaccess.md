# Mission 051 — nemeton-cvat-conversion-foretaccess

> Ouverte le 2026-11-25 au cycle 18, sous la délégation de Pascal du jour (« continue le dev des briefs restants dans les projets en validant les meilleurs choix pour la plateforme par toi même »). Origine : brief `groma/briefs/vers-nemeton/2026-11-20-relief-cvat-houppiers-foret.md`, § 2.3 ajouté le 2026-11-21 (conversion du CVAT de foretaccess), resté non traité (inventaire du 2026-11-25).
> Dépôt : `nemeton`, depuis la session cloud (branche `ccr-b52c1910-gjp34w`, repartie de `origin/main` après la fusion de #698). Fusion par l'orchestrateur à la CI verte (délégation du 2026-11-16 ; pas de chemin d'accès externe). **Pas de release.**

## Le constat (vérifié par l'orchestrateur sur `origin/main` 33e861a)

- `.iv_ecrire_cvat()` (`R/inventaire_video.R:1713-1750`) lit un CVAT Byte (codage foretaccess : relief 0 à 254, 255 = nodata), met 255 à NA, puis calcule `1 + round(v / 255 * 254)` : une source 254 donne 254, une source 0 donne 1. Le brief exige **source + 1** (0 → 1, 254 → 255) et 255 → 0.
- Un CVAT déjà au format Groma (Byte, nodata 0, valeurs 1 à 255) n'est pas reconnu : il est reconverti.
- Tout autre codage (autre nodata, autre type, autre résolution) donne un `cli_warn` et un projet sans `cvat.tif`. Le brief demande une **erreur**, jamais une conversion silencieuse.
- La référence de Groma est `exemples/creer_marsannay_p067.py`, fonction `decouper_cvat()` (dépôt `groma`, lecture seule).

## Mission

**En une phrase (quoi, et pourquoi) :** Faire écrire à `creer_projet_inventaire_video()` un `rasters/cvat.tif` exactement au codage attendu par Groma (source foretaccess + 1, 255 → 0 ; format Groma recopié tel quel ; tout autre codage refusé par une erreur), pour que le relief affiché sur le téléphone soit juste au niveau de gris près.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Choix de l'orchestrateur (délégation)

- Un CVAT en **flottant** `[0, 1]` (cache de `generate_rvt()`) reste accepté et mis à l'échelle `1 + round(v * 254)` : c'est la formule du brief pour le relief `[0, 1]`, et le refuser casserait un chemin qui marche aujourd'hui. Tout ce qui n'est ni Byte foretaccess, ni Byte Groma, ni flottant dans `[0, 1]` est refusé.
- Reconnaître les deux codages Byte par le **nodata déclaré** du fichier (255 → foretaccess, 0 → Groma) ; Byte sans nodata déclaré : refusé (on ne devine pas).
- L'erreur est levée (`cli::cli_abort`, classe dédiée) par `creer_projet_inventaire_video()` quand `cvat_path` est donné et illisible ou mal codé ; un fichier **absent** reste un avertissement comme aujourd'hui (l'app ne passe le chemin que si le fichier existe ; un absent est un cas de course, pas un mauvais codage).
- Rééchantillonnage : au plus proche voisin pour les deux codages Byte (pas de niveaux mélangés), après mise à NA du nodata, comme aujourd'hui.

## Cas limites (un test par cas, qui échoue sans le changement ; sans réseau ; rasters synthétiques dans `withr::local_tempdir()`)

1. Byte foretaccess, déjà sur la grille 2 m : 0 → 1, 127 → 128, 254 → 255, 255 → 0.
2. Byte Groma (nodata 0, valeurs 1 à 255) : recopié sans changement de valeur.
3. Flottant `[0, 1]` : `1 + round(v * 254)`, NA → 0 (comportement actuel gardé).
4. Byte sans nodata déclaré, Int16, flottant hors `[0, 1]`, résolution autre que 2 m pour un Byte : erreur de classe dédiée, aucun `cvat.tif` écrit, aucun projet à moitié écrit.
5. Hors de l'emprise : 0 (nodata), comme aujourd'hui.
6. Les tests existants du CVAT (`test-inventaire-video-foret.R`) restent verts, ou sont corrigés là où ils figeaient l'ancienne formule fausse (le dire dans la PR, fichier:ligne).

## Ce qui est attendu

1. Le correctif dans `R/inventaire_video.R`, roxygen de `cvat_path` mise à jour (codages acceptés, erreur).
2. `.claude/test-command` **et** `Rscript -e 'devtools::test(filter = "inventaire-video|houppiers", stop_on_failure = TRUE)'` ; pour chacun : sha, code de sortie, durée, réussis/échoués/sautés. Le conteneur a terra 1.7-65 : 8 échecs préexistants au niveau rapide (`flowAccumulation`, `test-indicators-frost.R:63`), à distinguer.
3. Contre-épreuve : chaque test rougit sur `origin/main`.
4. `DESCRIPTION` reste en `2026.11.45.9000` ; entrée NEWS en développement (`fix`) ; entrée datée dans `PLAN.md` selon `CLAUDE.md`.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), dans un worktree de nemeton. Relu par le `relecteur`.
- **Moyens :** budget 2 $.
- **Ce qui ne lui est pas demandé :** toucher nemetonshiny ou groma ; release ; ouvrir ou fusionner la PR.
- **Dépend de / rouge attendu jusqu'à :** rien.
