# Mission 073 — nemetonshiny-fordead-tout-calculer-hors-calibration

> Ouverte le 2026-11-26 sur la décision de Pascal (option A) : « je retiens A pour Tout calculer et FORDEAD ».
> Dépôt : `nemetonshiny`, branche `ccr-b52c1910-gjp34w`, après la mission 072. Pas de release.

## Mission

**En une phrase :** Dans « Tout calculer », lancer FORDEAD sur une zone hors de la zone de calibration ONF/DSF, avec un avertissement « classes extrapolées » dans le rapport, et ne sauter l'étape que si la part de résineux est insuffisante, pour appliquer la même règle que R5 et ne plus priver de FORDEAD tous les projets hors Vosges-Jura-Alpes du Nord.

## Constat (origin/main)

`R/mod_monitoring.R` ~l. 3148-3153 : `.lancer_fordead(zone_id)` lit `v <- .validity_for(zone)` et, en chaîne, rend `"hors_domaine"` dès que `v$overall_valid` est FALSE. Or `overall_valid = geo_valid && species_valid` (`nemeton::check_fordead_validity()`, `R/fordead_validity.R`) : le seul critère géographique suffit à sauter. `R/service_applicabilite.R` et `R/service_r5.R` disent au contraire qu'`eligible_fordead_out_of_calibration` n'est pas un refus.

## Attendu

1. En chaîne (zone imposée) : saut seulement si `species_valid` est FALSE (résineux insuffisants) — motif i18n dédié (« part de résineux insuffisante ») au lieu de `pipeline_skip_hors_domaine`. Hors calibration avec résineux suffisants (ou espèce inconnue, `species_valid` NA) : FORDEAD **tourne** ; le rapport de « Tout calculer » porte une ligne d'avertissement « hors zone de calibration ONF/DSF : classes extrapolées » (clé i18n), et l'étape finit `ok`.
2. Lancement manuel depuis l'onglet : inchangé (la modale de confirmation reste).
3. Libellé `pipeline_skip_hors_domaine` retiré ou réservé au cas résineux, sans clé orpheline (test `i18n_keys_used`).

## Cas limites (tests, cœur simulé)

1. geo FALSE, species TRUE → FORDEAD lancé, avertissement présent dans la réponse de l'étape.
2. geo FALSE, species NA → lancé, avertissement.
3. species FALSE → étape `skipped` avec le motif résineux.
4. geo TRUE, species TRUE → lancé, sans avertissement.
5. Lancement manuel hors domaine → modale toujours affichée.

## Ce qui est attendu

Code, tests, contrôle non ASCII, i18n `\uXXXX`, tests ciblés et `.claude/test-command`, contre-épreuve, cycle dev, NEWS ; commit et push. L'orchestrateur ouvre la PR.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur`. Budget 3 $. Dépend de : 072 fusionnée (branche de session).
