# Mission 047 — plateforme-charge-restes-044

> Ouverte le 2026-11-24 après la fusion de la PR #55, par délégation (restes à solder de la mission 044, relevés par le relecteur ; tâche de rangement de la plateforme).
> Dépôt : `nemetonplateforme` (pilotage). PR de pilotage, hors plafond.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire que l'avertissement « disque non mesurable » dise sa raison (elle se perd aujourd'hui dans un sous-shell et s'affiche « () ») et que la note de l'ADR 0001 nomme tous les périphériques exclus (`zram` compris), pour que l'orchestrateur sache pourquoi un départ est arrêté et qu'un successeur lise ce que fait vraiment le code.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- `pilotage/outils/commun.sh` (`controle_charge`, `occupation_disque`, `releve_disques`), `pilotage/outils/test.sh`.
- `docs/adr/0001-agir-dans-un-autre-depot.md`, « Note du 2026-11-24 (mission 044) ».
- `pilotage/journal.md`, ligne `relecteur · 044 · prête` (mineurs).

## Contrat aval lu

- Interface des outils inchangée (codes 0, 1, 3, `A_BLANC`, toutes les variables existantes) ; comportement inchangé : seule la raison s'ajoute au message.

## Ce qui est attendu

1. La raison de l'échec de mesure (fichier absent, second relevé absent, dossier des disques absent, aucun disque comparable…) apparaît dans l'avertissement « non mesurable (…) », sans parenthèses vides, par un moyen qui ne passe pas par une variable perdue dans un sous-shell.
2. `test.sh` : les cas « mesure impossible » vérifient chacun leur raison (ils échoueraient sur le code d'avant). `bash pilotage/outils/test.sh` vert, sortie complète dans le rendu, contre-épreuve sur `HEAD~`.
3. ADR 0001 : dans la note de la mission 044, une phrase ajoutée datée (sans réécrire) qui nomme les exclusions réelles du code (`loop`, `ram`, `zram`) et dit que `dm-*` et `md*` comptent comme disques entiers.
4. Une ligne de journal proposée dans le rendu.

## L'Homme

- **Agent :** `dev`, dans le worktree qui lui est donné. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 1 $.
- **Ce qui ne lui est pas demandé :** changer le seuil (`SEUIL_DISQUE`, à confirmer par Pascal) ou le budget des reprises ; lancer un vrai `claude -p` ; toucher un autre dépôt ; pousser ou fusionner.
- **Dépend de / rouge attendu jusqu'à :** rien.
