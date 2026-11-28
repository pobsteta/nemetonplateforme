# Mission 105 — nemetonshiny-p4-plan-actions

> Ouverte le 2026-11-28, suite de la décision de Pascal (« A puis B d'affilée »). Il s'agit des étages 3 et 4 de la partie B du brief app de la spec 072 : `nemeton/specs/072-p4-rendement-net-risque/brief-nemetonshiny.md`, § B2, B6 à B9, Tests, jalons A3 et A4.
> Le cœur nécessaire est **nemeton 2026.11.49** (mission 106, PR #720). Il contient les étages 1 et 2 : `p4_actions_candidates()`, `p4_options()`, `p4_prioriser()`, `p4_contexte_llm()`, `p4_regles_actions()` (mission 104, § 15 de `specs/072-p4-rendement-net-risque/actions.md`).
> Dépôt : `nemetonshiny`, sur la partie A (mission 103, PR #356) fusionnée. Pas de release.

## Mission

**En une phrase :** faire rédiger par le LLM, profil par profil, le plan d'actions P4 à partir des options du cœur, et le faire valider par l'utilisateur.

Le LLM retient une option fournie par UGF, rédige, et sa sortie est validée contre un schéma. Le plan dégradé du cœur sert de repli. L'utilisateur accepte, modifie ou rejette chaque action, et le plan est sauvegardé dans un format versionné.

**Redite par l'agent :** _à compléter avant d'agir._

## Attendu

**Le cœur fait foi pour tout calcul** : candidates, options, `p4_net_apres`, priorité. L'app ne recalcule rien et ne réordonne pas les priorités.

1. **Note d'alignement d'abord**, dans `pilotage/notes/105-alignement-plan-actions.md` de nemetonshiny. Elle répond, en lisant le code, aux questions ouvertes 1, 2 et 6 du brief :
   - les champs actuels d'une action du plan ;
   - si le LLM choisit aujourd'hui librement ou dans une liste ;
   - où les conflits entre profils sont exposés.

   Elle situe aussi :
   - le service de plan d'actions existant ;
   - l'appel `ellmer` ;
   - le chargement des profils (`R/llm_prompts.R`, `inst/experts/*.yml`).
2. **Contexte (B7).** Il est construit par `nemeton::p4_contexte_llm()`, appelé depuis un service, jamais depuis un module. On ne transmet aucun texte libre issu des données : seulement les identifiants `ugf_<n>`. On les retraduit en noms d'UGF après la réponse, par l'attribut `correspondance`.
3. **Profils (B8).** Le bloc `p4` (règles FR et EN, `poids_p4`) va dans chaque profil de `inst/experts/*.yml`, `generalist.yml` compris.
   - Les valeurs de `poids_p4` sont **provisoires** : `fort` si P est une famille prioritaire du profil, `faible` pour le naturaliste, `moyen` sinon.
   - Les lister dans la note pour que Pascal les relise.
   - Les seuils d'alerte des profils passent au cœur par `garde_profil`.
4. **Sortie structurée (B9).**
   - Schéma explicite avec les champs `ugf`, `option`, `tableau`, `libelle`, `annee`, `justification`, `arbitrage`, `conflit_profils` et `statut = "proposee"`.
   - Toute réponse non conforme est rejetée, de même qu'une option qui n'est pas fournie pour l'UGF, une UGF inconnue, ou un `tableau` incohérent avec l'invariant du cœur (récolte ⇔ `coupes`).
   - Une réponse rejetée est remplacée par le plan dégradé (option la mieux classée par le cœur, sans rédaction), et le rejet est visible à l'utilisateur.
   - Il en va de même en cas d'API absente ou en erreur.
5. **Garde-fous (B6), en plus de ceux du cœur.**
   - `signal_seulement` ne produit que des acquisitions.
   - Aucune coupe hors vocation production ou mixte.
   - Une option qui dégrade un axe protégé est présentée comme arbitrage explicite.
6. **Validation (étage 4).** L'utilisateur accepte, modifie (`libelle`, `annee`) ou rejette chaque action.
   - Le plan sauvegardé garde la règle, les valeurs P4, la version des paramètres et des règles, le profil, l'origine (`llm` ou `repli`) et le statut.
   - Le format est versionné, avec migration et test d'aller-retour. Un projet existant se charge à l'identique.
7. **UI et i18n.**
   - Contenu généré en ambre (`btn-ia` / `bg-ia`, icône `stars`) ; actions de l'utilisateur dans la hiérarchie normale.
   - Toutes les clés en FR et EN, en `\uXXXX`.
   - Retour immédiat sur l'appel LLM (toast, bouton désactivé).
   - L'appel est asynchrone (`ExtendedTask`).
8. **Tests, avec un LLM simulé** (`local_mocked_bindings`), sur la forêt de référence de la spec 072 (§ 10). Ils couvrent la table « Tests » du brief, plus :
   - le repli sans LLM ;
   - le rejet d'une sortie non conforme ;
   - le refus d'une option inventée ;
   - le signal seulement ;
   - la vocation ;
   - l'aller-retour du plan ;
   - la traçabilité ;
   - deux profils opposés (naturaliste, industrie bois) qui reçoivent le même contexte et ne diffèrent que par le prompt.
9. **Hors périmètre :**
   - la boucle d'évaluation B10 (il faut deux inventaires) ;
   - l'essai réel sur deux profils, qui revient à Pascal avec sa clé API ;
   - toute modification du cœur. Si le cœur manque, le dire et s'arrêter.
10. **Version** : `Imports: nemeton (>= 2026.11.49)`, cycle dev `.90xx` suivant, NEWS. Pas de release.

## L'Homme

`dev`, worktree nemetonshiny ; relu par le `relecteur` ; tests rejoués par l'orchestrateur contre nemeton 2026.11.49 installé depuis le tag. Budget 6 $.

## Dépend de / rouge attendu jusqu'à

Release nemeton `v2026.11.49` (mission 106) et fusion de la PR nemetonshiny #356 (mission 103).
