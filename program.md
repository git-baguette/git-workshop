# Module 1 : Introduction et mise en contexte (~20 min)

Présentation des objectifs du workshop
Présentation du projet fil rouge (application web simple avec backend/frontend)
Installation et vérification de l'environnement

# Module 2 : Commandes avancées pour la productivité (~50 min)

## 2.1 Git Worktree (~20 min)

Théorie : Pourquoi et quand utiliser worktree
Pratique :
Créer plusieurs worktrees pour travailler sur différentes features simultanément
Gérer les worktrees (list, remove, prune)
Cas d'usage : review de code, hotfix urgent pendant le développement d'une feature

## 2.2 Git Bisect (~15 min)

Théorie : Recherche dichotomique de bugs
Pratique :
Simuler un bug introduit dans l'historique
Utiliser git bisect pour identifier le commit fautif
Automatiser avec git bisect run

## 2.3 Autres commandes utiles (~15 min)

git reflog : retrouver des commits "perdus"
git cherry-pick : appliquer des commits sélectifs
git stash avancé : stash partiel, branches depuis stash
git rebase -i : nettoyer l'historique avant merge

# Module 3 : Stratégies de branching et workflows (~60 min)

## 3.1 Tour d'horizon des workflows (~25 min)

### Gitflow :

Principe et branches (main, develop, feature, release, hotfix)
Avantages : structure claire, releases planifiées
Inconvénients : complexité, overhead

### GitHub Flow :

Principe : main + feature branches + pull requests
Avantages : simplicité, déploiement continu
Inconvénients : nécessite CI/CD solide
Comparaison : tableau récapitulatif selon le contexte projet

## 3.2 Exercice pratique : Implémenter un workflow (~35 min)

Diviser les participants en groupes
Chaque groupe implémente un workflow différent sur le projet fil rouge
Simulation de scénarios réels :
Développement de 2 features en parallèle
Hotfix urgent en production
Release avec bug découvert en staging
Débriefing : retours d'expérience par groupe

# Module 4 : Bonnes pratiques professionnelles (~40 min)

## 4.1 Commits et messages (~10 min)

Convention Conventional Commits
Commits atomiques vs monolithiques
Utiliser git commit --fixup et git rebase --autosquash

## 4.2 Gestion des conflits (~15 min)

Stratégies de merge vs rebase
Outils pour résoudre les conflits (mergetool, VS Code)
Pratique : résoudre un conflit complexe sur le projet

## 4.3 Hooks et automatisation (~15 min)

Pre-commit hooks : linting, tests
Commit-msg hooks : validation des messages
Démo avec husky ou pre-commit
CI/CD : intégration avec GitHub Actions/GitLab CI

# Module 5 : Mise en pratique et Q&A (~30 min)

## 5.1 Challenge final (~20 min)

Scénario complet combinant plusieurs techniques :

Bug critique en production (bisect)
Feature en cours à poursuivre (worktree)
Historique à nettoyer avant merge (rebase interactif)
Conflit à résoudre

## 5.2 Questions & Réponses (~10 min)

Retours sur le workshop
Cas d'usage spécifiques des participants
Ressources complémentaires
