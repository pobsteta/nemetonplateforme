# Mission 039 — nemeton-era5-timeseries

> Ouverte le 2026-11-23 au cycle 15, sur la consigne de Pascal (« lis et code les briefs »). Origine : brief `~/dev/briefs/vers-nemeton/2026-11-23-era5-timeseries-forcage-microclimf.md`, émis depuis nemetonshiny (priorité haute : l'acquisition ERA5 de la Colombière est estimée à ~48 h par la file CDS, contre ~2 min par année avec le jeu `timeseries`).
> Dépôt : `nemeton` (session ouverte dans le projet, ADR 0001). Fusion par l'orchestrateur quand les contrôles sont verts. **La release de nemeton n'est pas posée par la mission** : `DESCRIPTION` reste en `.9000`.
> L'autre brief du jour (`vers-nemetonshiny/2026-11-23-eobs-derniere-annee-complete.md`) n'entre pas dans le cycle : nemetonshiny le traite déjà (PR nemetonshiny #323, sa mission 047).
>
> **Note du 2026-11-24 (mission 046, rangement).** Décisions de Pascal du 2026-11-23, prises après la relecture de la PR nemeton #684, qui l'emportent sur le texte de la fiche ci-dessous (journal, lignes `039 · réponse`, `039 · décision sous délégation`) : (a) diffus juste, `difrad = (ssrd − fdir)/3600`, sans recalage de `swdown` sur le ciel clair (« On part sur (a) ») ; (b) avec la source `timeseries`, le cache du chemin classique n'est plus relu ; (c) **pas de repli automatique** vers le chemin classique : un échec est l'erreur `rsen_era5ts_echec`, qui dit comment passer au chemin classique par option, et le cas de repli de la fiche est caduc. La fiche reste telle qu'écrite le 2026-11-23.

## Mission

**En une phrase (quoi, et pourquoi) :** Faire acquérir par défaut le forçage ERA5 horaire de microclimf et de BILJOU par le jeu CDS `reanalysis-era5-single-levels-timeseries`, en rendant le même data.frame qu'aujourd'hui et en gardant l'ancien chemin en repli, pour qu'une acquisition qui prend deux jours dans la file CDS tombe à quelques minutes.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Les sources à lire avant d'agir

- Le brief, en entier : `~/dev/briefs/vers-nemeton/2026-11-23-era5-timeseries-forcage-microclimf.md`. Il fait foi pour les formules (§ « À faire côté cœur », point 1) et les tests attendus.
- Le rapport cité, section « Essai réel » en fin de fichier (requête qui marche, variables servies et absentes, unités) : `~/dev/nemetonshiny/pilotage/rapports/2026-11-23-sources-meteo-horaire.md` (lecture seule).
- Dans `nemeton` (vérifié le 2026-11-23 sur `origin/main` b6c67d821, dernier tag v2026.11.41, `DESCRIPTION` en 2026.11.41.9000) : `CLAUDE.md` (cycle `.9000`, règles strictes), `R/regen_engines.R` (`.rsen_forcage_era5()` l. 955, `.rsen_era5_assurer()`, `.rsen_era5_lot()` et ses événements, `.rsen_era5_acces_cds()` l. 521, journal `era5_jobs/` l. 600 et suivantes, `.rsen_clamp_flux()`), `R/load_biljou.R` (`.biljou_forcing_era5()` l. 130, `.biljou_era5_meteo()` l. 110), `tests/testthat/test-regen-engines.R`, `test-load-biljou.R`.
- Le code de `mcera5::extract_clim()` installé (lecture seule) : **reprendre ses formules exactes** (humidité relative, vent, diffus, précipitation, décalage d'horodatage des cumuls s'il y en a un, interpolation entre mailles, rôle du masque terre-mer).

## Contrat aval lu

- **nemetonshiny** appelle le moteur (`regen_sensibilite()` et BILJOU) et affiche les événements `regen_expo:era5`, `regen_expo:era5_mois` (`category`, `year`, `mois_i`, `mois_n`) et `regen_expo:era5_attente` (missions 045-046 de nemetonshiny, v2026.11.5). Ni la signature publique, ni le nom ni les champs de ces événements ne changent. Si une requête couvre une année, `mois_i`/`mois_n` restent cohérents (croissants, `mois_i <= mois_n`, dernier `mois_i == mois_n`), et la roxygen dit ce qu'ils comptent désormais.
- **microclimf** (`checkinputs()`) exige `lwdown`, `difrad`, `precip` et des jours entiers de 24 h : le data.frame rendu les respecte.
- Le cache existant (`era5_<lon>_<lat>_<annee>*.nc` de l'ancien chemin) reste lisible par l'ancien chemin et n'est jamais pris pour un fichier `timeseries`, ni l'inverse.

## Cas limites (un test par cas, qui échoue sans le changement ; données synthétiques, pas de réseau)

1. **Fixture `timeseries`** (petit NetCDF de quelques heures, les 10 variables, `valid_time` en secondes depuis 1970) → data.frame aux colonnes et à l'ordre exacts de `.rsen_forcage_era5()` aujourd'hui (`obs_time`, `temp`, `relhum`, `pres`, `swdown`, `difrad`, `lwdown`, `windspeed`, `winddir`, `precip`), `obs_time` en POSIXct UTC.
2. **Unités** : `swdown = ssrd / 3600`, `lwdown = strd / 3600` (flux **par heure**, pas en cumul depuis 00 h), `pres = sp / 1000` (kPa), `precip` en mm (`tp` en m). Valeurs attendues calculées à la main dans le test.
3. **`difrad`** = `(ssrd - fdir) / 3600` borné à `[0, swdown]` : un cas où `fdir > ssrd` donne 0, un cas où le résultat dépasserait `swdown` donne `swdown`.
4. **Aucune valeur négative** sur `swdown`, `difrad`, `lwdown`, `precip` (petits négatifs dans la fixture ramenés à 0, comme `.rsen_clamp_flux()`).
5. **`relhum`** depuis `t2m`/`d2m` et **vent** depuis `u10`/`v10` : mêmes formules que `mcera5::extract_clim()` (le test compare à une valeur de référence calculée par ces formules, et `winddir` est dans `[0, 360)`).
6. **Horodatage** : si `extract_clim()` décale les cumuls horaires, le nouveau chemin applique le même décalage ; sinon, aucun. Le test fixe la règle retenue.
7. **Interpolation** : 4 mailles voisines et la même interpolation que `extract_clim()`, ou la maille la plus proche. Choix prudent : **les 4 mailles et la même interpolation**, pour rester comparable aux forçages déjà calculés (4 requêtes de ~2 min par point et par année). Un test avec 4 séries synthétiques vérifie les poids. L'écart avec la maille la plus proche est mesuré (cas 13) et écrit dans la PR.
8. **Masque terre-mer** absent du jeu `timeseries` : choix prudent, valeur 1 (terre) partout, si la lecture du code de `extract_clim()` confirme qu'il ne sert qu'à la correction côtière. Le noter dans la PR et dans un commentaire. Si cette lecture montre un autre usage, le dire dans la PR et choisir la solution la plus prudente (une requête au jeu classique par maille, mise en cache).
9. **Cache** : un fichier par point (ou maille) et par année, nom distinct de celui de l'ancien chemin (pas de collision, dans les deux sens) ; un fichier en cache complet n'est pas redemandé ; un fichier tronqué est redemandé (même contrôle que `.rsen_era5_nc_complet()`).
10. **Choix de la source** : `timeseries` par défaut ; l'ancien chemin reste joignable par une option ou un argument interne, documenté. Aucun argument public n'est retiré ni renommé.
11. **Repli** : `timeseries` en échec (job `failed`/`rejected`, réponse illisible, variable manquante) → l'ancien chemin, avec un message clair. Un refus pour limite (`rsen_era5_limite`) garde le comportement actuel (attente puis nouvel essai). Tests par injection (`acces`, `requete` ou équivalent), sans réseau.
12. **Événements** : les deux chemins émettent `regen_expo:era5_mois` avec `mois_i` croissant et `mois_n` constant sur un lot, et `regen_expo:era5_attente` avec ses champs actuels. BILJOU les renomme toujours en `biljou:era5_attente`. `.biljou_forcing_era5()` et `.biljou_era5_meteo()` passent par le nouveau chemin **sans changement de leur code** (ou un changement minimal, justifié dans la PR).
13. **Comparaison réelle (hors CI)** : 2024, un point (la Colombière, ou 4,8 E / 47,3 N), chemin `timeseries` contre `extract_clim()` sur les fichiers de l'ancien chemin. Écart par variable (moyenne, max absolu), et écart maille la plus proche contre interpolation. À lancer seulement si une clé CDS est disponible sur la machine. Le script va dans `tests/manual/` ou `data-raw/` (selon `CLAUDE.md`), le résultat dans la PR. Si aucun fichier de l'ancien chemin n'est en cache pour 2024 en ce point, **ne pas** lancer l'ancien chemin (des heures de file) : comparer au seul fichier présent ou le dire dans la PR. Tout test qui touche le réseau est sauté en CI (`skip_on_ci()`, `skip_if_offline()`, et sauté sans clé).
14. **Requêtes peu nombreuses** : les requêtes `timeseries` partent **en série** ou avec un plafond bas, et passent par le même journal `era5_jobs/` (purge des jobs orphelins des processus morts au démarrage, déjà en place). Le test vérifie que les jobs `timeseries` sont écrits au journal.

## Ce qui est attendu

1. Le nouveau chemin d'acquisition et sa lecture, qui rendent le data.frame du cas 1, branchés derrière `.rsen_forcage_era5()` (et donc BILJOU).
2. `timeseries` par défaut, repli sur l'ancien chemin, cache par point et par année.
3. Tests : un par cas limite ci-dessus. Lancer `.claude/test-command`, **et aussi** `Rscript -e 'devtools::test(filter = "regen-engines|load-biljou|r3-biljou|regen-per-unit", stop_on_failure = TRUE)'` : le niveau rapide n'exécute pas ces fichiers. Noter les deux dans `tests`.
4. Roxygen en anglais pour ce qui est documenté ; commentaires selon `CLAUDE.md`. `DESCRIPTION` reste en `2026.11.41.9000`. Une entrée dans `NEWS.md` sous la rubrique de développement, selon `CLAUDE.md`, avec la durée mesurée (cas 13) si elle l'est. Pas de version stable ni de tag.
5. Le corps de la PR donne, pour chaque point du brief (§ « À faire côté cœur » 1 à 4 et « Tests attendus »), ce qui est fait, et les choix tranchés (cas 7, 8, 12 et 14).
6. CI verte.

## L'Homme

- **Agent :** `dev`, dans une session ouverte dans `nemeton`. **Modèle :** sonnet. Relu par le `relecteur`.
- **Moyens :** budget 3 $ (plafond du lanceur) ; worktree depuis `origin/main`.
- **Ce qui ne lui est pas demandé :**
  - poser une version stable, un tag ou une release ;
  - écrire le brief vers nemetonshiny de la livraison (l'orchestrateur l'écrit à la release) ;
  - toucher `nemetonshiny`, `mcera5` ou un autre dépôt ;
  - lancer l'ancien chemin ERA5 sur le CDS (heures de file) ;
  - fusionner ;
  - déplacer le brief d'origine (l'orchestrateur le range).
- **Dépend de / rouge attendu jusqu'à :** rien.

## Fin

> Ajoutée le 2026-11-24 (mission 046), d'après le journal et le kanban.

PR nemeton #684 fusionnée par commit de fusion (e55239b) le 2026-11-23 ; publiée en v2026.11.42 (PR de release nemeton #685, fusionnée 5ecac20, tag `v2026.11.42`). Coût : 3,65 $ (budget 3 $, porté à 4 $ par Pascal pour la reprise 3) ; 3 allers-retours. Cas 13 mesuré à la main le 2026-11-24 (journal, essai Colombière) ; chemin cassé en usage réel jusqu'à la mission 042.
