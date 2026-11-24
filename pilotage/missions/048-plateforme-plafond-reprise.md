# Mission 048 — plateforme-plafond-reprise

> Ouverte le 2026-11-24 sur le « oui » de Pascal (« lance la mission du plafond de 4 $ »), après sa décision du même jour : plafond de reprise à 4 $ (cause E du Pareto du bilan ERA5).
> Dépôt : `nemetonplateforme` (pilotage). PR de pilotage, hors plafond.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire que `relance.sh` relise le coût déjà dépensé par une mission et refuse une reprise quand il atteint le plafond de 4 $, et sinon borne la passe à ce qui reste sous ce plafond, pour qu'aucune mission ne dépasse plus le budget que Pascal a fixé (039 : 3,65 $ cumulés pour 3 $, puis 4 $ accordés au cas par cas).

**Redite par l'agent :** Faire que `relance.sh` refuse (code 4) toute reprise d'une mission dont le coût cumulé (maximum des `total_cost_usd` de ses flux) atteint 4 $ (`PLAFOND_REPRISE`), et borne sinon la passe à ce qui reste sous ce plafond sans dépasser 3 $, pour qu'aucune mission ne dépasse le budget fixé par Pascal.

## Les sources à lire avant d'agir

- `pilotage/outils/relance.sh`, `lance.sh`, `resultat.sh`, `commun.sh`, `test.sh`.
- `docs/adr/0001-agir-dans-un-autre-depot.md`, section « Les outils d'exécution » : paragraphe « Le coût d'une reprise est cumulé » (le coût d'une mission est le **maximum** de `total_cost_usd` relu dans ses `flux*.jsonl`, jamais la somme), et les notes des missions 044 et 047.
- `pilotage/journal.md` du 2026-11-24 : ligne `Pascal · outils · cap` (plafond de reprise à 4 $).

## Contrat aval lu

- Interface inchangée : `relance.sh NNN depot k message.md`, codes 0, 1, 3, `A_BLANC=1`, variables existantes. Un nouveau code de sortie est permis pour le refus de budget s'il est distinct des autres et documenté.
- `lance.sh` (première passe) garde `--max-budget-usd 3`.

## Ce qui est attendu

1. **Coût cumulé** : une fonction de `commun.sh` relit le maximum de `total_cost_usd` dans `$CACHE/mNNN/flux*.jsonl` (lignes `"type":"result"`). Aucun flux ou aucun coût lisible : coût 0, avec un avertissement.
2. **Plafond réglable** : `PLAFOND_REPRISE` (défaut **4**, en dollars). Valeur non numérique : avertissement et défaut 4.
3. **Refus** : si le coût cumulé atteint ou dépasse le plafond, `relance.sh` ne lance rien, sort avec un code non nul distinct (par exemple 4) et un message qui donne le coût cumulé, le plafond et la marche à suivre (la décision revient à Pascal ; `PLAFOND_REPRISE` pour un dépassement qu'il accorde). En essai à blanc aussi.
4. **Borne de la passe** : sinon, `--max-budget-usd` de la reprise vaut ce qui reste sous le plafond (plafond − coût cumulé, arrondi vers le bas au centime), et jamais plus de 3 ; la commande à blanc l'affiche, ainsi que le coût cumulé.
5. **`test.sh`** : cas à blanc qui échoueraient sans le changement : coût cumulé sous le plafond (borne affichée), coût égal ou au-dessus (refus, code), plusieurs flux (maximum, pas la somme), aucun flux (coût 0), `PLAFOND_REPRISE` réglable et non numérique. Les cas existants restent verts. Sortie complète et contre-épreuve sur `HEAD~` dans le rendu.
6. **ADR 0001** : une note datée « Note du 2026-11-24 (mission 048) » à la fin de la section « Les outils d'exécution », sans réécrire le texte plus haut.
7. Une ligne de journal proposée dans le rendu.

## L'Homme

- **Agent :** `dev`, dans le worktree qui lui est donné. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 2 $.
- **Ce qui ne lui est pas demandé :** changer `lance.sh` (sauf s'il partage une fonction), le seuil de charge ou le seuil disque ; lancer un vrai `claude -p` ; toucher un autre dépôt ; pousser ou fusionner.
- **Dépend de / rouge attendu jusqu'à :** rien.
