#!/usr/bin/env python3
"""Lecteur et predicteur du format SharkRF d'OTB (archive texte Boost), vectorise.

Mission 093 (reprend le prototype de la 091, qui n'avait pas ete commite).
Format deduit par observation (cf. etudes/091-modele-reconfort-v3/rapport.md,
sections 1 et 4) : lignes 1-3 d'en-tete, puis 3 lignes par arbre :
  ligne de noeuds : id, N, ..., quadruplets (attribut, seuil, gauche, droite)
  ligne de classes : une classe par feuille
  ligne de 5 jetons.
Une feuille a gauche == 0 et droite == numero de feuille. Descente : x[attr] <= seuil
-> gauche, sinon droite. Vote : une voix par arbre pour la classe de la feuille.
Usage : python3 -I shark_rf.py convertir <modele.txt> <sortie.npz>
        python3 -I shark_rf.py predire <modele.npz> <matrice.csv>   (stdout : votes)
"""
import sys
import numpy as np


def convertir(chemin, sortie):
    """Lit le texte (traite comme donnee, jamais execute) et ecrit un npz compact."""
    with open(chemin) as f:
        lignes = f.read().split("\n")
    attr, seuil, gauche, droite, racines = [], [], [], [], []
    base = 0
    for k in range(1000):
        t = lignes[3 + 3 * k].split()
        d = lignes[4 + 3 * k].split()
        n = int(t[1])
        f = next(i for i, x in enumerate(t) if "e" in x and "." in x)
        s = f - 1
        nl = int(d[1])
        cls = [int(x) for x in d[2:2 + nl]]
        racines.append(base)
        for i in range(n):
            a, thr, l, r = int(t[s + 4 * i]), float(t[s + 4 * i + 1]), int(t[s + 4 * i + 2]), int(t[s + 4 * i + 3])
            if l != 0:
                attr.append(a); seuil.append(thr); gauche.append(base + l); droite.append(base + r)
            else:  # feuille : on range la classe dans `gauche`
                attr.append(-1); seuil.append(0.0); gauche.append(cls[r]); droite.append(-1)
        base += n
    np.savez_compressed(sortie, attr=np.array(attr, np.int16), seuil=np.array(seuil, np.float64),
                        gauche=np.array(gauche, np.int32), droite=np.array(droite, np.int32),
                        racines=np.array(racines, np.int32))


class Foret:
    def __init__(self, npz):
        z = np.load(npz)
        self.attr, self.seuil = z["attr"], z["seuil"]
        self.gauche, self.droite, self.racines = z["gauche"], z["droite"], z["racines"]

    def votes(self, X, lot=250):
        """X : (n pixels, 134) float64 -> (n, 3) votes (classes 1, 2, 3) sur 1000 arbres.
        NaN dans une ligne -> ligne de -1 (pixel non predictible)."""
        X = np.asarray(X, np.float64)
        out = np.full((X.shape[0], 3), -1, np.int32)
        bon = ~np.isnan(X).any(axis=1)
        for d in range(0, len(X), lot):
            idx = np.where(bon[d:d + lot])[0] + d
            if not len(idx):
                continue
            Xi = X[idx]
            p, t = len(idx), len(self.racines)
            noeud = np.tile(self.racines, (p, 1))
            ligne = np.repeat(np.arange(p), t).reshape(p, t)
            actif = np.ones((p, t), bool)
            while actif.any():
                a = self.attr[noeud]
                feuille = a < 0
                actif &= ~feuille
                if not actif.any():
                    break
                ac = np.where(actif)
                n = noeud[ac]
                x = Xi[ligne[ac], self.attr[n]]
                noeud[ac] = np.where(x <= self.seuil[n], self.gauche[n], self.droite[n])
            cls = self.gauche[noeud]  # classe de la feuille (0..2)
            for c in range(3):
                out[idx, c] = (cls == c).sum(axis=1)
        return out


if __name__ == "__main__":
    if sys.argv[1] == "convertir":
        convertir(sys.argv[2], sys.argv[3])
    else:
        X = np.genfromtxt(sys.argv[3], delimiter=",")
        for v in Foret(sys.argv[2]).votes(X):
            print(*v)
