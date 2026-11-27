#!/usr/bin/env python3
"""Mission 093 - classes du modele v3 avec des reflectances MAJA contre Sen2Cor.

Entrees (hors depot, ecrites par echantillon_et_maja.R et sen2cor_pixels.R, converties en CSV
par exporter_series.R) : pixels.csv, series_maja.csv, series_sen2cor.csv.
Sorties (CSV legers) dans le dossier de l'etude.
Usage : python3 -I classes.py <dossier_travail> <modele.npz> <dates_interpolation.txt> \
            <092/ecarts_par_date.csv> <092/ecarts_total.csv> <dossier_sortie>
"""
import sys, csv, datetime as dt
import numpy as np
sys.path.insert(0, __file__.rsplit("/", 1)[0])
from shark_rf import Foret

W, MODELE, DATES, PAR_DATE, TOTAL, OUT = sys.argv[1:7]
BANDES = ["B4", "B5", "B6", "B8A", "B11", "B12"]


def lire_csv(chemin):
    with open(chemin) as f:
        r = csv.DictReader(f)
        return list(r)


def jour(s):  # AAAAMMJJ -> nombre de jours
    return dt.date(int(s[:4]), int(s[4:6]), int(s[6:])).toordinal()


dates67 = np.array([jour(x) for x in open(DATES).read().split()], float)
assert len(dates67) == 67
pts = lire_csv(f"{W}/pixels.csv")
N = len(pts)
def _v(x):  # un vote nul est stocke comme nodata (NA) dans ProbabilityMap : on le lit comme 0
    return 0 if x in ("NA", "") else int(x)


votes_iota = np.array([[_v(p["v1"]), _v(p["v2"]), _v(p["v3"])] for p in pts])
assert (votes_iota.sum(axis=1) == 1000).all()


def charger(chemin, maja):
    """Series longues -> dict pixel -> (jours, matrice (k,6) de reflectances 0-1, valide)."""
    lignes = lire_csv(chemin)
    par = [[] for _ in range(N)]
    for l in lignes:
        p = int(l["pt"]) - 1
        b = [float(l[k]) if l[k] not in ("NA", "") else np.nan for k in BANDES]
        if maja:
            m = [float(l[k]) if l[k] not in ("NA", "") else np.nan for k in ("CLM1", "CLM2", "EDG1", "SAT1", "SAT2")]
            ok = (not np.isnan(b).any()) and min(b) > -9000 and (not np.isnan(m).any()) and max(m) == 0
            b = [x / 10000 for x in b]
        else:
            ok = (not np.isnan(b).any()) and l["scl_ok"] == "TRUE"
        if ok:
            par[p].append((jour(l["date"]), b))
    return par


def pile(par, jours_ok=None, jmax=None):
    """134 caracteristiques : bandes interpolees lineairement (bords constants) sur 67 dates,
    puis CRswir_1..67 et CRre_1..67 (formules de custom_index.py). jours_ok : ne garder que ces
    jours ; jmax : ne garder que les observations jusqu'a ce jour."""
    X = np.full((N, 134), np.nan)
    nobs = np.zeros(N, int)
    for p, obs in enumerate(par):
        if jours_ok is not None:
            obs = [o for o in obs if o[0] in jours_ok]
        if jmax is not None:
            obs = [o for o in obs if o[0] <= jmax]
        obs = sorted(obs)
        nobs[p] = len(obs)
        if len(obs) < 2:
            continue
        d = np.array([o[0] for o in obs], float)
        B = np.array([o[1] for o in obs])
        I = {k: np.interp(dates67, d, B[:, i]) for i, k in enumerate(BANDES)}
        den = I["B8A"] + (1610 - 865) * ((I["B12"] - I["B8A"]) / (2190 - 865)); den[den == 0] = 1
        den2 = I["B4"] + (704 - 665) * ((I["B6"] - I["B4"]) / (741 - 665)); den2[den2 == 0] = 1
        X[p] = np.concatenate([I["B11"] / den, I["B5"] / den2])
    return X, nobs


