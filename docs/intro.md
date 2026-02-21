---
sidebar_position: 1
---

# Vous croyez connaître Git ? Challenge Accepted.

Vous savez faire `git commit -m "fix"`. Bravo. Mais est-ce que vous savez retrouver ce commit que vous avez supprimé par erreur à 16h58 un vendredi ? Est-ce que vous savez trouver le bug introduit il y a 47 commits sans lire tout l'historique ? Est-ce que vous travaillez sur 3 features en même temps sans avoir l'impression de jongler avec des grenades ?

Ce workshop est fait pour vous.

## Planning — 3 heures

| Horaire | Durée  | Contenu                                                      |
| ------- | ------ | ------------------------------------------------------------ |
| 00:00   | 10 min | Introduction + setup du projet                               |
| 00:10   | 35 min | **Module 1** — Worktrees : 3 features en même temps          |
| 00:45   | 30 min | **Module 2** — Reflog : ressusciter des commits perdus       |
| 01:15   | 10 min | ☕ Pause                                                     |
| 01:25   | 25 min | **Module 3** — Bisect : débusquer le coupable                |
| 01:50   | 35 min | **Module 4** — Rebase : réécrire l'histoire (proprement)     |
| 02:25   | 15 min | **Module 5** — Workflows : Gitflow, GitHub Flow, Trunk-Based |
| 02:40   | 20 min | Wrap-up, questions & challenges à faire chez soi             |

## Le projet fil rouge : TodoCraft

Tout au long du workshop, vous travaillerez sur **TodoCraft** — une application de gestion de tâches avec :

- **47 commits** d'historique réaliste avec un bug caché quelque part
- **3 branches** en cours de développement simultané
- Des commits "perdus" à retrouver avec le reflog
- Un historique à nettoyer avec rebase

Avant de commencer quoi que ce soit : **[Setup du projet →](/docs/setup)**

## Ce que vous repartez avec

- **Worktrees** : finies les semaines à jongler avec `git stash`
- **Reflog** : plus jamais de sueurs froides sur un `reset --hard`
- **Bisect** : trouver n'importe quel bug en 6 questions
- **Rebase interactif** : un historique propre qui raconte une histoire
- **Workflows** : choisir le bon outil pour votre équipe

## Prérequis

```bash
git --version
# git version 2.23.0 minimum (2.30+ recommandé pour toutes les features)
node --version
# Node.js 18+ (pour les scripts de test du module Bisect)
```

:::tip Niveau requis
Savoir ce qu'est un commit. Si vous tapez encore `git add .` les yeux fermés en priant, c'est parfait — on est exactement là pour ça.
:::
