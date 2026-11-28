#!/usr/bin/env Rscript
# Mission 093 - series Sen2Cor (Planetary Computer, sentinel-2-l2a) aux memes pixels que MAJA.
# Reutilise telles quelles les fonctions de l'etude 092 (comparer.R : grille, lecture sur grille
# au plus proche voisin, offset BOA, SCL) et de nemeton (stac_search_s2_pc, .dedup_s2_reprocessed).
# Usage : Rscript sen2cor_pixels.R <comparer.R de la 092> <dossier_travail> <scene_maja_exemple_FRE_B4.tif> \
#           [debut=2024-01-01] [fin=2025-12-31] [cache] [coeurs=4]
suppressPackageStartupMessages({library(terra); library(parallel)})
a <- commandArgs(TRUE)
src092 <- a[1]; W <- a[2]; r0f <- a[3]
debut <- if (length(a) >= 4) a[4] else "2024-01-01"; fin <- if (length(a) >= 5) a[5] else "2025-12-31"
cache <- if (length(a) >= 6) a[6] else file.path(W, "cache_pc"); nco <- as.integer(if (length(a) >= 7) a[7] else 4)
dir.create(cache, showWarnings = FALSE, recursive = TRUE)
e <- new.env(); sys.source(src092, envir = e)   # definit les fonctions, ne lance rien (garde sys.nframe)
pts <- read.csv(file.path(W, "pixels.csv"))
r0 <- rast(r0f); grille <- rast(ext(r0), resolution = 10, crs = "EPSG:2154")
cel <- cellFromXY(grille, as.matrix(pts[, c("x", "y")])); stopifnot(!anyNA(cel))
bb <- ext(project(as.polygons(ext(grille), crs = "EPSG:2154"), "EPSG:4326"))
bbox <- as.numeric(bb[c(1, 3, 2, 4)])
sc <- e$.nm(".dedup_s2_reprocessed")(e$.nm("stac_search_s2_pc")(bbox, debut, fin, max_cloud = 100))
sc <- sc[grepl("_T31TFN_", sc$scene_id), , drop = FALSE]
sc <- sc[order(sc$obs_date), , drop = FALSE]
cat(sprintf("Scenes PC T31TFN %s -> %s : %d (apres dedoublonnage des retraitements)\n", debut, fin, nrow(sc)))
un <- function(i) {
  f <- file.path(cache, paste0("pix_", sc$scene_id[i], ".rds"))
  if (file.exists(f)) return(readRDS(f))
  r <- tryCatch(e$lire_scene_pc(sc[i, ], grille, 4:5, cache), error = function(err) { message("ECHEC ", sc$scene_id[i], " : ", conditionMessage(err)); NULL })
  if (is.null(r)) return(NULL)
  res <- data.frame(scene = r$scene_id, date = format(r$date, "%Y%m%d"), pt = pts$pt,
                    B4 = r$refl[cel, "B04"], B5 = r$refl[cel, "B05"], B6 = r$refl[cel, "B06"],
                    B8A = r$refl[cel, "B8A"], B11 = r$refl[cel, "B11"], B12 = r$refl[cel, "B12"],
                    scl_ok = r$ok[cel], nuages_scene = sc$cloud_pct[i])
  saveRDS(res, f)
  unlink(file.path(cache, paste0("pc_", sc$scene_id[i], ".rds")))  # matrice complete : inutile, volumineuse
  res
}
t0 <- Sys.time()
out <- mclapply(seq_len(nrow(sc)), un, mc.cores = nco, mc.preschedule = FALSE)
bad <- vapply(out, is.null, NA)
cat(sprintf("Lecture : %.1f min ; echecs : %d\n", as.numeric(difftime(Sys.time(), t0, units = "mins")), sum(bad)))
saveRDS(do.call(rbind, out[!bad]), file.path(W, "series_sen2cor.rds"))
