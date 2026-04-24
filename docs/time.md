---
sidebar_class_name: hidden
---

# Timing du workshop

:::warning Page interne
Cette page n'est **pas référencée** dans la navigation publique. Elle est réservée à l'animateur pour gérer le timing du workshop. Ne pas partager le lien aux participants.
:::

## Durée totale : 3 heures

| Horaire | Durée  | Contenu                                                      |
| ------- | ------ | ------------------------------------------------------------ |
| 00:00   | 10 min | Introduction + setup du projet                               |
| 00:10   | 35 min | **Module 1** — Worktrees : 3 features en même temps          |
| 00:45   | 30 min | **Module 2** — Reflog : ressusciter des commits perdus       |
| 01:15   | 25 min | **Module 3** — Bisect : débusquer le coupable                |
| 01:40   | 10 min | ☕ Pause                                                     |
| 01:50   | 35 min | **Module 4** — Rebase : réécrire l'histoire (proprement)     |
| 02:25   | 15 min | **Module 5** — Workflows : Gitflow, GitHub Flow, Trunk-Based |
| 02:40   | 20 min | Wrap-up, questions & challenges à faire chez soi             |

## Détail par module

### Setup — 5 minutes

Faire le clone et vérifier l'historique. Si un participant bloque, l'aider en 1:1 pendant que les autres explorent.

### Module 1 — Worktrees (35 minutes)

- **5 min** : concept + démonstration
- **25 min** : TP
- **5 min** : patterns avancés + challenges

### Module 2 — Reflog (30 minutes)

- **5 min** : concept
- **22 min** : 3 scénarios de récupération
- **3 min** : configuration et bonnes pratiques

### Module 3 — Bisect (25 minutes)

- **5 min** : concept de la recherche binaire
- **10 min** : bisect manuel
- **10 min** : bisect automatique

### ☕ Pause (10 minutes)

À placer avant le module Rebase pour garder l'attention sur la partie la plus dense.

### Module 4 — Rebase (35 minutes)

Module souvent le plus long à digérer — prévoir du temps pour les questions sur le modèle mental avant d'attaquer l'atelier interactif.

### Module 5 — Workflows (15 minutes)

Vue d'ensemble comparative. Les pages détaillées (Gitflow, GitHub Flow, Trunk-Based) sont pour l'après-workshop.

### Bonus (15 minutes, optionnel)

À faire si l'on termine en avance, ou à proposer en lecture à la maison.

## Tips animation

- Module Rebase = 35 min mais prévoir **5-10 min de marge** car c'est là que les participants posent le plus de questions.
- Module Bisect : le bisect automatique avec `bisect run` est rapide (2-3 min) — ne pas s'y attarder, l'essentiel est le bisect manuel.
- Si en retard : couper le module Workflows à 10 min et les pages détaillées renvoyées à après le workshop.
- Si en avance : enchaîner sur un bonus (git alias ou git hooks) avant le wrap-up.