def affine(X, coef):
    """Inverse de S2C = a + b * MAJA, par indice : MAJA_est = (S2C - a) / b."""
    Y = X.copy()
    (a1, b1), (a2, b2) = coef["CRswir"], coef["CRre"]
    Y[:, :67] = (X[:, :67] - a1) / b1
    Y[:, 67:] = (X[:, 67:] - a2) / b2
    return Y


# --- coefficients de la 092 ------------------------------------------------------------------
pd_ = lire_csv(PAR_DATE)
coef_date = {i: (np.mean([float(r["ordonnee"]) for r in pd_ if r["indice"] == i]),
                 np.mean([float(r["pente"]) for r in pd_ if r["indice"] == i])) for i in ("CRswir", "CRre")}
tot = lire_csv(TOTAL)
coef_tot = {r["indice"]: (float(r["ordonnee"]), float(r["pente"])) for r in tot}

# --- piles -----------------------------------------------------------------------------------
foret = Foret(MODELE)
maja = charger(f"{W}/series_maja.csv", True)
s2c = charger(f"{W}/series_sen2cor.csv", False)
jours_pc = {o[0] for obs in s2c for o in obs}
jours_maja = {o[0] for obs in maja for o in obs}
fin_fenetre = jour("20251029")

piles = {}
piles["maja"], n_maja = pile(maja)
piles["s2c"], n_s2c = pile(s2c)
piles["s2c_affine_par_date"] = affine(piles["s2c"], coef_date)
piles["s2c_affine_totale"] = affine(piles["s2c"], coef_tot)
# variantes de correction (en plus de l'inversion de la regression S2C = a + b MAJA demandee par la fiche)
bi = {i: np.mean([float(r["biais"]) for r in pd_ if r["indice"] == i]) for i in ("CRswir", "CRre")}
Xb = piles["s2c"].copy(); Xb[:, :67] -= bi["CRswir"]; Xb[:, 67:] -= bi["CRre"]
piles["s2c_biais_seul"] = Xb
# regression inverse MAJA = a' + b' S2C (pente = cor * sd_x / sd_y ; ordonnee = moy_x - pente * moy_y), moyenne des 12 dates
inv = {}
for i in ("CRswir", "CRre"):
    rr = [r for r in pd_ if r["indice"] == i]
    bp = np.mean([float(r["cor"]) * float(r["sd_x"]) / float(r["sd_y"]) for r in rr])
    ap = np.mean([float(r["mean_x"]) - float(r["cor"]) * float(r["sd_x"]) / float(r["sd_y"]) * float(r["mean_y"]) for r in rr])
    inv[i] = (ap, bp)
Xi = piles["s2c"].copy()
Xi[:, :67] = inv["CRswir"][0] + inv["CRswir"][1] * Xi[:, :67]
Xi[:, 67:] = inv["CRre"][0] + inv["CRre"][1] * Xi[:, 67:]
piles["s2c_regression_inverse"] = Xi
piles["maja_memes_jours_que_s2c"], n_mj = pile(maja, jours_ok=jours_pc)
piles["s2c_memes_jours_que_maja"], n_sj = pile(s2c, jours_ok=jours_maja)
piles["maja_jusqu_au_29_oct"], _ = pile(maja, jmax=fin_fenetre)
piles["s2c_jusqu_au_29_oct"], _ = pile(s2c, jmax=fin_fenetre)

V = {k: foret.votes(X) for k, X in piles.items()}
V["iota2"] = votes_iota
cl = {k: np.where(v.min(axis=1) < 0, 0, v.argmax(axis=1) + 1) for k, v in V.items()}  # 0 = non predictible


def wilson(k, n, z=1.96):
    if n == 0:
        return (np.nan, np.nan)
    p = k / n; d = 1 + z * z / n
    c = (p + z * z / (2 * n)) / d; h = z * np.sqrt(p * (1 - p) / n + z * z / (4 * n * n)) / d
    return (c - h, c + h)


