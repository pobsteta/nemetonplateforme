# Mission 100 — nemetonshiny-versions-aide

> Ouverte le 2026-11-28 sur la demande de Pascal : « peux-tu ajouter dans l'app la version de nemeton et nemetonshiny dans le "?" Aide du bandeau supérieur ? ». Le motif : après la fusion de la 099, l'app qui tourne sur son PC ne montrait rien de neuf, et il fallait savoir quelle version était installée.
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, partie de `origin/main` 149c3a575 (DESCRIPTION 2026.11.6.9028). Pas de release.

## Mission

**En une phrase :** Afficher, dans la fenêtre d'aide ouverte par le bouton « ? » du bandeau supérieur (`input$show_help`, `R/app_server.R` vers la ligne 175), les versions installées de `nemetonshiny` et de `nemeton`, lues à l'exécution.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. Un helper de service (par ex. `.versions_paquets()` dans un `R/service_*.R` existant ou nouveau) rend les versions de `nemetonshiny` et de `nemeton` (`utils::packageVersion()`, `as.character`) :
   - si un paquet est introuvable, il rend `NA` et non une erreur ;
   - si l'app tourne en `pkgload::load_all()`, il rend la version du DESCRIPTION chargé, ce que `packageVersion` fait déjà pour un paquet chargé par `pkgload`. À vérifier.
2. Dans la fenêtre d'aide, en bas, avant ou après le lien de documentation, une ligne discrète (`small`, `text-muted`), par exemple « Versions : nemetonshiny 2026.11.6.9028 · nemeton 2026.11.47 ».
   - Le libellé passe par l'i18n : nouvelle clé FR/EN en `\uXXXX`, de 30 caractères au plus.
   - Un paquet introuvable s'affiche « inconnue » ou « unknown » via l'i18n.
3. Aucune logique dans le module ou dans l'UI au-delà de l'appel du helper.

## Cas limites (tests)

1. Le helper rend deux chaînes non vides égales à `packageVersion()` des deux paquets.
2. Avec `packageVersion` simulé en erreur pour `nemeton` (stub local) : `NA` pour nemeton, aucune erreur.
3. Le contenu de la fenêtre d'aide contient les deux versions. Tester la fonction qui construit le contenu si elle est extraite, ou faire un `testServer` sur `show_help`.
4. Contre-épreuve sur `origin/main`.

## Ce qui est attendu

Code, tests, contrôle ASCII, tests des fichiers touchés et de `test-i18n_keys_used.R` / `test-utils_i18n.R`, cycle dev `.9029`, NEWS ; commit, push ; sha. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; contrôle par l'orchestrateur, sans relecteur séparé vu la taille. Budget 1 $.
