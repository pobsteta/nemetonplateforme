#!/usr/bin/env Rscript
# Mission 092 - ecart Sen2Cor (Planetary Computer) contre MAJA (THEIA/MUSCATE)
# sur CRswir et CRre. Etude : aucun code produit, aucune ecriture dans nemeton.
#
# Usage (depuis la racine du depot, nemeton installe ou charge) :
#   Rscript etudes/092-sen2cor-contre-maja/comparer.R [options]
#
# Options (--cle=valeur) :
#   --cote=pc|theia|les-deux|pc-pc   (defaut les-deux)
#        pc       : Sen2Cor seul, donne la dispersion des indices (sans THEIA)
#        theia    : MAJA seul, meme sortie
#        les-deux : appariement par jour, ecarts Sen2Cor - MAJA
#        pc-pc    : autotest du pipeline d'appariement : deux traitements
#                   Sen2Cor (baselines 05.09 et 05.10) de la meme prise de vue
#   --bbox=xmin,ymin,xmax,ymax       WGS84 (defaut : forets de Couchey, T31TFN)
#   --tuile=31TFN                    code MGRS sans T
#   --debut=2023-06-01 --fin=2023-08-31
#   --nuages=30                      couverture nuageuse maximale de la scene (%)
#   --max-scenes=0                   0 = toutes ; sinon les N premieres dates
#   --foret=oui|non                  masque arbres ESA WorldCover (via PC)
#   --scl=4,5                        classes SCL gardees cote Sen2Cor
#   --maja-dir=<dossier>             cote MAJA LOCAL : dossier `extracted/T31TFN`
#        (scenes SENTINEL2*_FRE_B*.tif et MASKS/*_CLM_R2 deja decoupees, L93 10 m) ;
#        remplace la lecture THEIA, la grille et l'emprise viennent des scenes
#   --oso=<fichier>                  masque feuillus OSO (1 = feuillus), optionnel
#   --nuages-pc=15 --clair-maja=0.6  filtres de ciel clair (scene PC ; part de
#        pixels forestiers sans nuage cote MAJA) ; --n-dates=12 dates retenues,
#        reparties sur la periode
#   --sortie=<dossier>               CSV (defaut : dossier du script)
#   --cache=<dossier>                matrices lues, hors depot (defaut : tempdir)
#
# Cote THEIA : cles TLD_ACCESS_KEY / TLD_SECRET_KEY dans l'environnement
# (~/.Renviron), catalogue api.stac.teledetection.fr joignable. Il n'existe pas
# de voie publique : les objets S3 de MESO@UM ne sont lisibles que signes par la
# passerelle teledetection, qui exige la cle (cf. nemeton R/theia_stac.R).
#
# Convention des differences : d = Sen2Cor - MAJA (ou, en pc-pc, 05.10 - 05.09).
# Reutilise les fonctions internes de nemeton (lues, jamais reecrites) :
#   stac_search_s2_pc, .dedup_s2_reprocessed, .s2_harmonize_band/.s2_boa_offset,
#   .terra_rast_with_pc_retry, .pc_collection_token/.pc_apply_token,
#   .reconfort_fenetre_lister/_signer, reconfort_indices (exporte).

suppressPackageStartupMessages({
  library(terra)
  library(nemeton)
})
.nm <- function(f) get(f, envir = asNamespace("nemeton"))
terra::terraOptions(progress = 0)

# --- Options ----------------------------------------------------------------
lire_options <- function(args = commandArgs(trailingOnly = TRUE)) {
  o <- list(cote = "les-deux", bbox = "4.935,47.215,4.975,47.250",
            tuile = "31TFN", debut = "2023-06-01", fin = "2023-08-31",
            nuages = "30", `max-scenes` = "0", foret = "oui", scl = "4,5",
            sortie = NA_character_, cache = NA_character_,
            `maja-dir` = NA_character_, oso = NA_character_,
            `nuages-pc` = "15", `clair-maja` = "0.6", `n-dates` = "12")
  for (a in args) {
    m <- regmatches(a, regexec("^--([a-z-]+)=(.*)$", a))[[1]]
    if (length(m) == 3L) o[[m[2]]] <- m[3]
  }
  o$bbox <- as.numeric(strsplit(o$bbox, ",")[[1]])
  o$scl <- as.integer(strsplit(o$scl, ",")[[1]])
  o$nuages <- as.numeric(o$nuages)
  o$`nuages-pc` <- as.numeric(o$`nuages-pc`)
  o$`clair-maja` <- as.numeric(o$`clair-maja`)
  o$`n-dates` <- as.integer(o$`n-dates`)
  o$`max-scenes` <- as.integer(o$`max-scenes`)
  o
}

