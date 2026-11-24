#!/bin/bash
# Essai des outils : bash -n puis essai à blanc de chacun (n'appelle ni claude, ni gh, ni docker).
# Tout se passe dans un dossier temporaire ; ne touche pas à ~/.cache/nemetonplateforme.
O=$(cd "$(dirname "$0")" && pwd); T=$(mktemp -d); trap 'rm -rf "$T"' EXIT; rc=0
ok(){ echo "ok    $1"; }; ko(){ echo "ECHEC $1"; rc=1; }
for s in commun lance relance preuve resultat test; do bash -n "$O/$s.sh" && ok "bash -n $s.sh" || ko "bash -n $s.sh"; done
grep -v '^#' "$O/renviron.exemple" | grep -q '=' && ko "renviron.exemple ne doit lister que des noms" || ok "renviron.exemple : noms seulement"
mkdir -p "$T/dev/projet/.claude/worktrees/mission-999" "$T/cache/m999"
printf '{"type":"result","subtype":"success","total_cost_usd":1,"session_id":"s1","structured_output":{"a":1}}\n' > "$T/cache/m999/flux.jsonl"
echo "some avg10=1.00 avg60=10.00 avg300=1.00 total=1" > "$T/bas"
echo "some avg10=90.00 avg60=77.00 avg300=1.00 total=1" > "$T/haut"
echo "# message" > "$T/msg.md"
F=$(cd "$O/../missions" && ls | grep -m1 '^[0-9].*\.md$')  # une fiche réelle : lance.sh s'arrête sans fiche (mission 044)
# Disques (mission 044) : sda et nvme0n1 sont des disques entiers, sda1 une partition (absente de SYS_BLOCK).
mkdir -p "$T/sys/block/sda" "$T/sys/block/nvme0n1"
dk(){ printf '   8 0 sda 1 0 1 1 1 0 1 1 0 %s %s\n   8 1 sda1 1 0 1 1 1 0 1 1 0 %s %s\n 259 0 nvme0n1 1 0 1 1 1 0 1 1 0 %s %s\n   7 0 loop0 1 0 1 1 1 0 1 1 0 %s %s\n' "$1" "$1" "$3" "$3" "$2" "$2" 0 0; }
dk 1000 1000 1000 > "$T/d0"          # relevé de départ
dk 1040 1100 1000 > "$T/d_libre"     # sur 1 s : sda 4 %, nvme0n1 10 %
dk 1040 1700 1000 > "$T/d_occupe"    # nvme0n1 70 %
dk 1000 1000 9000 > "$T/d_part"      # seule la partition sda1 bouge : ignorée
export NEMETON_CACHE=$T/cache NEMETON_DEV=$T/dev NEMETON_RENVIRON=$T/absent A_BLANC=1 PRESSURE_IO_FICHIER=$T/bas DISKSTATS_FICHIER=$T/absent-diskstats SYS_BLOCK=$T/sys/block INTERVALLE_DISQUE=1
bash "$O/lance.sh" 999 projet "$F" 2>&1 | grep -q "claude -p" && ok "lance.sh à blanc" || ko "lance.sh à blanc"
bash "$O/preuve.sh" 999 projet 1 2>&1 | grep -q "À BLANC" && ok "preuve.sh à blanc" || ko "preuve.sh à blanc"
bash "$O/relance.sh" 999 projet 2 "$T/msg.md" 2>&1 | grep -q "resume" && ok "relance.sh à blanc" || ko "relance.sh à blanc"
unset A_BLANC
bash "$O/resultat.sh" 999 2>&1 | grep -q "coût 1" && ok "resultat.sh" || ko "resultat.sh"
export A_BLANC=1
for s in lance preuve relance; do
  PRESSURE_IO_FICHIER=$T/haut bash "$O/$s.sh" 999 projet 1 "$T/msg.md" >"$T/sortie" 2>&1; c=$?
  { [ $c = 3 ] && grep -q ARRÊT "$T/sortie"; } && ok "$s.sh s'arrête sous charge (code 3)" || ko "$s.sh sous charge (code $c)"
  SEUIL_CHARGE_IO=90 PRESSURE_IO_FICHIER=$T/haut bash "$O/$s.sh" 999 projet 1 "$T/msg.md" 2>&1 | grep -q ARRÊT && ko "$s.sh : seuil réglable" || ok "$s.sh : seuil réglable"