def comparer(a, b, nom):
    ok = (cl[a] > 0) & (cl[b] > 0)
    n = int(ok.sum()); ch = int((cl[a][ok] != cl[b][ok]).sum())
    dv = np.abs(V[a][ok] - V[b][ok])
    lo, hi = wilson(ch, n)
    r = [np.corrcoef(V[a][ok][:, c], V[b][ok][:, c])[0, 1] for c in range(3)]
    # sous-ensembles selon la marge de vote (premier - deuxieme) du premier terme
    s = np.sort(V[a][ok], axis=1); marge = s[:, 2] - s[:, 1]
    chg = cl[a][ok] != cl[b][ok]
    return dict(comparaison=nom, n=n, change=ch, part_change=ch / n, ic95_bas=lo, ic95_haut=hi,
                ecart_abs_moyen_votes=dv.mean(), ecart_abs_median_votes=float(np.median(dv)),
                ecart_L1_moyen_par_pixel=dv.sum(axis=1).mean(),
                biais_vote_c1=(V[b][ok][:, 0] - V[a][ok][:, 0]).mean(),
                biais_vote_c2=(V[b][ok][:, 1] - V[a][ok][:, 1]).mean(),
                biais_vote_c3=(V[b][ok][:, 2] - V[a][ok][:, 2]).mean(),
                cor_c1=r[0], cor_c2=r[1], cor_c3=r[2],
                part_change_marge_lt_100=(chg[marge < 100].mean() if (marge < 100).any() else np.nan),
                n_marge_lt_100=int((marge < 100).sum()),
                part_change_marge_ge_100=(chg[marge >= 100].mean() if (marge >= 100).any() else np.nan),
                n_marge_ge_100=int((marge >= 100).sum()))


COMP = [("maja", "s2c", "MAJA -> Sen2Cor (brut)"),
        ("maja", "s2c_affine_par_date", "MAJA -> Sen2Cor corrige (affine, moyenne des 12 dates 092)"),
        ("maja", "s2c_affine_totale", "MAJA -> Sen2Cor corrige (affine, regression totale 092)"),
        ("maja", "s2c_biais_seul", "MAJA -> Sen2Cor corrige (biais moyen seul, 092)"),
        ("maja", "s2c_regression_inverse", "MAJA -> Sen2Cor corrige (regression inverse MAJA sur Sen2Cor, 092)"),
        ("maja", "iota2", "prototype sur MAJA -> IOTA2 (bruit du prototype)"),
        ("s2c", "iota2", "prototype sur Sen2Cor -> IOTA2"),
        ("maja", "maja_memes_jours_que_s2c", "controle : MAJA -> MAJA aux seuls jours Sen2Cor (effet des dates)"),
        ("maja", "s2c_memes_jours_que_maja", "controle : MAJA -> Sen2Cor aux seuls jours MAJA (radiometrie et masques, sans l'echantillonnage plus dense)"),
        ("s2c_memes_jours_que_maja", "s2c", "controle : Sen2Cor aux jours MAJA -> Sen2Cor complet (effet de l'echantillonnage plus dense)"),
        ("maja_memes_jours_que_s2c", "s2c", "controle : MAJA aux jours Sen2Cor -> Sen2Cor (effet radiometrie seule)"),
        ("maja_jusqu_au_29_oct", "s2c_jusqu_au_29_oct", "sensibilite : observations jusqu'au 2025-10-29 seulement"),
        ("maja", "maja_jusqu_au_29_oct", "controle : MAJA complet -> MAJA jusqu'au 2025-10-29")]