BANDES <- c("B04", "B05", "B06", "B8A", "B11", "B12")

# --- Grille commune : Lambert-93, 10 m, alignee sur 10 m ---------------------
grille_commune <- function(bbox4326, res = 10) {
  e <- terra::ext(bbox4326[1], bbox4326[3], bbox4326[2], bbox4326[4])
  v <- terra::project(terra::as.polygons(e, crs = "EPSG:4326"), "EPSG:2154")
  ee <- terra::ext(v)
  ee <- terra::ext(floor(ee[1] / res) * res, ceiling(ee[2] / res) * res,
                   floor(ee[3] / res) * res, ceiling(ee[4] / res) * res)
  terra::rast(ee, resolution = res, crs = "EPSG:2154")
}

# Lit la fenetre d'un raster distant sur la grille commune (plus proche voisin :
# 10 m natif tel quel, 20 m dupliques ; le meme traitement des deux cotes).
fenetre_sur_grille <- function(href, grille, lecteur = NULL) {
  lire <- function(r0) {
    e <- terra::ext(terra::project(terra::as.polygons(terra::ext(grille),
                                                      crs = terra::crs(grille)),
                                   terra::crs(r0)))
    e <- terra::extend(e, 100)
    rc <- terra::crop(r0, e, snap = "out")
    terra::values(terra::project(rc, grille, method = "near"), mat = FALSE)
  }
  if (is.null(lecteur)) lire(terra::rast(href)) else lecteur(href, lire)
}

lecteur_pc <- function(scene_id, bande) {
  function(href, lire) {
    .nm(".terra_rast_with_pc_retry")(href, scene_id = scene_id, band = bande,
                                      materialize = lire)
  }
}

# --- Cote Sen2Cor (Planetary Computer) ---------------------------------------
# Renvoie une liste (une entree par scene) : date, scene_id, matrice de
# reflectances (colonnes BANDES, echelle 0-1, offset BOA retire) et vecteur `ok`.
lire_scene_pc <- function(ligne, grille, scl_ok, cache) {
  id <- ligne$scene_id
  f <- file.path(cache, paste0("pc_", id, ".rds"))
  if (file.exists(f)) return(readRDS(f))
  hrefs <- vapply(BANDES, function(b) ligne[[paste0("href_", b)]], "")
  # SCL a 20 m : meme dossier R20m que B05, meme jeton (collection entiere).
  href_scl <- sub("_B05_20m\\.tif", "_SCL_20m.tif", hrefs[["B05"]])
  refl <- vapply(BANDES, function(b) {
    v <- fenetre_sur_grille(hrefs[[b]], grille, lecteur_pc(id, b))
    # DN -> reflectance : offset BOA (baseline >= 04.00) comme pour FORDEAD,
    # puis /10000. 0 reste le nodata.
    off <- .nm(".s2_boa_offset")(id)
    nodata <- is.na(v) | v == 0
    if (is.na(off)) off <- 0
    out <- pmax(v + off, 0) / 10000
    out[nodata] <- NA_real_
    out
  }, numeric(terra::ncell(grille)))
  scl <- fenetre_sur_grille(href_scl, grille, lecteur_pc(id, "SCL"))
  res <- list(date = as.Date(ligne$obs_date), scene_id = id, refl = refl,
              ok = !is.na(scl) & scl %in% scl_ok)
  saveRDS(res, f)
  res
}

