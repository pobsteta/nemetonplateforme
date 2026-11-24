# Fonctions communes aux scripts d'exécution (à sourcer, pas à lancer). ADR 0001, section
# « Les outils d'exécution ».
#
# Variables (toutes facultatives) :
#   NEMETON_CACHE       traces des sessions (défaut ~/.cache/nemetonplateforme), jetables
#   NEMETON_DEV         dossier des dépôts (défaut ~/dev)
#   NEMETON_RENVIRON    fichier d'environnement de la base de test, HORS dépôt, avec un mot
#                       de passe : modèle `renviron.exemple` (défaut ~/.config/nemetonplateforme/renviron)
#   NEMETON_CONTENEUR   conteneur de la base (défaut nemeton_timescaledb)
#   SEUIL_CHARGE_IO     seuil de pression d'E/S en % (défaut 60)
#   FENETRE_CHARGE_IO   avg10, avg60 ou avg300 (défaut avg60 : 60 s)
#   PRESSURE_IO_FICHIER fichier lu (défaut /proc/pressure/io ; pour les essais)
#   DEPOTS_AVEC_BASE    dépôts qui se servent de la base de test, séparés par des espaces
#                       (défaut sommieR) ; les autres ne reçoivent ni SOMMIER_TEST_DB ni base
#   SEUIL_DISQUE        occupation (%) du disque le plus occupé au-delà de laquelle un départ est
#                       refusé quand la pression dépasse son seuil (défaut 50) ; mission 044
#   INTERVALLE_DISQUE   secondes entre les deux relevés de /proc/diskstats (défaut 2)
#   DISKSTATS_FICHIER   fichier lu pour le 1er relevé (défaut /proc/diskstats ; pour les essais)
#   DISKSTATS_FICHIER2  2e relevé : s'il est fourni, on ne dort pas et on le lit à la place d'un
#                       second passage sur DISKSTATS_FICHIER (pour les essais)
#   SYS_BLOCK           dossier des disques entiers (défaut /sys/block ; une partition n'y figure pas)
#   A_BLANC=1           affiche la commande au lieu de la lancer
OUTILS=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DEPOT=$(cd "$OUTILS/../.." && pwd)
CACHE=${NEMETON_CACHE:-$HOME/.cache/nemetonplateforme}
DEV=${NEMETON_DEV:-$HOME/dev}
RENVIRON=${NEMETON_RENVIRON:-$HOME/.config/nemetonplateforme/renviron}
CONTENEUR=${NEMETON_CONTENEUR:-nemeton_timescaledb}

# Contrôle de charge décidé au bilan du 2026-11-20 : s'arrête (code 3) si le disque est saturé.
controle_charge() {
  local f=${PRESSURE_IO_FICHIER:-/proc/pressure/io} seuil=${SEUIL_CHARGE_IO:-60} fen=${FENETRE_CHARGE_IO:-avg60} v num='^[0-9]+([.][0-9]+)?$'
  if [[ ! $seuil =~ $num ]]; then echo "contrôle de charge : SEUIL_CHARGE_IO='$seuil' non numérique, seuil par défaut (60)" >&2; seuil=60; fi
  if [ ! -r "$f" ]; then echo "contrôle de charge ignoré : $f illisible" >&2; return 0; fi
  v=$(awk -v k="$fen" '$1=="some"{for(i=2;i<=NF;i++){split($i,a,"=");if(a[1]==k)print a[2]}}' "$f")
  if [ -z "$v" ]; then echo "contrôle de charge ignoré : $fen introuvable dans $f (format inattendu)" >&2; return 0; fi
  if [[ ! $v =~ $num ]]; then echo "contrôle de charge ignoré : valeur '$v' non numérique dans $f" >&2; return 0; fi
  if awk -v v="$v" -v s="$seuil" 'BEGIN{exit !(v+0>s+0)}'; then
    # Pression haute : elle compte aussi l'attente des autres sessions, pas seulement un disque saturé.
    # Seconde mesure : occupation réelle du disque entier le plus occupé (mission 044).
    local sd=${SEUIL_DISQUE:-50} occ
    if [[ ! $sd =~ $num ]]; then echo "contrôle de charge : SEUIL_DISQUE='$sd' non numérique, seuil par défaut (50)" >&2; sd=50; fi
    if occ=$(occupation_disque); then
      if awk -v o="$occ" -v s="$sd" 'BEGIN{exit !(o+0>s+0)}'; then
        echo "ARRÊT : pression d'E/S ($fen) à $v % (seuil $seuil %), disque le plus occupé à $occ % (seuil $sd %) ; attendre que le disque se libère ou régler SEUIL_CHARGE_IO / SEUIL_DISQUE (ADR 0001, « Les outils d'exécution »)." >&2
        return 3
      fi
      echo "contrôle de charge : pression à $v %, disque le plus occupé à $occ % : départ accepté" >&2
      return 0
    fi
    echo "contrôle de charge : occupation des disques non mesurable ($DISQUE_RAISON), repli sur la seule pression" >&2
    echo "ARRÊT : pression d'E/S ($fen) à $v % pour un seuil de $seuil % ; attendre que le disque se libère ou régler SEUIL_CHARGE_IO (ADR 0001, « Les outils d'exécution »)." >&2
    return 3
  fi
}

