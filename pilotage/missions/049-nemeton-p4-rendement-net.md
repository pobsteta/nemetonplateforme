# Mission 049 — nemeton-p4-rendement-net

> Proposée le 2026-11-28, hors cycle, sur la consigne de Pascal (« ajoute les en fait dans le dépôt nemetonplateforme dans le répertoire pilotage/missions »). **Non validée** : carte au bac à sable, portes n° 1 et n° 2 à passer avant tout lancement.
> Origine : spec 072 de `nemeton`, `specs/072-p4-rendement-net-risque/spec.md` (PR nemeton #716, ouverte et non fusionnée le 2026-11-28, statut « Proposée »). La spec fait foi ; cette fiche n'en recopie rien.
> Dépôt : `nemeton` (session ouverte dans le projet, ADR 0001). Fusion par l'orchestrateur quand les contrôles sont verts. **La release de nemeton n'est pas posée par la mission** : `DESCRIPTION` reste en `.9000`.

## Mission

**En une phrase (quoi, et pourquoi) :** Ajouter à nemeton l'indicateur conditionnel P4, rendement du capital sur pied net des pertes attendues, avec capital et gain de valeur fournis (jalons M0 et M1 de la spec 072), pour que chaque UGF porte un écart au taux exigé de sa vocation et une décision lisible.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- La spec 072, en entier : § 0 (consignes), § 2 (formules), § 5 (fichier de paramètres), § 6 (sorties), § 10 (jeu d'essai de référence), § 11 (tests).
- Dans `nemeton` : `CLAUDE.md` (convention NMT, cycle `.9000`, règles strictes), `specs/048-sens-radar/spec.md` (0-100, haut = bon), `R/indicators-productive.R`, `R/normalization.R`, `R/indicator-config.R`, `R/family-system.R`, et un indicateur conditionnel existant comme modèle (R5 ou B4).

## Contrat aval lu

- **nemetonshiny** et **nemetonmcp** consomment `famille_production`. P4 étant conditionnel, ce score ne change pour aucun projet existant : c'est le test de non-régression de la spec (§ 11).
- Aucune fonction exportée n'est retirée ni renommée.

## Cas limites (un test par cas, qui échoue sans le changement ; données synthétiques)

1. **Jeu de référence** (spec § 10) : les cinq UGF rendent toutes les colonnes attendues, à 0,005 point près.
2. **Scores R** : le calcul lit `R1_norm` à `R4_norm` et refuse `R1` sans `R1_norm`.
3. **`perte_saisie`** renseignée : remplace le calcul, pertes par aléa à `NA`.
4. **Capital** nul ou manquant : `NA` et avertissement, pas d'erreur fatale.
5. **Vocation** absente du fichier de paramètres : erreur explicite.
6. **R5 présent** : l'aléa sécheresse et sanitaire lit le minimum de `R3_norm` et `R5_norm`.
7. **`P4_norm`** borné à 0 et à 100.
8. **Non-régression** : sans les sources de P4, `famille_production` est inchangée sur `massif_demo_units`.

## Ce qui est attendu

1. `inst/extdata/p4_parametres.yml` et son validateur ; toutes les valeurs marquées `provisoire: true`.
2. `indicateur_p4_rendement_net()`, exportée, documentée, avec les tests des cas 1 à 8.
3. La règle de normalisation de P4 et sa déclaration comme indicateur conditionnel de la famille P.
4. La note d'alignement du jalon M0 dans le corps de la PR : chaque nom de la spec confronté au code réel.
5. `NEWS.md` en développement, `PLAN.md` et version selon le `CLAUDE.md` du projet. Pas de version stable ni de tag.
6. `.claude/test-command`, CI verte.

## L'Homme

- **Agent :** `dev`, dans une session ouverte dans `nemeton`. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget à fixer par Pascal ; worktree depuis `origin/main`.
- **Ce qui ne lui est pas demandé :** les jalons M2 et M3 de la spec (synthèse forêt, risque de ruine, Pareto, capital calculé depuis P1 et P2), qui feront l'objet de missions suivantes ; calibrer les paramètres ; toucher nemetonshiny ou un autre dépôt ; poser une release ; fusionner.
- **Dépend de / rouge attendu jusqu'à :** la validation de la spec 072 par Pascal et la fusion de la PR nemeton #716. Restent posés à Pascal (spec § 13) : les sources des prix et des probabilités d'aléas, le champ vocation, le plafond du score et le seuil de décision.
