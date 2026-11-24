# Mission 045 — plateforme-regle-reponse-reelle

> Ouverte le 2026-11-24 au bilan ERA5, sur le « oui » de Pascal (proposition 2 : cause A du Pareto de l'analyste).
> Dépôt : `nemetonplateforme` (pilotage). PR de pilotage, hors plafond. Documentation seule.

## Mission

**En une phrase (quoi, et pourquoi) :** Écrire dans `docs/spec.md` la règle qu'un nouveau chemin d'accès à une source externe ne se fusionne qu'avec des fixtures de la forme exacte d'une vraie réponse, et après une vraie réponse vérifiée une fois hors CI, pour que la faute qui a mis en service nemeton 2026.11.42 et 2026.11.43 (variables scalaires du CDS absentes des fixtures) ne revienne pas.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- `docs/spec.md`, en entier, surtout § 5 (« Qui fusionne et qui publie une release ») et § 14.
- `pilotage/journal.md` du 2026-11-24 : l'essai de la Colombière (« leçon pour le bilan »), le rendu et la relecture de la mission 042, les lignes `analyste` et `archiviste` du bilan ERA5.
- `pilotage/missions/039-nemeton-era5-timeseries.md` et `042-nemeton-era5ts-cache-scalaires.md`.

## Ce qui est attendu

1. Dans `docs/spec.md` § 5, une **note datée du 2026-11-24 (bilan ERA5, Pascal)**, ajoutée sans réécrire les six contrôles : pour toute PR qui ouvre ou change un chemin d'accès à une source externe (API, service de téléchargement, format reçu d'un tiers), (a) les fixtures reprennent la forme exacte d'une vraie réponse (dimensions, variables scalaires, types, en-têtes), tirée d'une réponse réelle gardée hors dépôt et citée par son chemin ; (b) une vraie réponse est lue une fois par le code de la PR, hors CI, et la commande et sa sortie figurent dans la PR ; (c) la fiche de mission le demande et le relecteur le contrôle ; (d) faute de quoi la fusion n'est pas déléguée. Une phrase dit d'où vient la règle (missions 039 et 042), avec le lien vers le journal.
2. Si § 14 (« Critères d'acceptation ») liste les contrôles, un renvoi d'une ligne vers la note ; sinon rien.
3. Rien d'autre : ni le plugin `imperatrice` (autre dépôt), ni `pilotage/equipe.md`, ni l'ADR 0001.
4. Une ligne de journal proposée dans ton rendu (l'orchestrateur l'inscrit).

## L'Homme

- **Agent :** `archiviste`, dans le worktree qui lui est donné. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 1 $.
- **Ce qui ne lui est pas demandé :** toucher un autre fichier que `docs/spec.md` ; toucher un autre dépôt ; pousser ou fusionner.
- **Dépend de / rouge attendu jusqu'à :** rien.
