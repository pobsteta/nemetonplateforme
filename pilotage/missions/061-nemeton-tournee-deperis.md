# Mission 061 — nemeton-tournee-deperis

> Ouverte le 2026-11-25 au cycle 18, sous la consigne de Pascal (« continue le dev des briefs restants dans les projets en validant les meilleurs choix pour la plateforme par toi même »). Origine : brief de Ramulus vers Nemeton `ramulus/pilotage/briefs/vers-nemeton/2026-10-28-ramulus-tournee-deperis.md` (ADR 0003 de Ramulus, acceptée par Pascal le 2026-10-28) ; préalable levé : mission 010 de Ramulus fusionnée (ramulus 3649c13, PR #13). Raison du choix : c'est la source des **notes DEPERIS réelles** qui manquent au spike RECONFORT (mission 060, spec 070).
> Dépôt : `nemeton`, branche imposée `ccr-b52c1910-gjp34w`, partie d'`origin/main`. **Pas de release.** Lecture seule sur ramulus.

## Choix pris par l'orchestrateur (questions du brief, sous la délégation de Pascal)

1. **Noms** : `creer_tournee_deperis()` et `importer_deperis()`, comme proposé (convention NMT respectée).
2. **Schéma** : copie de `ramulus/docs/formats/deperis-v1.schema.json` dans `inst/schemas/deperis-v1.schema.json`, avec son empreinte SHA-256 et le commit Ramulus d'origine notés dans `inst/schemas/README.md` ; un test vérifie l'empreinte. La mise à jour à chaque version du format est faite par une session nemeton sur brief de Ramulus (la copie ne s'édite pas à la main). Les cas communs `fixtures/echange/` sont copiés dans `tests/testthat/fixtures/deperis-v1/` (même règle, même empreinte par fichier dans le README).
3. **Bilan par unité de gestion vers sommieR** : hors de cette mission (le brief ne le fixe pas ; ce sera une mission à part, après un brief sommieR).

## Mission

**En une phrase (quoi, et pourquoi) :** Écrire dans nemeton `creer_tournee_deperis()` (le `deperis.gpkg` de départ, et sa variante de contre-notation) et `importer_deperis()` (le paquet rendu par Ramulus, tout ou rien, rejouable sans doublon, classe recalculée par l'abaque, refus et signalements du catalogue des motifs), validées sur tous les cas communs de `fixtures/echange/` de Ramulus, pour que les notes DEPERIS de terrain entrent dans la plateforme — et, plus tard, dans l'apprentissage RECONFORT.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources (font foi, dans cet ordre ; ne rien inventer)

- `ramulus/docs/formats/deperis-v1.md` (331 lignes) et `deperis-v1.schema.json` : tables, règles du fichier (EPSG:2154, `SPATIAL_INDEX=NO`, options GDAL), version, tournée de contre-notation, paquet rendu, import par Nemeton, instantané, **catalogue des motifs**.
- `ramulus/fixtures/echange/*/attendu.json` (≈ 40 cas : A acceptés, F fusion, R refus, S signalés, T, X illisibles) et la référence Python `fixtures/echange/tests/test_deperis_v1.py` (à lire pour comprendre comment chaque cas se joue ; on la transpose en testthat, on ne l'exécute pas comme source de vérité).
- `ramulus/docs/referentiels/deperis/abaque.csv` et `essences.csv` : la classe se **recalcule** par l'abaque à partir de MB et de MR ou MA.
- Le brief lui-même (§ 1, 2, 3) ; brief Groma vers Nemeton (2026-10-12, § 2.1-2.2) pour les options GDAL, et ce que fait déjà `R/inventaire_video.R` dans nemeton pour un GeoPackage terrain (s'en inspirer, ne pas le modifier).
- `nemeton/CLAUDE.md` (NMT, roxygen anglais, tests, NEWS, PLAN.md, `_pkgdown.yml` : toute nouvelle fonction exportée va dans l'index de référence, sinon pkgdown échoue).

## Ce qui est attendu

1. `creer_tournee_deperis(plan, code, nature, saison, regle_choix = <défaut Kraft 1-3, tour d'horizon depuis le nord sens horaire>, dossier, contre_notation = NULL)` : écrit `deperis.gpkg` (tables `tournee`, `placettes` avec les colonnes du plan, `centres` et `notations` vides ; variante contre-notation sans `notations`, centre du premier opérateur en lecture seule, 5 % des placettes, tirage reproductible). Vérifié contre A1 et A2 (instantanés).
2. `importer_deperis(zip, depart, ...)` : verdict `accepte` / `signale` / `refuse` et la liste des motifs, exactement comme `attendu.json` ; tout ou rien ; rejouable sans doublon (union sur `uuid`) ; fusion de plusieurs paquets (A5, F1, S3) ; classe recalculée par l'abaque, refus si elle diffère (R2) ; les autres motifs du catalogue.
3. Un test testthat **par cas** de `fixtures/echange/`, piloté par `attendu.json`, sans réseau. Un cas qui ne peut pas être joué (dépendance absente) est compté sauté et dit, pas passé sous silence.
4. Copie du schéma et des fixtures avec empreintes (choix 2) ; test d'empreinte.
5. NEWS (développement), `PLAN.md` (entrée datée), `_pkgdown.yml`. `DESCRIPTION` reste en `2026.11.45.9000`.

## Commandes de preuve

- `Rscript -e 'devtools::test(filter = "deperis", stop_on_failure = TRUE)'` (avec `LANG=C.UTF-8 LC_ALL=C.UTF-8`) : sha, code de sortie, durée, réussis / échoués / sautés, et le décompte des cas de `fixtures/echange/` joués sur le total.
- Contre-épreuve : un test rougit si l'abaque est modifié, et un autre si l'import accepte un cas R.

## L'Homme

- **Agent :** `dev` (rôle du plugin `imperatrice`), worktree de nemeton. Relu par le `relecteur`.
- **Moyens :** budget 6 $.
- **Ce qui ne lui est pas demandé :** modifier ramulus ou sommieR ; le bilan vers sommieR ; release ; ouvrir la PR.
- **Dépend de / rouge attendu jusqu'à :** rien (Ramulus 010 fusionnée).
