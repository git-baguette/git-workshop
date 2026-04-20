---
sidebar_position: 1
---

# Reflog — Le filet de sécurité que vous ne saviez pas avoir

:::info Durée : 30 minutes

- 5 min : concept
- 22 min : 3 scénarios de récupération
- 3 min : configuration et bonnes pratiques
  :::

## "J'ai tout cassé"

```bash
git reset --hard HEAD~3
# HEAD is now at a1b2c3d feat: add sortByDate helper
```

Silence. Sueurs froides. Trois commits de travail s'envolent.

**Sauf que non. Git ne supprime rien.**

## Ce qu'est vraiment le reflog

Le **reflog** (reference log) est un journal local de _toutes_ les modifications de HEAD et des branches. Chaque fois que HEAD bouge — checkout, commit, reset, rebase, merge, cherry-pick — Git l'enregistre.

```bash
git reflog
# d4e5f6a (HEAD -> main) HEAD@{0}: reset: moving to HEAD~3
# 7c8d9e0 HEAD@{1}: commit: feat(ui): add ExportMenu component
# 4b5c6d7 HEAD@{2}: commit: feat(ui): add dark mode toggle
# 1a2b3c4 HEAD@{3}: commit: fix(sort): restore priority order
# ...
```

Ce journal est **local uniquement** — il n'est pas pushé sur le remote. Et les entrées ont une durée de vie limitée :

| Type d'entrée                         | Durée de vie par défaut |
| ------------------------------------- | ----------------------- |
| Entrées normales                      | 90 jours                |
| Entrées orphelines (non atteignables) | 30 jours                |

Moralité : vous avez du temps, mais pas indéfiniment.

## Anatomie d'une entrée reflog

```
d4e5f6a HEAD@{0}: reset: moving to HEAD~3
│       │         └─ description de l'opération
│       └─ position dans le reflog (0 = la plus récente)
└─ hash du commit à ce moment
```

`HEAD@{N}` est une syntaxe de référence valide — vous pouvez l'utiliser directement dans toutes les commandes Git :

```bash
git show HEAD@{2}                    # voir le commit 2 étapes en arrière
git diff HEAD@{0} HEAD@{5}           # diff entre maintenant et 5 étapes avant
git switch -C rescue HEAD@{1}        # créer une branche depuis l'état précédent
git cherry-pick HEAD@{3}             # appliquer un commit "perdu"
git reset --hard HEAD@{N}            # revenir à un état précédent
```

## Ce que le reflog sauve

| Opération dangereuse                   | Récupérable ?                 |
| -------------------------------------- | ----------------------------- |
| `git reset --hard HEAD~N`              | ✅ Oui                        |
| `git branch -D ma-branche`             | ✅ Oui                        |
| `git commit --amend` (mauvais)         | ✅ Oui                        |
| `git rebase` catastrophique            | ✅ Oui                        |
| `git clean -fd` (fichiers non-trackés) | ❌ Non                        |
| `git stash drop`                       | ✅ Oui (via reflog des stash) |
