# Mission 104 — nemeton-p4-actions-candidates

> Ouverte le 2026-11-28 sur la décision de Pascal (« A puis B d'affilée »). C'est le **côté cœur de la partie B** du brief app de la spec 072 (§ B2 étage 2, B3, B4, B5, B6) : le moteur de règles, que le brief demande « à ajouter au cœur (extension de la spec 072) ».
> La matrice signal-action reste **provisoire**. Le brief demande qu'un forestier la relise avant sa mise en service : cette relecture est à la charge de Pascal et n'est pas faite.
> Dépôt : `nemeton`, branche `ccr-b52c1910-gjp34w`, partie d'`origin/main` **après la fusion de #718** (release 2026.11.48). Si #718 n'est pas encore fusionnée au lancement, partir d'e036f3a et fusionner main avant la PR. Cycle dev `2026.11.48.9000`, pas de release.

## Mission

**En une phrase :** ajouter au cœur l'étage 2 du plan d'actions piloté par P4. Il comprend :
- un fichier de règles `inst/extdata/p4_regles_actions.yml`, marqué `provisoire: true`, avec son validateur ;
- un moteur qui produit, pour chaque UGF, des actions candidates et jusqu'à trois options chiffrées (conserver, intervenir, convertir), à partir du diagnostic P4, du statut Pareto et du risque de ruine ;
- l'élimination des options dominées ;
- une priorisation déterministe (manque à gagner × confiance NDP, avec une seconde liste pour les UGF concentrantes) ;
- les six garde-fous de B6, avec la traçabilité de la règle qui a produit chaque action.

Tout cela fonctionne sans LLM.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

1. **Écrire d'abord l'extension de la spec 072.** C'est un nouveau § « 15. Actions candidates », ou bien un fichier `specs/072-p4-rendement-net-risque/actions.md`, qui reprend B2 à B6 du brief en termes de cœur :
   - les fonctions ;
   - les entrées et les sorties ;
   - le format du YAML.

   Il faut aussi y noter, sans les trancher, les questions ouvertes 1 à 6 du brief.
2. **`p4_regles_actions.yml`**, à reprendre tel que la matrice B3 :
   - décision × Pareto ;
   - aléa dominant ;
   - UGF concentrante ;
   - seuil d'action d'aléa à 0,005 ;
   - effets qualitatifs par axe pour les options (B4) ;
   - bornes de prélèvement (B6.5).

   Ajouter `provisoire: true` et un validateur, avec la classe d'erreur `nemeton_p4_regles_invalides`.
3. **Fonctions exportées.** Les noms sont à aligner sur l'existant ; ceux-ci sont proposés :
   - `p4_actions_candidates(ugf_p4, pareto, ruine, regles)` rend une table par UGF et par action : règle source, tableau (coupes, travaux, aucun), libellé, version des paramètres et des règles.
   - `p4_options(ugf_p4, regles)` construit au plus trois options par UGF. Chacune porte `p4_net_apres`, recalculé par `indicateur_p4_rendement_net()` avec des entrées modifiées selon les règles, ses effets qualitatifs `+`, `0` ou `−`, et le marquage des options dominées.
   - `p4_prioriser(...)` : `manque_a_gagner = max(0, −ecart − seuil) × capital × surface` et `priorite = manque_a_gagner × confiance_ndp`. À manque égal, l'UGF dominée passe devant. Les UGF concentrantes forment une seconde liste. Les acquisitions de données sont classées à part.
   - `p4_contexte_llm(...)` produit l'objet structuré de B7, sans texte libre, pour l'étage 3 côté app.
4. **Garde-fous (B6)** :
   - vocation (aucune coupe motivée par P4 hors production et mixte) ;
   - axes protégés ;
   - précision (sous NDP 3 : acquisition, suivi ou travaux sans récolte) ;
   - ampleur (pas de coupe rase, bornes) ;
   - traçabilité.
   
   Le garde 3, sur les seuils d'alerte des profils, vit côté app : il faut l'exposer comme un paramètre.
5. **Tests.**
   - Le tableau de tests du brief sur la forêt de référence (§ 10), à reproduire exactement. En particulier : UGF 3 au rang 1 avec un manque à gagner de **617 €/an** (0,935 point × 66 000 €), trois options, actions d'aléa sécheresse et tempête ; UGF 1 concentrante pour la tempête.
   - Si un chiffre attendu ne se retrouve pas par le calcul défini, le dire au lieu d'ajuster le test.
   - Plus : signal seulement → acquisitions uniquement ; garde de vocation ; traçabilité ; validateur.
6. **Livraison.**
   - Fonctions exportées documentées et testées, ajoutées à `_pkgdown.yml`.
   - Code en ASCII, messages cli en anglais.
   - NEWS, DESCRIPTION en `2026.11.48.9000` (ou `.9001` si main est déjà en `.9000`), PLAN.md.

## Hors périmètre

L'étage 3 (LLM, profils, sortie structurée) et l'étage 4 (validation), qui relèvent de la mission 105, côté app. La relecture de la matrice par un forestier.

## L'Homme

`dev`, worktree nemeton ; relu par le `relecteur`. Budget 6 $.
