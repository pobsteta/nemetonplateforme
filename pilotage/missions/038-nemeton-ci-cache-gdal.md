# Mission 038 — nemeton-ci-cache-gdal

> Ouverte le 2026-11-21 au cycle 14, sous la délégation (porte n° 3) : la CI de nemeton est rouge pour toute PR depuis le changement d'image `ubuntu-latest`, ce qui bloque la fusion de la mission 037 (PR #668).
> Dépôt : `nemeton` (session ouverte dans le projet, ADR 0001). Fusion par l'orchestrateur quand les contrôles sont verts.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire que le cache des paquets R de la CI de nemeton ne soit plus réutilisé quand la bibliothèque système GDAL change, pour que les PR repassent au vert sans perdre le gain de temps du cache.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- Le constat : run https://github.com/pobsteta/nemeton/actions/runs/44879677167 (PR #668, 2026-11-21). `sf.so` ne trouve pas `libgdal.so.34`. Le cache `actions/cache` (`.github/workflows/r.yml`, étape « Cache des paquets R », l. 118-126) a pour clé l'OS, la version de R et l'empreinte de `DESCRIPTION`, sans rien qui dépende de l'image ni de GDAL. Dernière CI verte sur `main` : 70618fd, le 2026-11-16.
- Dans `nemeton` : `CLAUDE.md`, `.github/workflows/r.yml` (jobs l. 22, 64, 189, 292), `.github/workflows/pkgdown.yaml`, `.github/workflows/release.yml`, et les commentaires du workflow sur le cache (l. 95-106 et 223-232), qui expliquent pourquoi le cache est géré à la main.

## Contrat aval lu

Aucun : la CI n'est pas un contrat public. Le seul effet attendu est que les PR de nemeton (dont #668) repassent au vert.

## Cas limites (chacun vérifié par une CI réelle, faute de test unitaire possible)

1. **Image inchangée** : le cache est réutilisé (« Cache restored from key » dans le log), et le temps d'installation reste celui d'avant.
2. **GDAL du runner différente de celle du cache** : le cache n'est pas réutilisé, ou les paquets liés à GDAL (`sf`, `terra`, et tout paquet compilé contre `libgdal`, `libproj` ou `libgeos`) sont recompilés. `library(sf); library(terra)` passent.
3. **Même correction dans chaque job et chaque workflow** qui restaure ce cache (`r.yml`, `pkgdown.yaml`, `release.yml` s'il le fait). Aucun ne garde l'ancienne clé.
4. **`restore-keys`** : un préfixe large ne doit pas ramener un cache d'une autre GDAL. Le vérifier, sinon le défaut revient par cette porte.
5. Choix prudent, à défaut d'une meilleure solution : mettre dans la clé la version de la bibliothèque GDAL du runner (lue avant la restauration, par exemple avec `dpkg-query` ou `gdal-config` après l'installation des dépendances système, en réordonnant les étapes si besoin) plutôt que `ImageVersion`, qui changerait chaque semaine. Le noter dans la PR.

## Ce qui est attendu

1. Correction des workflows. Commentaire en français dans le YAML, qui dit pourquoi la clé contient GDAL (incident du 2026-11-21).
2. CI verte sur la PR, sans `.claude/test-command` modifiée. Joindre à la PR l'extrait du log qui montre le cas 2 (cache non réutilisé ou recompilation) puis le cas 1 (une seconde exécution qui réutilise le cache), si la seconde exécution est possible sans pousser de code inutile.
3. Journal du projet en ajout seul s'il en a un ; `NEWS.md` seulement si `CLAUDE.md` l'exige pour un changement de CI.
4. `.claude/test-command` lancée avant de dire terminé.

## L'Homme

- **Agent :** `dev`, dans une session ouverte dans `nemeton`. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 3 $ (plafond du lanceur) ; worktree depuis `origin/main`.
- **Ce qui ne lui est pas demandé :**
  - toucher la PR #668 ou sa branche `mission/037` ;
  - changer la version, poser un tag ou une release ;
  - toucher un autre dépôt ;
  - fusionner.
- **Dépend de / rouge attendu jusqu'à :** rien. La PR #668 attend cette fusion pour repasser au vert.
