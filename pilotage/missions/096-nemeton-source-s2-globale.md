# Mission 096 — nemeton-source-s2-globale

> Planifiée le 2026-11-27 sur les décisions de Pascal (questions posées une par une) : « comme la chaîne THEIA fonctionne bien avec l'AOI, ne peut-on pas prévoir un calcul FAST/FORDEAD/RECONFORT/ICD avec THEIA et Sen2Cor au choix ? » → **un seul choix global** de source Sentinel-2 par projet, **THEIA/MAJA par défaut** (projets neufs et existants), repli Sen2Cor si THEIA est en panne.
> Dépôt : `nemeton`, après la PR #710 (release), la 089 (repli THEIA → GEODES) et la 095 (RECONFORT sur Sen2Cor) : missions en série dans ce dépôt. Puis une mission nemetonshiny (réglage dans Sources & paramètres, source affichée sur chaque carte).

> **Mise à jour du 2026-11-27, au lancement.** Partir d'`origin/main` 2fae116, qui contient la 089 et la 095 (DESCRIPTION en 2026.11.46.9001, passer en `.9002`). **Décision de Pascal du jour, prise après les études 092 et 093 : la source par défaut se règle par méthode.** Chaque méthode garde la source sur laquelle elle est calée : RECONFORT = `"theia"`, FAST, FORDEAD et ICD = `"sen2cor"`. Le choix global par projet reste possible : `source_s2 = NULL` (défaut par méthode), `"theia"` ou `"sen2cor"`, appliqué aux quatre méthodes. Une méthode qui tourne sur une source où elle n'est pas calée le signale dans ses métadonnées (`calee_sur`, `validee = false`) et par un avertissement de classe dédiée. Le point 5 ci-dessous ne vaut donc que dans ce cas. Les projets existants restent à l'identique (Sen2Cor pour FAST, FORDEAD et ICD). Le repli de RECONFORT (THEIA → GEODES → Sen2Cor, 089) et celui de « conda absent » ne changent pas. Repli des méthodes en THEIA choisi : THEIA indisponible → Sen2Cor, série entière. Budget : 6 $. Livrer en un ou deux commits sur la même branche ; si la comparaison de Couchey (point 7) dépasse le budget, la donner en « non fait », avec ce qui manque.

## Mission

**En une phrase :** Donner au suivi sanitaire du cœur une source Sentinel-2 unique et choisie (`"theia"` = MAJA par lecture fenêtrée du catalogue THEIA, `"sen2cor"` = Planetary Computer), utilisée par FAST, FORDEAD, RECONFORT et l'ICD, avec THEIA par défaut, un repli sur Sen2Cor quand THEIA est indisponible, et la source inscrite dans chaque sortie.

## Attendu (à préciser au lancement)

1. Couche d'acquisition commune : généraliser la lecture fenêtrée de `R/reconfort_fenetre.R` (MAJA FRE, masques CLM/SAT/EDG) en un fournisseur de scènes pour le cache du suivi sanitaire, à côté du fournisseur Planetary Computer existant (Sen2Cor, offset BOA, SCL) ; même interface de scènes (dates, bandes, masque de validité), caches séparés par source.
2. Paramètre `source_s2 = c("theia", "sen2cor")` porté au niveau projet/zone et passé aux quatre méthodes ; défaut `"theia"`.
3. Repli : THEIA indisponible (délai, connexion, 5xx) → Sen2Cor, avertissement de classe dédiée, source effective inscrite ; 401/403 → erreur claire (clés).
4. **Jamais de mélange de sources dans une même série** : une série temporelle (FORDEAD, FAST, ICD) est calculée entièrement sur une source ; si le repli intervient en cours de série, la série entière bascule et le dit.
5. Chaque sortie (rasters, tables, `run_meta`) porte `source_s2` effective ; les méthodes calées sur une autre source le signalent (FAST, FORDEAD, ICD calés sur Sen2Cor tournent désormais sur MAJA par défaut : avertissement dans NEWS et dans les métadonnées ; seuils à revoir, études 092/093).
6. Vérifier si FORDEAD (bibliothèque INRAE) lit nativement le format THEIA (à confirmer dans sa documentation, sans le supposer).
7. Tests sans réseau (fournisseurs simulés), et une comparaison sur Couchey des sorties FAST/FORDEAD/ICD entre les deux sources (ordre de grandeur des écarts), rendue dans le rapport.

## L'Homme

`dev`, worktree nemeton ; relu par le `relecteur`. Budget à fixer au lancement (mission de plusieurs étapes).