# --- Cote MAJA (THEIA / MUSCATE) ---------------------------------------------
# Un item STAC -> memes sorties. FRE (reflectance plate), masques CLM/SAT/EDG a
# 20 m (R2 : un pixel 20 m couvre 4 pixels 10 m, comme pour les bandes 20 m).
lire_scene_theia <- function(ft, grille, cache) {
  id <- ft$id
  f <- file.path(cache, paste0("maja_", id, ".rds"))
  if (file.exists(f)) return(readRDS(f))
  assets <- ft$assets
  cles <- c(BANDES, "CLM_R2", "SAT_R2", "EDG_R2")
  hrefs <- vapply(cles, function(k) {
    h <- assets[[k]]$href %||% ""
    if (!nzchar(h)) stop("asset THEIA absent : ", k, " (item ", id, ")")
    h
  }, "")
  sg <- .nm(".reconfort_fenetre_signer")(unname(hrefs))
  names(sg) <- cles
  lec <- function(k) fenetre_sur_grille(sg[[k]], grille)
  refl <- vapply(BANDES, function(b) {
    v <- lec(b)
    out <- v / 10000
    out[is.na(v) | v <= -10000] <- NA_real_   # nodata MAJA = -10000
    out
  }, numeric(terra::ncell(grille)))
  clm <- lec("CLM_R2"); sat <- lec("SAT_R2"); edg <- lec("EDG_R2")
  ok <- !is.na(clm) & clm == 0 & !is.na(sat) & sat == 0 & !is.na(edg) & edg == 0
  dt <- as.Date(substr(ft$properties$datetime %||% ft$properties$start_datetime,
                       1, 10))
  res <- list(date = dt, scene_id = id, refl = refl, ok = ok)
  saveRDS(res, f)
  res
}

# MAJA local : une scene decoupee (dossier) -> memes sorties.
lire_scene_maja_locale <- function(dossier, grille, cache) {
  id <- basename(dossier)
  f <- file.path(cache, paste0("majaloc_", id, ".rds"))
  if (file.exists(f)) return(readRDS(f))
  lec <- function(rel) fenetre_sur_grille(file.path(dossier, rel), grille)
  refl <- vapply(BANDES, function(b) {
    v <- lec(sprintf("%s_FRE_%s.tif", id, sub("^B0", "B", b)))
    out <- v / 10000
    out[is.na(v) | v <= -10000] <- NA_real_
    out
  }, numeric(terra::ncell(grille)))
  m <- function(k) lec(file.path("MASKS", sprintf("%s_%s_R2.tif", id, k)))
  clm <- m("CLM"); sat <- m("SAT"); edg <- m("EDG")
  ok <- !is.na(clm) & clm == 0 & !is.na(sat) & sat == 0 & !is.na(edg) & edg == 0
  dt <- as.Date(sub(".*_(20[0-9]{6})-.*", "\\1", id), "%Y%m%d")
  res <- list(date = dt, scene_id = id, refl = refl, ok = ok)
  saveRDS(res, f)
  res
}

