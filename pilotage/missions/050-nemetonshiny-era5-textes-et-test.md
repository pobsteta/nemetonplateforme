# Mission 050 — nemetonshiny-era5-textes-et-test

> Ouverte le 2026-11-24 au cycle 18, sur le « oui, travaille sur tous les dépôts de cette instance » de Pascal (restes à solder de la mission 040), sous sa délégation du 2026-11-18.
> Dépôt : `nemetonshiny`, clone de cette session (`/home/user/nemetonshiny`), branche `ccr-104aede3-7r3vop` partie de `origin/main` (seule branche où cette session peut pousser). **Pas de release posée par la mission.**
> Deux PR sont ouvertes dans ce dépôt par sa propre session (nemetonshiny #328, release 2026.11.7 ; #323, fenêtre E-OBS) : ne pas les toucher ; si `main` bouge, se remettre à jour par fusion de `origin/main`.

## Mission

**En une phrase (quoi, et pourquoi) :** Remettre d'accord avec le forçage ERA5 `timeseries` (source par défaut depuis nemeton 2026.11.42) un test et deux textes de l'onglet reGénération restés sur l'ancien chemin, mineurs de la relecture de la mission 040.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- `CLAUDE.md` de nemetonshiny (i18n en `\uXXXX`, cycle `.900x`, NEWS, règles strictes, aucune logique métier).
- Sur `origin/main` ac4cba6 :
  - `tests/testthat/test-regeneration_engine.R` l. 481-507 : le test « un echec timeseries (rsen_era5ts_echec) remonte tel quel » fabrique à la main un message **français** ;
  - `R/mod_regeneration.R` l. 18-30 et 80-90 : commentaires sur « les douze téléchargements mensuels » ;
  - `R/utils_i18n.R` l. 6332, clé `regen_engine_tip` : « 4 requêtes au CDS » et « quelques secondes ensuite (cache partagé) ».
- Dans nemeton (lecture seule, clone `/home/user/nemeton`, `origin/main`) : `R/era5_timeseries.R` (`.rsen_era5ts_abort()`, l. 198, message anglais par `cli::cli_abort`, classe `rsen_era5ts_echec` ; nombre de requêtes CDS par année et par point), `NEWS.md` 2026.11.42 à 2026.11.44.

## Cas limites (un test par cas)

1. **Test d'échec** : la condition simulée est celle que nemeton lève vraiment (produite par `nemeton:::.rsen_era5ts_abort()` si elle existe dans la version installée, sinon recopie fidèle du message anglais et de la classe, avec un commentaire qui cite la source) ; le test vérifie toujours que le message remonte tel quel et sans bascule.
2. **Commentaires** : ce qui ne vaut que pour le chemin classique (douze requêtes mensuelles par année) le dit ; rien n'affirme plus que le chemin par défaut fait douze téléchargements.
3. **Texte `regen_engine_tip` (FR et EN)** : le nombre de requêtes au CDS est celui du code de nemeton (le citer dans le rendu) ; « quelques secondes ensuite » n'a jamais été mesuré (microclimf recalcule sur la grille même avec le forçage en cache) : le remplacer par une formulation qui ne promet pas de durée non mesurée (valeur la plus prudente). Accents en `\uXXXX`. Si un test verrouille ce texte, l'adapter.

## Ce qui est attendu

1. Les trois cas, sans autre changement de code.
2. Les tests touchés lancés seuls, puis `.claude/test-command` si les dépendances le permettent dans ce conteneur (`foretaccess` pourrait y manquer : le dire, sans contourner). Commandes et résultats dans le rendu.
3. Version : `DESCRIPTION` de `2026.11.6.9001` à `2026.11.6.9002`, entrée de développement en tête de `NEWS.md` selon le `CLAUDE.md` ; une entrée datée au journal du `PLAN.md` de nemeton est **hors mission** (autre dépôt) : la proposer dans le rendu, l'orchestrateur l'inscrira.
4. Commit sur la branche `ccr-104aede3-7r3vop`, poussée ; l'orchestrateur ouvre la PR.

**Réponse réelle (`docs/spec.md` § 5) :** sans objet, aucun chemin d'accès à une source externe ne change ; le relecteur le vérifie.

## L'Homme

- **Agent :** `dev`. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** le clone de la session ; R installé dans le conteneur par l'orchestrateur.
- **Ce qui ne lui est pas demandé :** écrire dans nemeton ; poser une release ; toucher les PR #323 et #328 ; fusionner ; changer un comportement de l'app.
- **Dépend de / rouge attendu jusqu'à :** rien.
