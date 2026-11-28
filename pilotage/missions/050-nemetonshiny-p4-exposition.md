# Mission 050 — nemetonshiny-p4-exposition

> Proposée le 2026-11-28, hors cycle, sur la consigne de Pascal (« ajoute les en fait dans le dépôt nemetonplateforme dans le répertoire pilotage/missions »). **Non validée** : carte au bac à sable, portes n° 1 et n° 2 à passer avant tout lancement.
> Origine : brief `specs/072-p4-rendement-net-risque/brief-nemetonshiny.md` de `nemeton` (PR nemeton #716, ouverte et non fusionnée le 2026-11-28, statut « Proposé »). Le brief fait foi ; cette fiche n'en recopie rien.
> Dépôt : `nemetonshiny` (session ouverte dans le projet, ADR 0001). Fusion par l'orchestrateur quand les contrôles sont verts. **La release de nemetonshiny n'est pas posée par la mission.**

## Mission

**En une phrase (quoi, et pourquoi) :** Exposer l'indicateur P4 dans nemetonshiny (partie A du brief : champs vocation et perte saisie par UGF, affichage, i18n, export), pour que le gestionnaire déclare la vocation de chaque UGF et lise son rendement net, son écart et sa décision.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- Le brief, en entier : § 0 (consignes) et partie A. La partie B (plan d'actions piloté par P4) est hors de cette mission.
- La spec 072 de `nemeton` (lecture seule) : § 6 (sorties) et § 10 (jeu d'essai de référence).
- Dans `nemetonshiny` : `CLAUDE.md`, `pilotage/` du projet, le format de sauvegarde des données UG et son versionnage, `R/mod_family.R`, `R/mod_synthesis.R`, `R/utils_i18n.R`, le service d'export.

## Contrat amont lu

La release de nemeton qui porte `indicateur_p4_rendement_net()` (mission 049), ses colonnes de sortie et son fichier de paramètres. Le plancher `nemeton (>= …)` de `DESCRIPTION` suit cette release.

## Cas limites (un test par cas, qui échoue sans le changement)

1. **Aller-retour** : `vocation` et `perte_saisie` survivent à une sauvegarde puis un chargement des données UG ; un projet sans ces champs se charge sans erreur.
2. **Vocation** : liste fermée, cinq valeurs ; une UGF sans vocation n'affiche pas de décision P4.
3. **P4 absent** (sources non fournies) : la famille P s'affiche comme aujourd'hui.
4. **Signal seulement** : un P4 sous NDP 3 s'affiche comme un signal, sans décision de coupe.
5. **i18n** : clés FR et EN pour l'indicateur, les quatre décisions, les cinq vocations et les quatre aléas ; aucun texte en littéral.
6. **Export** : colonnes P4 présentes dans le GeoPackage et le rapport.
7. **Aucune logique métier dans l'app** : le calcul vient de nemeton.

## Ce qui est attendu

1. Les changements des cas 1 à 7, tests compris.
2. `.claude/test-command`, CI verte.
3. Version, `NEWS.md`, journal et `PLAN.md` selon le `CLAUDE.md` du projet. Pas de version stable ni de tag.
4. Corps de la PR : pour chaque point de la partie A du brief, ce qui est fait.

## L'Homme

- **Agent :** `dev`, dans une session ouverte dans `nemetonshiny`. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget à fixer par Pascal ; worktree depuis `origin/main`.
- **Ce qui ne lui est pas demandé :** la partie B du brief (moteur de règles, arbitrage par le LLM, profils experts, boucle d'évaluation), qui demande d'abord une extension de la spec 072 côté cœur ; l'affichage du risque de ruine et de Pareto, qui attend les jalons M2 de la spec ; toucher nemeton ou un autre dépôt ; poser une release ; fusionner.
- **Dépend de / rouge attendu jusqu'à :** la release de nemeton issue de la mission 049. Rouge attendu tant qu'elle n'est pas publiée.