# Mesure sur les scenes MAJA locales contre Planetary Computer, memes jours.
principal_local <- function(o) {
  racine <- tryCatch(dirname(normalizePath(sub("^--file=", "", grep("^--file=",
              commandArgs(), value = TRUE)[1]))), error = function(e) ".")
  sortie <- if (is.na(o$sortie)) racine else o$sortie
  cache <- if (is.na(o$cache)) file.path(tempdir(), "cache092") else o$cache
  dir.create(cache, showWarnings = FALSE, recursive = TRUE)
  dir.create(sortie, showWarnings = FALSE, recursive = TRUE)
  dossiers <- sort(list.dirs(o$`maja-dir`, recursive = FALSE))
  dossiers <- dossiers[grepl("^SENTINEL2", basename(dossiers))]
  d_maja <- as.Date(sub(".*_(20[0-9]{6})-.*", "\\1", basename(dossiers)), "%Y%m%d")
  # grille = celle des scenes locales (L93, 10 m)
  r0 <- terra::rast(Sys.glob(file.path(dossiers[1], "*_FRE_B4.tif"))[1])
  grille <- terra::rast(terra::ext(r0), resolution = 10, crs = "EPSG:2154")
  bb <- terra::ext(terra::project(terra::as.polygons(terra::ext(grille), crs = "EPSG:2154"), "EPSG:4326"))
  o$bbox <- as.numeric(bb[c(1, 3, 2, 4)])
  cat(sprintf("Grille : %d x %d ; %d scenes MAJA locales\n", ncol(grille), nrow(grille), length(dossiers)))

  wc <- masque_foret(grille)
  oso <- rep(TRUE, terra::ncell(grille))
  if (!is.na(o$oso)) {
    oso <- fenetre_sur_grille(o$oso, grille) == 1
    oso[is.na(oso)] <- FALSE
  }
  foret <- wc & oso
  cat(sprintf("Pixels : arbres WorldCover %d ; feuillus OSO %d ; les deux %d\n",
              sum(wc), sum(oso), sum(foret)))

  o$debut <- format(min(d_maja)); o$fin <- format(max(d_maja))
  o$nuages <- o$`nuages-pc`
  pc <- .nm(".dedup_s2_reprocessed")(scenes_pc(o))
  pc <- pc[order(pc$obs_date), , drop = FALSE]
  communs <- intersect(format(pc$obs_date), format(d_maja))
  cat(sprintf("PC (nuages <= %g %%) : %d scenes ; jours communs : %d\n",
              o$`nuages-pc`, nrow(pc), length(communs)))

  # ciel clair cote MAJA : part des pixels forestiers valides
  cand <- do.call(rbind, lapply(communs, function(j) {
    a <- lire_scene_maja_locale(dossiers[which(format(d_maja) == j)[1]], grille, cache)
    data.frame(date = j, part_clair_maja = mean(a$ok[foret] & stats::complete.cases(a$refl)[foret]))
  }))
  print(cand)
  cand <- cand[cand$part_clair_maja >= o$`clair-maja`, , drop = FALSE]
  if (nrow(cand) > o$`n-dates`) {
    cand <- cand[unique(round(seq(1, nrow(cand), length.out = o$`n-dates`))), , drop = FALSE]
  }
  cat("Dates retenues :", paste(cand$date, collapse = " "), "\n")

  res <- list(); dsp <- list(); pooled <- list()
  for (j in cand$date) {
    a <- lire_scene_maja_locale(dossiers[which(format(d_maja) == j)[1]], grille, cache)
    b <- lire_scene_pc(pc[format(pc$obs_date) == j, , drop = FALSE][1, ], grille, o$scl, cache)
    res[[length(res) + 1L]] <- cbind(comparer_paire(a, b, foret, "MAJA FRE", "Sen2Cor"),
                                     nuages_pc = pc$cloud_pct[format(pc$obs_date) == j][1])
    dsp[[length(dsp) + 1L]] <- dispersion_cote(list(a), foret, "MAJA")
    dsp[[length(dsp) + 1L]] <- dispersion_cote(list(b), foret, "Sen2Cor")
    # pixels appaires gardes pour le total (sous-echantillon 20 000 par date)
    ok <- a$ok & b$ok & foret & stats::complete.cases(a$refl) & stats::complete.cases(b$refl)
    ix <- which(ok); set.seed(92)
    if (length(ix) > 20000L) ix <- sample(ix, 20000L)
    ia <- indices_de(a$refl[ix, , drop = FALSE]); ib <- indices_de(b$refl[ix, , drop = FALSE])
    pooled[[length(pooled) + 1L]] <- data.frame(date = j, ia_swir = ia$CRswir, ib_swir = ib$CRswir,
                                                ia_re = ia$CRre, ib_re = ib$CRre)
  }
  resultats <- do.call(rbind, res)
  P <- do.call(rbind, pooled)
  tot <- rbind(cbind(date = "toutes", reference = "MAJA FRE", compare = "Sen2Cor", indice = "CRswir",
                     stats_ecart(P$ia_swir, P$ib_swir)),
               cbind(date = "toutes", reference = "MAJA FRE", compare = "Sen2Cor", indice = "CRre",
                     stats_ecart(P$ia_re, P$ib_re)))
  # biais par date : dispersion des biais entre dates
  utils::write.csv(resultats, file.path(sortie, "ecarts_par_date.csv"), row.names = FALSE)
  utils::write.csv(tot, file.path(sortie, "ecarts_total.csv"), row.names = FALSE)
  utils::write.csv(do.call(rbind, dsp), file.path(sortie, "dispersion_par_date.csv"), row.names = FALSE)
  print(resultats[, c("date", "indice", "n", "biais", "ecart_type_d", "rmse", "cor", "pente", "ordonnee")])
  print(tot)
  invisible(resultats)
}

