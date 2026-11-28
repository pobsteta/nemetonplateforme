#!/usr/bin/env Rscript
# Mission 093 - (1) tire l'echantillon de pixels feuillus (masque OSO du run, graine fixee),
# (2) lit les votes IOTA2 du run, (3) extrait les series MAJA (scenes du run) aux pixels.
# Usage : Rscript echantillon_et_maja.R <output_zone_63> <dossier_travail> [n=1000] [graine=93]
# Lecture seule sur le run ; rien n'est execute depuis les donnees. Ecrit dans <dossier_travail>.
suppressPackageStartupMessages(library(terra))
a <- commandArgs(TRUE)
O <- a[1]; W <- a[2]; n <- as.integer(if (length(a) >= 3) a[3] else 1000); graine <- as.integer(if (length(a) >= 4) a[4] else 93)
R <- file.path(O, "results/iota2_results_classif_labels-z63-S2_2025")
F <- rast(file.path(R, "final/Final_Classif_masked_2025.tif"))   # > 0 = feuillus OSO
P <- rast(file.path(R, "final/ProbabilityMap_seed_0.tif"))       # votes sur 1000, classes 1 2 3
C <- rast(file.path(R, "final/Classif_Seed_0.tif"))
ok <- which(values(F)[, 1] > 0)
set.seed(graine); s <- sort(sample(ok, n))
xy <- xyFromCell(F, s)
pts <- data.frame(pt = seq_len(n), cell = s, x = xy[, 1], y = xy[, 2], cls_iota = values(C)[s, 1],
                  v1 = values(P)[s, 1], v2 = values(P)[s, 2], v3 = values(P)[s, 3])
write.csv(pts, file.path(W, "pixels.csv"), row.names = FALSE)
cat(sprintf("pixels masques feuillus : %d ; tires : %d (graine %d)\n", length(ok), n, graine))
v <- vect(as.matrix(pts[, c("x", "y")]), crs = "EPSG:2154")
dirs <- list.dirs(file.path(O, "s2_download/extracted/T31TFN"), recursive = FALSE)
dirs <- dirs[grepl("^SENTINEL2", basename(dirs))]
ex <- function(p) if (!file.exists(p)) rep(NA_real_, n) else as.numeric(extract(rast(p), v, method = "simple", ID = FALSE)[, 1])
out <- lapply(dirs, function(d) {
  b <- basename(d)
  g <- function(s) ex(file.path(d, paste0(b, s)))
  m <- function(s) ex(file.path(d, "MASKS", paste0(b, s)))
  data.frame(scene = b, date = sub("^SENTINEL2[ABC]_([0-9]{8}).*", "\\1", b), pt = pts$pt,
             B4 = g("_FRE_B4.tif"), B5 = g("_FRE_B5.tif"), B6 = g("_FRE_B6.tif"), B8A = g("_FRE_B8A.tif"),
             B11 = g("_FRE_B11.tif"), B12 = g("_FRE_B12.tif"),
             CLM1 = m("_CLM_R1.tif"), CLM2 = m("_CLM_R2.tif"), EDG1 = m("_EDG_R1.tif"),
             SAT1 = m("_SAT_R1.tif"), SAT2 = m("_SAT_R2.tif"))
})
res <- do.call(rbind, out)
saveRDS(res, file.path(W, "series_maja.rds"))
cat(sprintf("series MAJA : %d scenes, %d lignes\n", length(dirs), nrow(res)))
