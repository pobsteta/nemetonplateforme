# Mission 044 — plateforme-charge-disque-et-lanceur

> Ouverte le 2026-11-24 au bilan ERA5, sur le « oui » de Pascal (proposition 1 : causes C et E du Pareto de l'analyste).
> Dépôt : `nemetonplateforme` (pilotage). PR de pilotage, hors plafond.

## Mission

**En une phrase (quoi, et pourquoi) :** Donner au contrôle de charge une seconde mesure, l'occupation réelle des disques, qui laisse partir une mission quand la pression d'E/S est haute mais le disque libre, et faire que `lance.sh` s'arrête quand la fiche ne peut pas être copiée, pour que les départs ne soient plus bloqués à tort (69 essais refusés sur le fil ERA5, trois levées de seuil par Pascal) et qu'aucune session ne parte sans sa fiche.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- `pilotage/outils/commun.sh` (`controle_charge`), `lance.sh`, `relance.sh`, `preuve.sh`, `test.sh`.
- `docs/adr/0001-agir-dans-un-autre-depot.md`, section « Ajout du 2026-11-20 : les outils d'exécution », paragraphe « Le contrôle de charge ».
- `pilotage/journal.md` du 2026-11-23 et du 2026-11-24 : relevés « pression d'E/S 74 à 93 %, `sda` occupé à 2 % puis 9 % », départs refusés, levées du seuil ; ligne de la mission 043 (départ sans fiche) ; lignes `analyste` et `archiviste` du bilan ERA5.

## Contrat aval lu

- Les outils n'ont qu'un utilisateur : l'orchestrateur. Interface inchangée : `lance.sh NNN depot fiche.md`, `relance.sh NNN depot k message.md`, `preuve.sh NNN depot numero_pr`, codes 0, 1, 3, `A_BLANC=1`, `SEUIL_CHARGE_IO`, `FENETRE_CHARGE_IO`, `PRESSURE_IO_FICHIER`, `DEPOTS_AVEC_BASE`.
- Une mesure impossible ne bloque jamais (décision du 2026-11-20, ADR 0001) ; cela vaut aussi pour la nouvelle mesure.

## Ce qui est attendu

1. **Seconde mesure dans `commun.sh`.** Quand la pression dépasse son seuil, `controle_charge` mesure l'occupation des disques entiers (pas des partitions) dans `/proc/diskstats` (temps passé en E/S, champ `io_ticks`), sur deux relevés espacés d'un court intervalle réglable, et retient le disque le plus occupé. Disque occupé sous un seuil réglable (`SEUIL_DISQUE`, défaut 50 %) : le départ est **accepté**, avec un avertissement qui donne les deux valeurs (« pression à X %, disque le plus occupé à Y % : départ accepté »). Au-dessus : arrêt, code 3, message qui donne les deux valeurs. Mesure du disque impossible : comportement actuel (arrêt au-dessus du seuil de pression), avec un avertissement. Les fichiers lus et l'intervalle sont réglables pour les essais (par exemple `DISKSTATS_FICHIER` ou deux relevés fournis), à ton choix, dit en commentaire.
2. **`lance.sh` s'arrête** (code non nul, message clair, rien n'est lancé) quand la fiche `pilotage/missions/<fiche>` est absente ou que sa copie, ou celle du schéma, échoue ; en essai à blanc aussi, la fiche absente est signalée par un code non nul. Même vérification dans `relance.sh` pour le fichier message.
3. **`test.sh`** : des cas à blanc qui échoueraient sans le changement : pression haute et disque libre (départ accepté) ; pression haute et disque occupé (code 3) ; mesure du disque impossible (arrêt comme avant, avertissement) ; `SEUIL_DISQUE` réglable ; `lance.sh` avec une fiche absente (code non nul). Les cas existants restent verts. `bash pilotage/outils/test.sh` vert, sortie complète dans ton rendu.
4. **ADR 0001** : une note datée « Note du 2026-11-24 (mission 044) » à la fin de la section « Les outils d'exécution », sans réécrire le texte plus haut.
5. Journal en ajout seul : une ligne `dev` proposée dans ton rendu (l'orchestrateur l'inscrit).

## L'Homme

- **Agent :** `dev`, dans le worktree qui lui est donné. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 2 $.
- **Ce qui ne lui est pas demandé :** lancer un vrai `claude -p`, `gh`, `docker` ou `psql` (essais à blanc seulement) ; lire `~/.config/nemetonplateforme/renviron` ; borner le budget des reprises (cause E, reste à décider par Pascal) ; toucher un autre dépôt ; pousser ou fusionner.
- **Dépend de / rouge attendu jusqu'à :** rien. La mission 046 attend sa fin (même fichier, l'ADR 0001).