res = [comparer(a, b, n) for a, b, n in COMP]
with open(f"{OUT}/resume.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(res[0].keys())); w.writeheader(); w.writerows(res)

# matrices de confusion
for a, b, tag in [("maja", "s2c", "maja_sen2cor"), ("maja", "s2c_affine_par_date", "maja_sen2cor_affine"),
                  ("maja", "iota2", "maja_iota2"), ("s2c", "iota2", "sen2cor_iota2")]:
    M = np.zeros((3, 3), int)
    for x, y in zip(cl[a], cl[b]):
        if x > 0 and y > 0:
            M[x - 1, y - 1] += 1
    with open(f"{OUT}/confusion_{tag}.csv", "w", newline="") as f:
        w = csv.writer(f); w.writerow(["ligne=" + a + " / colonne=" + b, "classe1", "classe2", "classe3"])
        for i in range(3):
            w.writerow([f"classe{i + 1}"] + list(M[i]))

# par pixel (leger)
with open(f"{OUT}/classes_par_pixel.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["pt", "n_obs_maja", "n_obs_s2c", "cl_maja", "cl_s2c", "cl_s2c_affine", "cl_iota2",
                "maja_v1", "maja_v2", "maja_v3", "s2c_v1", "s2c_v2", "s2c_v3", "iota_v1", "iota_v2", "iota_v3"])
    for p in range(N):
        w.writerow([p + 1, n_maja[p], n_s2c[p], cl["maja"][p], cl["s2c"][p], cl["s2c_affine_par_date"][p], cl["iota2"][p],
                    *V["maja"][p], *V["s2c"][p], *V["iota2"][p]])

# repartition des classes et resume des series
with open(f"{OUT}/repartition_classes.csv", "w", newline="") as f:
    w = csv.writer(f); w.writerow(["pile", "classe1", "classe2", "classe3", "non_predits"])
    for k in cl:
        w.writerow([k] + [int((cl[k] == c).sum()) for c in (1, 2, 3, 0)])
# test apparie (McNemar) : la source Sen2Cor accorde-t-elle moins souvent la classe d'IOTA2 que MAJA ?
with open(f"{OUT}/mcnemar.csv", "w", newline="") as f:
    w = csv.writer(f); w.writerow(["pile", "maja_ok_pile_ko", "maja_ko_pile_ok", "z", "accord_pile_avec_iota2", "accord_maja_avec_iota2"])
    for k in ("s2c", "s2c_affine_par_date", "s2c_affine_totale", "s2c_biais_seul", "s2c_regression_inverse"):
        am, ak = cl["maja"] == cl["iota2"], cl[k] == cl["iota2"]
        b_, c_ = int((am & ~ak).sum()), int((~am & ak).sum())
        w.writerow([k, b_, c_, round((b_ - c_) / np.sqrt(b_ + c_), 2), round(ak.mean(), 3), round(am.mean(), 3)])
dd = {"coef_par_date_CRswir_a_b": coef_date["CRswir"], "coef_par_date_CRre_a_b": coef_date["CRre"],
      "coef_total_CRswir_a_b": coef_tot["CRswir"], "coef_total_CRre_a_b": coef_tot["CRre"],
      "jours_maja_avec_au_moins_un_pixel_valide": len(jours_maja), "jours_sen2cor_avec_au_moins_un_pixel_valide": len(jours_pc),
      "coef_regression_inverse_CRswir_a_b": inv["CRswir"], "coef_regression_inverse_CRre_a_b": inv["CRre"],
      "biais_moyen_par_date_CRswir_CRre": (bi["CRswir"], bi["CRre"]),
      "obs_valides_par_pixel_maja_med_min_max": (float(np.median(n_maja)), int(n_maja.min()), int(n_maja.max())),
      "obs_valides_par_pixel_s2c_med_min_max": (float(np.median(n_s2c)), int(n_s2c.min()), int(n_s2c.max())),
      "obs_valides_maja_memes_jours_que_s2c_med": float(np.median(n_mj)),
      "obs_valides_s2c_aux_jours_maja_med_min_max": (float(np.median(n_sj)), int(n_sj.min()), int(n_sj.max()))}
with open(f"{OUT}/parametres.txt", "w") as f:
    for k, v in dd.items():
        f.write(f"{k}: {v}\n")
        print(k, v)
for r in res:
    print(f"{r['comparaison'][:70]:70s} n={r['n']:4d} change={r['part_change']*100:5.1f}% [{r['ic95_bas']*100:4.1f}-{r['ic95_haut']*100:4.1f}] |dv|={r['ecart_abs_moyen_votes']:.1f}")
