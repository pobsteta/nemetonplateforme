# Mission 079 — sommier-brief-surculus-aller

> Ouverte le 2026-11-26 (« continue le dev des briefs restants »). Reste de la mission 065 (PR sommieR #91, relecture du 2026-11-25) : trois écarts à signaler à Surculus sur les plants envoyés à l'aller.
> Dépôts : `sommieR` (émetteur, copie de référence du brief) et `surculus` (destinataire, par issue). Branche `ccr-b52c1910-gjp34w` dans sommieR. Pas de release.

## Mission

**En une phrase :** Écrire, depuis sommieR, le brief vers Surculus qui décrit exactement les trois écarts entre ce que sommieR écrit dans le projet QField à l'aller et la spec de Surculus — colonne `methode_pointage` dans `plants`, `controle_uuid` des états d'aller sans contrôle dans la couche `controles`, `uuid` d'état dérivés (md5, pas v4) — avec, pour chacun, ce que fait sommieR, ce que dit la spec de Surculus (fichier:ligne), et la question posée à Surculus, pour que Surculus tranche sans deviner.

## Attendu

1. Lire le code de sommieR (`R/` des plants à l'aller, mission 065, a586121) et la spec de Surculus (lecture seule, `/home/user/surculus/docs/`, couches du `travaux.gpkg`, l. ~494-496 citées par le relecteur) ; vérifier chaque écart sur les fichiers, preuves à l'appui (fichier:ligne, commit).
2. Écrire le brief dans sommieR, `specs/brief-surculus-plants-aller.md`, selon le style des briefs existants de `specs/` ; pour chaque écart : constat, effet sur Surculus (lecture du gpkg, import), options (garder / renommer / retirer côté sommieR, ou accepter côté Surculus), question.
3. Ne rien changer au code de sommieR (aucun écart n'est tranché ici).
4. Commit et push sur la branche ; l'orchestrateur ouvre la PR sommieR (doc seule) et l'issue sur surculus.

## L'Homme

`dev`, worktree de sommieR ; relu par le `relecteur`. Budget 2 $. Dépend de : rien.
