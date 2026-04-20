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
cd $WORKSHOP_DIR/ng-baguette-conf
git log --oneline | wc -l
# 32 commits

git log --oneline
# a1b2c3d (HEAD) chore: add bisect test script
# b2c3d4e chore: release v1.0.0
# c3d4e5f feat(ui): add speaker cards grid layout
# d4e5f6a feat(schedule): add session filtering by track
# ...28 commits plus tôt...
```

Les sessions de l'agenda s'affichent en ordre anti-chronologique. Quelqu'un a cassé `getSortedSessions`. Lequel de ces 32 commits est le coupable ?

Vérifiez :

```bash
./bisect-test.sh; echo "Exit: $?"
# Exit: 1  ← le bug est là
```

## La recherche binaire appliquée à Git

`git bisect` utilise une **recherche dichotomique** sur votre historique :

```
32 commits à tester → log₂(32) = 5 → 5 étapes maximum
```

```
[1 ─────────────── 16 ─────────────── 32]
                   ↑ bad
[1 ──────── 8 ──── 16]
            ↑ good
[8 ──── 12 ─── 16]
        ↑ bad
[8 ──── 10 ─── 12]
        ↑ good
[10 ─ 11 ─ 12]
      ↑ bad → commit 11 est le premier mauvais !
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
