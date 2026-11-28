#!/usr/bin/env Rscript
# Convertit les RDS (series_maja.rds, series_sen2cor.rds) en CSV pour classes.py (hors depot).
a <- commandArgs(TRUE); W <- a[1]
for (n in c("maja", "sen2cor")) write.csv(readRDS(file.path(W, paste0("series_", n, ".rds"))), file.path(W, paste0("series_", n, ".csv")), row.names = FALSE)
