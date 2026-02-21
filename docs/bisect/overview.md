---
sidebar_position: 1
---

# Git Bisect — Trouver le coupable en 6 questions

:::info Durée : 25 minutes
- 5 min : concept de la recherche binaire
- 10 min : bisect manuel
- 10 min : bisect automatique
:::

## Le problème

Un bug est en prod. Vous regardez votre historique :

```bash
cd ~/git-workshop/todocraft
git log --oneline | wc -l
# 49 commits

git log --oneline
# a1b2c3d (HEAD) chore: add bisect test script
# b2c3d4e chore: release v1.0.0
# c3d4e5f feat(filter): add composable multi-filter utility
# d4e5f6a feat(validation): add task input validation
# ...47 commits plus tôt...
```

Les tâches "haute priorité" s'affichent en dernier au lieu d'en premier. Quelqu'un a cassé `sortByPriority`. Lequel de ces 49 commits est le coupable ?

Vérifiez :

```bash
node tests/sort.test.js
# AssertionError: FAIL [0]: attendu high, obtenu low
```

## La recherche binaire appliquée à Git

`git bisect` utilise une **recherche dichotomique** sur votre historique :

```
49 commits à tester → log₂(49) ≈ 5.6 → 6 étapes maximum
```

```
[1 ─────────────── 25 ─────────────── 49]
                   ↑ bad
[1 ──────── 13 ─── 25]
            ↑ good
[13 ─── 19 ─── 25]
        ↑ bad
[13 ─── 16 ─── 19]
        ↑ good
[16 ─ 17 ─ 19]
      ↑ bad → commit 17 est le premier mauvais !
```

## Les commandes

```bash
git bisect start                # démarre la session
git bisect bad                  # HEAD est mauvais
git bisect good <commit>        # ce commit était bon
# → Git checkout le commit du milieu, vous testez

git bisect good                 # ce commit est bon → Git cherche plus loin
git bisect bad                  # ce commit est mauvais → Git remonte

git bisect skip                 # ce commit ne peut pas être testé
git bisect reset                # fin de session, retour à HEAD

# Semi-automatique
git bisect run <script>         # Git teste et décide tout seul
```