`%||%` <- function(a, b) if (is.null(a) || (length(a) == 1L && is.na(a))) b else a

# --- Masque forestier : ESA WorldCover (classe 10 = arbres), via PC ----------
masque_foret <- function(grille) {
  body <- list(collections = list("esa-worldcover"),
               bbox = as.numeric(terra::ext(terra::project(
                 terra::as.polygons(terra::ext(grille), crs = "EPSG:2154"),
                 "EPSG:4326"))[c(1, 3, 2, 4)]),
               limit = 10L)
  resp <- httr2::request("https://planetarycomputer.microsoft.com/api/stac/v1/search") |>
    httr2::req_body_json(body) |> httr2::req_perform()
  feats <- httr2::resp_body_json(resp)$features
  feats <- Filter(function(ft) grepl("2021_v200", ft$id), feats)
  if (!length(feats)) return(NULL)
  tok <- .nm(".pc_collection_token")("esa-worldcover")
  out <- rep(FALSE, terra::ncell(grille))
  for (ft in feats) {
    href <- .nm(".pc_apply_token")(ft$assets$map$href, tok)
    v <- fenetre_sur_grille(href, grille, function(h, lire) {
      .nm(".terra_rast_with_pc_retry")(h, collection = "esa-worldcover",
                                       materialize = lire)
    })
    out <- out | (!is.na(v) & v == 10)
  }
  out
}

# --- Statistiques d'ecart ----------------------------------------------------
stats_ecart <- function(x, y) {
  # x = reference (MAJA), y = Sen2Cor ; d = y - x
  k <- is.finite(x) & is.finite(y)
  x <- x[k]; y <- y[k]
  d <- y - x
  n <- length(d)
  if (n < 30L) {
    return(data.frame(n = n, biais = NA, ecart_type_d = NA, rmse = NA, cor = NA,
                      pente = NA, ordonnee = NA, q01 = NA, q05 = NA, q25 = NA,
                      q50 = NA, q75 = NA, q95 = NA, q99 = NA,
                      sd_x = NA, sd_y = NA, mean_x = NA, mean_y = NA))
  }
  fit <- stats::lm.fit(cbind(1, x), y)$coefficients
  q <- stats::quantile(d, c(.01, .05, .25, .5, .75, .95, .99), names = FALSE)
  data.frame(n = n, biais = mean(d), ecart_type_d = stats::sd(d),
             rmse = sqrt(mean(d^2)), cor = stats::cor(x, y),
             pente = fit[[2]], ordonnee = fit[[1]],
             q01 = q[1], q05 = q[2], q25 = q[3], q50 = q[4], q75 = q[5],
             q95 = q[6], q99 = q[7],
             sd_x = stats::sd(x), sd_y = stats::sd(y),
             mean_x = mean(x), mean_y = mean(y))
}

indices_de <- function(refl) {
  b <- as.data.frame(refl)
  names(b)[names(b) == "B04"] <- "B4"   # reconfort_indices attend B4, B5, B6
  names(b)[names(b) == "B05"] <- "B5"
  names(b)[names(b) == "B06"] <- "B6"
  as.data.frame(nemeton::reconfort_indices(b))
}

