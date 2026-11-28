#!/usr/bin/env python3
"""Verification du predicteur : reproduit l'essai de la 091 (30 pixels, bandes 20 m au plus proche voisin).
Usage : python3 -I reproduire_091.py <modele.npz> <pixels_091.csv> <feat_near_091.csv> <votes_091.txt>"""
import sys, csv
import numpy as np
sys.path.insert(0, __file__.rsplit("/", 1)[0])
from shark_rf import Foret
npz, pix, feat, v091 = sys.argv[1:5]
P = list(csv.DictReader(open(pix)))
iota = np.array([[int(p["p1"]), int(p["p2"]), int(p["p3"])] for p in P])
X = np.genfromtxt(feat, delimiter=",")
V = Foret(npz).votes(X)
anc = np.array([[int(z) for z in l.split()] for l in open(v091) if l.strip()])
print("votes identiques a ceux de la 091 :", bool((V == anc).all()))
print("classe identique a IOTA2 : %d / %d" % ((V.argmax(1) == iota.argmax(1)).sum(), len(V)))
print("ecart absolu moyen des votes : %.1f" % np.abs(V - iota).mean())