done
# Base de test : seulement pour les dépôts de DEPOTS_AVEC_BASE (défaut sommieR).
printf 'SOMMIER_TEST_DB=x\n' > "$T/renv"; mkdir -p "$T/dev/sommieR"
b(){ env -u SOMMIER_TEST_DB NEMETON_RENVIRON=$T/renv "$@" 2>&1; }
b bash "$O/lance.sh" 999 projet "$F" | grep -q "SOMMIER_TEST_DB=sommier\|base sommier" && ko "lance.sh : dépôt sans base ne doit pas annoncer de base" || ok "lance.sh : dépôt sans base, pas de base annoncée"
b bash "$O/lance.sh" 999 sommieR "$F" | grep -q "SOMMIER_TEST_DB=sommier_test_m999" && ok "lance.sh : sommieR, SOMMIER_TEST_DB annoncée" || ko "lance.sh : sommieR sans base"
b bash "$O/lance.sh" 999 sommieR "$F" | grep -q "base sommier_test_m999 créée si elle manque" && ok "lance.sh : sommieR, création de la base dite à blanc" || ko "lance.sh : création non annoncée"
b bash "$O/preuve.sh" 999 projet 1 | grep -q "sans base" && ! b bash "$O/preuve.sh" 999 projet 1 | grep -q mpreuve && ok "preuve.sh : dépôt sans base, pas de base de preuve" || ko "preuve.sh : dépôt sans base"
b bash "$O/preuve.sh" 999 sommieR 1 | grep -q "base sommier_test_mpreuve999" && ok "preuve.sh : sommieR, base de preuve annoncée" || ko "preuve.sh : sommieR sans base de preuve"
b env DEPOTS_AVEC_BASE="projet autre" bash "$O/lance.sh" 999 projet "$F" | grep -q "SOMMIER_TEST_DB=sommier_test_m999" && ok "DEPOTS_AVEC_BASE : liste réglable (projet ajouté)" || ko "DEPOTS_AVEC_BASE : projet ajouté"
b env DEPOTS_AVEC_BASE="projet autre" bash "$O/lance.sh" 999 sommieR "$F" | grep -q "SOMMIER_TEST_DB=sommier" && ko "DEPOTS_AVEC_BASE : sommieR retiré de la liste" || ok "DEPOTS_AVEC_BASE : sommieR retiré, plus de base"
b env DEPOTS_AVEC_BASE= bash "$O/lance.sh" 999 sommieR "$F" | grep -q "SOMMIER_TEST_DB=sommier" && ko "DEPOTS_AVEC_BASE vide : aucune base" || ok "DEPOTS_AVEC_BASE vide : aucune base"
# Cas dégradés : jamais de blocage, un avertissement.
echo "" > "$T/vide"; echo "full avg60=99.00" > "$T/sanssome"; echo "some avg60=abc" > "$T/nan"
cas(){ # nom, fichier, VAR=val
  local nom=$1 fic=$2; shift 2
  env "$@" PRESSURE_IO_FICHIER=$fic bash "$O/lance.sh" 999 projet "$F" >"$T/sortie" 2>&1; c=$?
  { [ $c = 0 ] && grep -q "contrôle de charge" "$T/sortie"; } && ok "charge : $nom (pas de blocage, avertissement)" || ko "charge : $nom (code $c)"
}
cas "fichier absent" "$T/nexiste-pas" X=1
cas "fichier vide" "$T/vide" X=1
cas "sans ligne some" "$T/sanssome" X=1
cas "valeur non numérique" "$T/nan" X=1
cas "fenêtre inconnue" "$T/haut" FENETRE_CHARGE_IO=avg7
cas "seuil non numérique" "$T/bas" SEUIL_CHARGE_IO=beaucoup
SEUIL_CHARGE_IO=beaucoup PRESSURE_IO_FICHIER=$T/haut bash "$O/lance.sh" 999 projet "$F" >"$T/sortie" 2>&1; [ $? = 3 ] && ok "seuil non numérique : défaut 60 appliqué (77 % arrête)" || ko "seuil non numérique : défaut"
[ "$(ls "$T/cache/m999")" = "flux.jsonl" ] && ok "essai à blanc sans trace" || ko "l'essai à blanc a écrit des traces"
# Seconde mesure : l'occupation du disque (mission 044). Pression haute (77 %) dans tous ces cas.
dsk(){ # nom, code attendu, motif attendu dans la sortie, VAR=val...
  local nom=$1 att=$2 motif=$3; shift 3
  env "$@" PRESSURE_IO_FICHIER=$T/haut bash "$O/lance.sh" 999 projet "$F" >"$T/sortie" 2>&1; c=$?
  { [ $c = "$att" ] && grep -q "$motif" "$T/sortie"; } && ok "disque : $nom" || { ko "disque : $nom (code $c)"; sed 's/^/      /' "$T/sortie"; }
}
dsk "pression haute, disque libre : départ accepté avec les deux valeurs" 0 "pression à 77.00 %, disque le plus occupé à 10 % : départ accepté" DISKSTATS_FICHIER=$T/d0 DISKSTATS_FICHIER2=$T/d_libre
dsk "pression haute, disque occupé : code 3 avec les deux valeurs" 3 "pression d'E/S (avg60) à 77.00 %.*disque le plus occupé à 70 %" DISKSTATS_FICHIER=$T/d0 DISKSTATS_FICHIER2=$T/d_occupe
dsk "partition ignorée (seul sda1 bouge) : départ accepté" 0 "disque le plus occupé à 0 %" DISKSTATS_FICHIER=$T/d0 DISKSTATS_FICHIER2=$T/d_part
dsk "SEUIL_DISQUE=5 : 10 % devient trop occupé" 3 "disque le plus occupé à 10 %" DISKSTATS_FICHIER=$T/d0 DISKSTATS_FICHIER2=$T/d_libre SEUIL_DISQUE=5
dsk "SEUIL_DISQUE=80 : 70 % accepté" 0 "départ accepté" DISKSTATS_FICHIER=$T/d0 DISKSTATS_FICHIER2=$T/d_occupe SEUIL_DISQUE=80
dsk "SEUIL_DISQUE non numérique : défaut 50" 3 "SEUIL_DISQUE='beaucoup' non numérique" DISKSTATS_FICHIER=$T/d0 DISKSTATS_FICHIER2=$T/d_occupe SEUIL_DISQUE=beaucoup
dsk "mesure impossible (fichier absent) : arrêt comme avant, avec avertissement" 3 "non mesurable" DISKSTATS_FICHIER=$T/absent-diskstats
dsk "mesure impossible (second relevé absent)" 3 "non mesurable" DISKSTATS_FICHIER=$T/d0 DISKSTATS_FICHIER2=$T/absent-diskstats
dsk "mesure impossible (dossier des disques absent)" 3 "non mesurable" DISKSTATS_FICHIER=$T/d0 DISKSTATS_FICHIER2=$T/d_libre SYS_BLOCK=$T/nexiste-pas
# Pression basse : pas de seconde mesure, départ accepté sans avertissement de disque.
env DISKSTATS_FICHIER=$T/absent-diskstats bash "$O/lance.sh" 999 projet "$F" >"$T/sortie" 2>&1; { [ $? = 0 ] && ! grep -q disque "$T/sortie"; } && ok "pression basse : pas de mesure de disque" || ko "pression basse"
# Fiche absente : code non nul, rien n'est lancé, même à blanc ; sans A_BLANC, aucune trace non plus.
bash "$O/lance.sh" 999 projet inexistante.md >"$T/sortie" 2>&1; c=$?
{ [ $c != 0 ] && grep -q "fiche introuvable" "$T/sortie" && ! grep -q "claude -p" "$T/sortie"; } && ok "lance.sh : fiche absente (code $c), à blanc" || ko "lance.sh : fiche absente à blanc (code $c)"
env -u A_BLANC bash "$O/lance.sh" 999 projet inexistante.md >"$T/sortie" 2>&1; c=$?
{ [ $c != 0 ] && [ ! -e "$T/cache/m999/pid" ] && [ ! -e "$T/cache/m999/fiche.md" ]; } && ok "lance.sh : fiche absente (code $c), rien de lancé" || ko "lance.sh : fiche absente, réel (code $c)"
bash "$O/relance.sh" 999 projet 2 "$T/absent.md" >"$T/sortie" 2>&1; c=$?
{ [ $c != 0 ] && grep -q "message introuvable" "$T/sortie"; } && ok "relance.sh : message absent (code $c)" || ko "relance.sh : message absent (code $c)"
exit $rc