# Compare deux scenes (listes lire_scene_*) sur les pixels valides des deux.
comparer_paire <- function(a_maja, b_s2c, foret, etiq_a, etiq_b) {
  ok <- a_maja$ok & b_s2c$ok & !is.na(foret) & foret
  ok <- ok & stats::complete.cases(a_maja$refl) & stats::complete.cases(b_s2c$refl)
  ia <- indices_de(a_maja$refl[ok, , drop = FALSE])
  ib <- indices_de(b_s2c$refl[ok, , drop = FALSE])
  do.call(rbind, lapply(c("CRswir", "CRre"), function(ind) {
    cbind(date = format(b_s2c$date), reference = etiq_a, compare = etiq_b,
          indice = ind, stats_ecart(ia[[ind]], ib[[ind]]),
          n_pixels_foret = sum(foret, na.rm = TRUE))
  }))
}

# Dispersion d'un seul cote : moyenne et ecart-type spatiaux par date, puis
# ecart-type de la moyenne de zone sur la saison.
dispersion_cote <- function(scenes, foret, etiq) {
  do.call(rbind, lapply(scenes, function(s) {
    ok <- s$ok & !is.na(foret) & foret & stats::complete.cases(s$refl)
    if (sum(ok) < 30L) return(NULL)
    ind <- indices_de(s$refl[ok, , drop = FALSE])
    do.call(rbind, lapply(c("CRswir", "CRre"), function(i) {
      data.frame(cote = etiq, date = format(s$date), indice = i, n = sum(ok),
                 moyenne = mean(ind[[i]], na.rm = TRUE),
                 ecart_type_spatial = stats::sd(ind[[i]], na.rm = TRUE),
                 p05 = unname(stats::quantile(ind[[i]], .05, na.rm = TRUE)),
                 p95 = unname(stats::quantile(ind[[i]], .95, na.rm = TRUE)))
    }))
  }))
}

# --- Recherche des scenes ----------------------------------------------------
scenes_pc <- function(o) {
  s <- .nm("stac_search_s2_pc")(o$bbox, o$debut, o$fin, max_cloud = o$nuages)
  s <- s[grepl(paste0("_T", o$tuile, "_"), s$scene_id), , drop = FALSE]
  s
}

