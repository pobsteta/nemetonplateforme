# Mission 067 — nemetonshiny-effet-gestion

> Ouverte le 2026-11-25 au cycle 18 sous la consigne de Pascal de continuer les briefs restants, et sur sa décision du même jour (journal, « décisions », point 7 : type de gestion saisi par UGF, liste fermée ; tableau seulement si au moins deux types renseignés). Origine : brief `nemeton/specs/068-trajectoires-finn/brief-nemetonshiny.md` (partie « effets de la gestion ») ; écart n° 27 de `nemeton/PLAN.md` ; cœur livré en 2026.11.8.
> Dépôt : `nemetonshiny`, branche imposée `ccr-b52c1910-gjp34w`, partie d'`origin/main` à jour (après #337). **Pas de release.**

## Mission

**En une phrase (quoi, et pourquoi) :** Permettre de déclarer le type de gestion de chaque UGF (liste fermée) et montrer dans la synthèse, à la demande, le tableau « ce que la gestion a produit sur ce massif » calculé par `nemeton::effet_gestion()`, pour que le gestionnaire voie l'effet associé à chaque type de gestion sur chaque famille, avec son incertitude et sans le présenter comme une preuve causale.

**Redite par l'agent :** _à compléter par l'agent avant d'agir — s'il n'y arrive pas, il s'arrête._

## Ce que disent le brief et la décision de Pascal (font foi)

1. **Saisie** : un champ « type de gestion » par UGF, **liste fermée** : régulière, irrégulière (futaie jardinée / continue), taillis, taillis sous futaie, libre évolution, non renseigné (défaut). Valeur déclarée par le forestier, enregistrée avec l'UGF (même mécanisme de persistance que les autres attributs d'UGF), clés stables NMT (ex. `reguliere`, `irreguliere`, `taillis`, `taillis_sous_futaie`, `libre_evolution`, `non_renseigne`), libellés FR/EN par i18n.
2. **Calcul** : `effet_gestion(units, traitement = <colonne>, reference = ...)` du cœur, **à la demande** (bouton ; quelques dizaines de secondes avec ranger ; tâche longue → `ExtendedTask`, retour immédiat, bouton désactivé pendant le calcul, cf. CLAUDE.md), jamais à chaque affichage. Lire la signature réelle (référence par défaut, colonnes attendues : familles, station) dans `nemeton/R/effet_gestion.R`.
3. **Affichage dans la synthèse** : seulement si **au moins deux types** sont renseignés (hors `non_renseigne`) ; sinon un message qui dit quoi saisir. Une ligne par famille, **l'intervalle (ic_bas – ic_haut, 90 %) avant le chiffre**, `n_traite` / `n_reference` ; quand `statut` ≠ `calcule` (`recouvrement_insuffisant`, `trop_peu_unites`), le statut traduit et rien d'autre. Mention fixe sous le tableau : « association ajustée sur la station, pas une preuve causale ».
4. Pas de logique métier dans l'app : l'effet, l'IC et le statut viennent du cœur.

## Les sources

- `nemetonshiny/CLAUDE.md` (i18n `\uXXXX`, clés ≤ 30, pas de logique métier dans `mod_*`, couleurs de boutons — le bouton de calcul est une action principale de la vue, `ExtendedTask`, cycle dev, NEWS ; **pas de caractère non ASCII dans le code R**, cause de deux CI rouges aujourd'hui).
- Cœur en lecture : `nemeton/R/effet_gestion.R`, spec 068.
- App : `R/mod_ug.R` / `R/domain_ug.R` (attributs et persistance des UGF), `R/mod_synthesis.R`, `R/service_*`.

## Cas limites (un test par cas, sans réseau ; cœur simulé pour la partie lente)

1. Saisie : la valeur est enregistrée et relue avec le projet ; une valeur hors liste est refusée ; défaut `non_renseigne`.
2. Moins de deux types renseignés : pas de tableau, message de saisie, aucun appel au cœur.
3. Deux types ou plus : le cœur reçoit la bonne colonne ; le tableau montre l'IC avant le chiffre ; la mention « pas une preuve causale » est présente (FR/EN).
4. `statut` = `recouvrement_insuffisant` ou `trop_peu_unites` : seul le statut traduit s'affiche pour la ligne.
5. Le calcul passe par `ExtendedTask` (bouton désactivé pendant le calcul, notification).

## Ce qui est attendu

1. Code services / modules, tests ci-dessus ; `.claude/test-command` et lot ciblé ; sha, commande, code, durée, réussis/échoués/sautés ; contre-épreuve.
2. Cycle dev suivant, entrée NEWS. Commit sur `ccr-b52c1910-gjp34w`, push. L'orchestrateur ouvre la PR.

## L'Homme

- **Agent :** `dev`, worktree de nemetonshiny. Relu par le `relecteur`.
- **Moyens :** budget 5 $.
- **Ce qui ne lui est pas demandé :** déduire le type depuis la BD Forêt ; le skill `aigora` ; release ; PR.
- **Dépend de :** fusion de nemetonshiny #337 (branche de session).