# Relevé de /proc/diskstats : une ligne « disque io_ticks_ms » par disque entier (présent dans
# $SYS_BLOCK, hors loop et ram). Champ 13 de /proc/diskstats = temps passé en E/S, en ms.
releve_disques() {
  local f=$1 sys=${SYS_BLOCK:-/sys/block} maj min nom reste
  [ -r "$f" ] && [ -d "$sys" ] || return 1
  while read -r maj min nom reste; do
    [ -e "$sys/$nom" ] || continue
    case $nom in loop*|ram*|zram*) continue;; esac
    set -- $reste
    [ -n "${10:-}" ] && echo "$nom ${10}"
  done < "$f"
}

# Écrit sur stdout l'occupation (%) du disque entier le plus occupé entre deux relevés ; code 1 et
# DISQUE_RAISON si la mesure est impossible (jamais bloquant en soi).
occupation_disque() {
  local f1=${DISKSTATS_FICHIER:-/proc/diskstats} f2=${DISKSTATS_FICHIER2:-} iv=${INTERVALLE_DISQUE:-2} r1 r2 num='^[0-9]+([.][0-9]+)?$'
  [[ $iv =~ $num ]] && awk -v i="$iv" 'BEGIN{exit !(i+0>0)}' || iv=2
  r1=$(releve_disques "$f1") && [ -n "$r1" ] || { DISQUE_RAISON="$f1 ou le dossier des disques illisible"; return 1; }
  if [ -n "$f2" ]; then r2=$(releve_disques "$f2") || r2=; else sleep "$iv"; r2=$(releve_disques "$f1") || r2=; fi
  [ -n "$r2" ] || { DISQUE_RAISON="second relevé illisible"; return 1; }
  printf '%s\n--\n%s\n' "$r1" "$r2" | awk -v iv="$iv" '
    $1=="--"{s=1;next}
    !s{a[$1]=$2;next}
    ($1 in a) && $2+0>=a[$1]+0 {p=($2-a[$1])/(iv*1000)*100; if(p>100)p=100; if(!n||p>m)m=p; n=1}
    END{if(!n)exit 1; printf "%.0f\n", m}' || { DISQUE_RAISON="aucun disque comparable entre les deux relevés"; return 1; }
}

# Charge l'environnement de la base (si le fichier existe) ; sinon le dit sur stderr.
charge_renviron() {
  if [ -f "$RENVIRON" ]; then set -a; . "$RENVIRON"; set +a; return 0; fi
  echo "pas de fichier d'environnement ($RENVIRON) : tests d'intégration de la base ignorés" >&2; return 1
}

# Dit (code 0) si le dépôt $1 se sert de la base PostgreSQL de test. Critère : une liste
# réglable, DEPOTS_AVEC_BASE (défaut « sommieR »), le plus simple et le plus sûr ; un dépôt
# absent de la liste ne touche jamais à la base (mission 034).
depot_a_base() {
  local d
  for d in ${DEPOTS_AVEC_BASE-sommieR}; do [ "$d" = "$1" ] && return 0; done
  return 1
}

# Crée la base $1 (avec postgis et pgcrypto) si elle manque ; $2 = recréer (DROP avant).
# Utilise les variables SOMMIER_TEST_* déjà chargées par charge_renviron.
prepare_base() {
  local base=$1 recree=$2 psql q
  psql() { docker exec -e PGPASSWORD="$SOMMIER_TEST_PASSWORD" "$CONTENEUR" psql -U "$SOMMIER_TEST_USER" "$@"; }
  if [ -n "$recree" ]; then psql -d postgres -qc "DROP DATABASE IF EXISTS $base WITH (FORCE)"; fi
  if [ "$(psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$base'")" != 1 ]; then
    psql -d postgres -qc "CREATE DATABASE $base" && psql -d "$base" -qc "CREATE EXTENSION postgis; CREATE EXTENSION pgcrypto"
  fi
}