# --- Programme ---------------------------------------------------------------
principal <- function(o) {
  racine <- tryCatch(dirname(normalizePath(sub("^--file=", "", grep("^--file=",
              commandArgs(), value = TRUE)[1]))), error = function(e) ".")
  sortie <- if (is.na(o$sortie)) racine else o$sortie
  cache <- if (is.na(o$cache)) file.path(tempdir(), "cache092") else o$cache
  dir.create(cache, showWarnings = FALSE, recursive = TRUE)
  dir.create(sortie, showWarnings = FALSE, recursive = TRUE)
  grille <- grille_commune(o$bbox)
  cat(sprintf("Grille L93 10 m : %d x %d pixels\n", ncol(grille), nrow(grille)))

  foret <- if (o$foret == "oui") masque_foret(grille) else rep(TRUE, terra::ncell(grille))
  if (is.null(foret)) stop("masque forestier introuvable")
  cat(sprintf("Pixels forestiers : %d (%.0f %%)\n", sum(foret), 100 * mean(foret)))

  trace <- list(options = o[setdiff(names(o), "cache")],
                date_execution = format(Sys.time(), tz = "UTC"),
                nemeton = as.character(utils::packageVersion("nemeton")),
                n_pixels_foret = sum(foret))

  # Sen2Cor
  pc <- NULL
  if (o$cote %in% c("pc", "les-deux", "pc-pc")) {
    sc <- scenes_pc(o)
    cat(sprintf("PC : %d scenes (toutes baselines)\n", nrow(sc)))
    if (o$cote != "pc-pc") sc <- .nm(".dedup_s2_reprocessed")(sc)
    sc <- sc[order(sc$obs_date, sc$scene_id), , drop = FALSE]
    pc <- sc
  }

  if (o$cote == "pc-pc") {
    # Paires de la meme prise de vue : un traitement 05.09 et un retraitement.
    cle <- vapply(pc$scene_id, function(i) .nm(".s2_split_product_id")(i)$key, "")
    proc <- vapply(pc$scene_id, function(i) .nm(".s2_split_product_id")(i)$proc, "")
    paires <- Filter(function(ix) length(ix) == 2L, split(seq_len(nrow(pc)), cle))
    if (o$`max-scenes` > 0L) paires <- head(paires, o$`max-scenes`)
    res <- list(); disp <- list()
    for (ix in paires) {
      ix <- ix[order(proc[ix])]
      a <- lire_scene_pc(pc[ix[1], ], grille, o$scl, cache)
      b <- lire_scene_pc(pc[ix[2], ], grille, o$scl, cache)
      res[[length(res) + 1L]] <- comparer_paire(a, b, foret,
        "Sen2Cor ancien traitement", "Sen2Cor retraitement")
    }
    resultats <- do.call(rbind, res)
    utils::write.csv(resultats, file.path(sortie, "autotest_pc_pc.csv"),
                     row.names = FALSE)
    print(resultats[, c("date", "indice", "n", "biais", "rmse", "cor")])
    return(invisible(resultats))
  }

  maja <- NULL
  if (o$cote %in% c("theia", "les-deux")) {
    feats <- .nm(".reconfort_fenetre_lister")(o$tuile, o$debut, o$fin)
    cat(sprintf("THEIA : %d items MUSCATE\n", length(feats)))
    maja <- feats
  }

  lim <- function(n) if (o$`max-scenes` > 0L) min(n, o$`max-scenes`) else n

  if (o$cote == "pc") {
    sc <- lapply(seq_len(lim(nrow(pc))), function(i) lire_scene_pc(pc[i, ], grille, o$scl, cache))
    disp <- dispersion_cote(sc, foret, "Sen2Cor")
    utils::write.csv(disp, file.path(sortie, "dispersion_sen2cor.csv"), row.names = FALSE)
    print(disp); return(invisible(disp))
  }
  if (o$cote == "theia") {
    sc <- lapply(maja[seq_len(lim(length(maja)))], lire_scene_theia, grille, cache)
    disp <- dispersion_cote(sc, foret, "MAJA")
    utils::write.csv(disp, file.path(sortie, "dispersion_maja.csv"), row.names = FALSE)
    print(disp); return(invisible(disp))
  }

  # les-deux : appariement par jour
  d_maja <- as.Date(vapply(maja, function(ft)
    substr(ft$properties$datetime %||% ft$properties$start_datetime, 1, 10), ""))
  jours <- intersect(format(pc$obs_date), format(d_maja))
  cat(sprintf("Jours communs : %d (%s)\n", length(jours), paste(jours, collapse = " ")))
  if (!length(jours)) stop("aucune date commune entre les deux collections")
  jours <- jours[seq_len(lim(length(jours)))]
  res <- list(); dsp <- list()
  for (j in jours) {
    a <- lire_scene_theia(maja[[which(format(d_maja) == j)[1]]], grille, cache)
    b <- lire_scene_pc(pc[format(pc$obs_date) == j, , drop = FALSE][1, ], grille,
                       o$scl, cache)
    res[[length(res) + 1L]] <- comparer_paire(a, b, foret, "MAJA FRE", "Sen2Cor")
    dsp[[length(dsp) + 1L]] <- dispersion_cote(list(a), foret, "MAJA")
    dsp[[length(dsp) + 1L]] <- dispersion_cote(list(b), foret, "Sen2Cor")
  }
  resultats <- do.call(rbind, res)
  utils::write.csv(resultats, file.path(sortie, "ecarts_par_date.csv"), row.names = FALSE)
  utils::write.csv(do.call(rbind, dsp), file.path(sortie, "dispersion_par_date.csv"),
                   row.names = FALSE)
  print(resultats[, c("date", "indice", "n", "biais", "rmse", "cor", "pente")])
  invisible(resultats)
}

if (sys.nframe() == 0L) {
  o <- lire_options()
  if (!is.na(o$`maja-dir`)) principal_local(o) else principal(o)
}
