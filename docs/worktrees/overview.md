---
sidebar_position: 1
---

# Worktrees — 3 features en même temps sans devenir fou

## Le scénario classique du vendredi

Il est 14h. Vous êtes sur `feature/dark-mode`, vous avez 8 fichiers modifiés en cours. Votre manager arrive en courant :

> _"Le login est cassé en prod. Fix urgent."_

Vos options actuelles :

| Solution              | Pourquoi c'est nul                                                                                                      |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `git stash`           | Perd l'état de votre éditeur, oublie les fichiers non-trackés, vous oublierez ce stash dans 3 jours                     |
| Commit WIP            | `git commit -m "WIP ne pas merger"` pollue l'historique et vous fait passer pour quelqu'un qui ne sait pas utiliser Git |
| `git clone` à nouveau | Vous re-téléchargez tout, vous réinstallez les `node_modules` — 10 minutes perdues pour un fix de 2 lignes              |

## La vraie solution : `git worktree`

Un **worktree** est un répertoire de travail supplémentaire lié à votre dépôt. Chaque worktree a sa propre branche et son propre index, mais ils **partagent tous la même base d'objets Git** (commits, blobs, trees).

Pas de duplication. Pas de re-téléchargement.

```
$WORKSHOP_DIR/ng-baguette-conf/.git/    ← tous les objets Git (partagés)
$WORKSHOP_DIR/ng-baguette-conf/         ← worktree principal (feature/dark-mode)
$WORKSHOP_DIR/ng-baguette-hotfix/       ← worktree lié    (fix/login-prod)
$WORKSHOP_DIR/ng-baguette-export/       ← worktree lié    (feature/export-csv)
```

Trois branches, trois terminaux, zéro stash.

## Les commandes essentielles

```bash
# Ajouter un worktree sur une branche existante
git worktree add <chemin> <branche>

# Ajouter un worktree ET créer une nouvelle branche
git worktree add -b <nouvelle-branche> <chemin> [<point-de-départ>]

# Lister tous les worktrees
git worktree list

# Supprimer un worktree
git worktree remove <chemin>

# Nettoyer les références orphelines
git worktree prune
```
