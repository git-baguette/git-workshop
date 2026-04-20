---
sidebar_position: 1
---

# Vous croyez connaître Git ? Challenge Accepted.

Vous savez faire `git commit -m "fix"`. Bravo. Mais est-ce que vous savez retrouver ce commit que vous avez supprimé par erreur à 16h58 un vendredi ? Est-ce que vous savez trouver le bug introduit il y a 47 commits sans lire tout l'historique ? Est-ce que vous travaillez sur 3 features en même temps sans avoir l'impression de jongler avec des grenades ?

Ce workshop est fait pour vous.

## Le projet fil rouge : NG Baguette Conf

Tout au long du workshop, vous travaillerez sur **NG Baguette Conf** — un site de conférence Astro + Tailwind avec :

- **~32 commits** d'historique réaliste avec un bug caché quelque part
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
