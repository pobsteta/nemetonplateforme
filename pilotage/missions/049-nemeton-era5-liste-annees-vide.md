# Mission 049 — nemeton-era5-liste-annees-vide

> Ouverte le 2026-11-24 au cycle 18, sur le « oui, travaille sur tous les dépôts de cette instance » de Pascal (restes à solder de la mission 041), sous sa délégation du 2026-11-18 (restes et questions de détail tranchés par la valeur la plus prudente et la plus réversible).
> Dépôt : `nemeton`, clone de cette session (`/home/user/nemeton`), branche `ccr-104aede3-7r3vop` partie de `origin/main` (seule branche où cette session peut pousser). **Pas de release posée par la mission.**
> Une autre PR est ouverte dans ce dépôt par sa propre session (nemeton #695, décoloration du feuillage) : ne pas la toucher ; si `main` bouge, se remettre à jour par fusion de `origin/main`.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire dire à `.rsen_era5ts_exiger_annees_closes()` qu'aucune année n'a été demandée quand la liste est vide, au lieu du message actuel « the requested year is missing (NA) », qui décrit un autre cas (reste mineur de la relecture de la mission 041).

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- `CLAUDE.md` de nemeton (versions `.9000`, NEWS, PLAN.md, règles strictes).
- `R/era5_timeseries.R`, l. 198-232 sur `origin/main` 361c799 : `.rsen_era5ts_abort()` et `.rsen_era5ts_exiger_annees_closes()` (`if (!length(annees) || anyNA(annees))`).
- Les tests existants de l'ERA5 `timeseries` (`tests/testthat/test-era5*`), et les lignes de la mission 041 au journal de nemetonplateforme (2026-11-23, relecture « prête » : « liste d'années vide refusée avec le message « missing (NA) » »).

## Cas limites (un test par cas, qui échoue sans le changement quand il change un comportement)

1. **Liste vide** (`integer(0)`, `NULL`) : erreur de classe `rsen_era5ts_echec`, levée avant tout appel au CDS, dont le message dit qu'aucune année n'a été demandée (et non « missing (NA) »). Ce test échoue sur `main`.
2. **Année `NA`** seule ou dans une liste : message « missing (NA) » inchangé, même classe.
3. **Année ouverte** (en cours, future, close depuis moins de 5 jours) : message et classe inchangés (test existant suffisant s'il le couvre ; le citer).
4. **Années closes** : aucune erreur.

## Ce qui est attendu

1. Le changement dans `R/era5_timeseries.R`, messages en anglais (convention du cœur), et les tests des cas 1 à 4.
2. `.claude/test-command` du dépôt, et le fichier de tests ERA5 seul ; les deux commandes et leur résultat dans le rendu.
3. Version : `DESCRIPTION` en `2026.11.45.9000` (ouverture du cycle de développement ; NEWS et CITATION restent sur 2026.11.45, selon le `CLAUDE.md`) ; une entrée datée au journal de `PLAN.md`. Pas de version stable ni de tag.
4. Commit sur la branche `ccr-104aede3-7r3vop`, poussée ; l'orchestrateur ouvre la PR.

**Réponse réelle (`docs/spec.md` § 5, note du 2026-11-24) :** sans objet, le refus a lieu avant tout appel à une source externe ; le relecteur le vérifie.

## L'Homme

- **Agent :** `dev`. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** le clone de la session ; R installé dans le conteneur par l'orchestrateur (paquets binaires r2u).
- **Ce qui ne lui est pas demandé :** poser une release ; toucher un autre dépôt ou la PR #695 ; fusionner ; changer le chemin classique mcera5.
- **Dépend de / rouge attendu jusqu'à :** rien.
