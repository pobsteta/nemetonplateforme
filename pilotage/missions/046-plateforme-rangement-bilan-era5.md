# Mission 046 — plateforme-rangement-bilan-era5

> Ouverte le 2026-11-24 au bilan ERA5, sur le « oui » de Pascal (proposition 3 : trous de mémoire de l'archiviste).
> Dépôt : `nemetonplateforme` (pilotage). PR de pilotage, hors plafond. Documentation seule.

## Mission

**En une phrase (quoi, et pourquoi) :** Combler les trous de mémoire relevés par le test du successeur sur le fil ERA5 (plancher périmé dans la carte, décisions de Pascal sur 039 seulement au journal, fiches sans état final ni coût, pièce `m042/` dite jetable), pour qu'un successeur reprenne depuis le dépôt seul sans croire sûres des versions cassées.

**Redite par l'agent :** Corriger le plancher périmé de la carte (nemeton → nemetonshiny, foretaccess → nemetonshiny), écrire dans les fiches 039 à 043 ce que le journal ne dit qu'ailleurs (décisions de Pascal sur la 039, état final et coût), dire dans l'ADR 0001 que `m042/` est une pièce à conserver, et remettre la carte 039 à sa place au kanban, par des ajouts datés seulement, pour qu'un successeur reprenne depuis le dépôt seul. (Agent `archiviste`, 2026-11-24.)

## Les sources à lire avant d'agir

- `pilotage/journal.md` : ligne `archiviste` du bilan ERA5 (2026-11-24) et lignes des missions 039 à 043 (2026-11-23 et 2026-11-24), dont les décisions de Pascal sur 039 (« On part sur (a) », question du repli).
- `pilotage/missions/039-*.md` à `043-*.md`, `pilotage/kanban.md` (cartes 039 à 043), `pilotage/equipe.md`.
- `docs/carte.yaml` et `docs/carte-dependances.md`.
- `docs/adr/0001-agir-dans-un-autre-depot.md`, section « Les outils d'exécution », paragraphe « Ce qui reste hors dépôt », et la note de la mission 044 qui le suit.

## Ce qui est attendu

1. **`docs/carte.yaml`** : le lien nemeton → nemetonshiny dit `Imports: nemeton (>= 2026.11.44)`, source `nemetonshiny/DESCRIPTION:15`, relevé du 2026-11-24 (mission 043), et une note : le plancher fait foi dans `DESCRIPTION`, que le test de contrat lit depuis la mission 043 ; 2026.11.42 et 2026.11.43 sont cassées en usage réel. Même correction dans `docs/carte-dependances.md` si le plancher y figure. Vérifier aussi le lien foretaccess → nemetonshiny (`DESCRIPTION` dit désormais `foretaccess (>= 2.6.3)`).
2. **Fiche 039** : une note datée en tête, sous le bandeau, sans réécrire la fiche : décisions de Pascal du 2026-11-23 (diffus (a), sans recalage de `swdown` ; pas de repli automatique, un échec est l'erreur `rsen_era5ts_echec`, le cas de repli de la fiche est caduc), avec renvoi au journal.
3. **Fiches 039 à 043** : en queue de chaque fiche, une rubrique « Fin » d'une à trois lignes : PR et commit de fusion, release, coût dépensé pour le budget, nombre d'allers-retours, tels qu'au journal et au kanban. Une valeur absente des deux est écrite « non relevé », jamais devinée.
4. **ADR 0001**, paragraphe « Ce qui reste hors dépôt » : une note datée (ajout, sans réécrire) : `~/.cache/nemetonplateforme/m042/` garde la vraie réponse du CDS de la mission 042, pièce de preuve à conserver, pas une trace jetable ; si elle disparaît, la refaire par une requête CDS `timeseries` sur la maille de la Colombière (point 5,05 E / 47,30 N, 2018) ; les briefs ERA5 cités par les fiches 039 et 041 vivent dans `~/dev/briefs/vers-nemeton/`.
5. **Kanban** : dans « Terminé », la carte 039 remise à sa place, avant 040 (ordre du plus récent au plus ancien par numéro, comme les autres) ; rien d'autre.
6. Une ligne de journal proposée dans ton rendu (l'orchestrateur l'inscrit). Le journal est en ajout seul : tu n'y écris pas.

## L'Homme

- **Agent :** `archiviste`, dans le worktree qui lui est donné. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 1,5 $.
- **Ce qui ne lui est pas demandé :** `docs/spec.md` (mission 045) ; `pilotage/outils/` ; toucher un autre dépôt ; pousser ou fusionner.
- **Dépend de / rouge attendu jusqu'à :** fin de la mission 044 (même fichier : l'ADR 0001). Part après l'intégration de 044.
