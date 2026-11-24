#!/bin/bash
# usage : relance.sh NNN depot k fichier_message — reprend la session de la mission NNN (flux{k}.jsonl)
# Le coût d'une reprise est cumulé (ADR 0001, « Les outils d'exécution »).
# Plafond de reprise (mission 048) : coût cumulé >= PLAFOND_REPRISE (défaut 4 $) : refus, code 4 ;
# sinon --max-budget-usd = min(3, plafond - coût cumulé, arrondi au centime inférieur).
# A_BLANC=1 : affiche la commande `claude -p --resume` sans la lancer.
. "$(dirname "$0")/commun.sh"
n=$1; repo=$2; k=$3; msg=$4; M=$CACHE/m$n
controle_charge || exit $?
[ -f "$msg" ] || { echo "ERREUR : fichier message introuvable : $msg ; rien n'est lancé." >&2; exit 1; }
cout=$(cout_cumule "$n"); plafond=$(plafond_reprise)
if awk -v c="$cout" -v p="$plafond" 'BEGIN{exit !(c+0>=p+0)}'; then
  echo "REFUS : la mission $n a déjà dépensé $cout \$ pour un plafond de reprise de $plafond \$ ; rien n'est lancé. La décision revient à Pascal : pour accorder un dépassement, relancer avec PLAFOND_REPRISE=<montant en \$> (ADR 0001, « Les outils d'exécution »)." >&2
  exit 4
fi
budget=$(awk -v c="$cout" -v p="$plafond" 'BEGIN{r=int((p-c)*100+1e-9)/100; if(r>3)r=3; printf "%.2f", r}')
sid=$(grep -ho '"session_id":"[^"]*"' "$M"/flux*.jsonl | tail -1 | cut -d'"' -f4)
cd "$DEV/$repo/.claude/worktrees/mission-$n" || exit 1
if depot_a_base "$repo" && charge_renviron; then export SOMMIER_TEST_DB=sommier_test_m$n; export R_ENVIRON_USER=$M/Renviron; fi
CMD=(timeout 7200 claude -p "$(cat "$msg")" --resume "$sid" --model sonnet --settings '{"enabledPlugins":{"imperatrice@pobsteta":true}}' --permission-mode auto --permission-prompts none --disallowedTools "Bash(gh pr merge *)" --max-budget-usd "$budget" --output-format stream-json --verbose --json-schema "$(cat "$OUTILS/schema.json")")
if [ -n "$A_BLANC" ]; then echo "À BLANC, dans $PWD (session $sid ; coût cumulé $cout \$, plafond $plafond \$, budget de la passe $budget \$) :"; printf '%q ' "${CMD[@]}" | cut -c1-400; echo; exit 0; fi
nohup "${CMD[@]}" > "$M/flux$k.jsonl" 2> "$M/err$k.log" < /dev/null &
echo $! > "$M/pid$k"; echo "relancée $n ($sid) pid $(cat "$M/pid$k")"
