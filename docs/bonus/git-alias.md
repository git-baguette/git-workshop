---
sidebar_position: 3
---

# git alias — Gagner du temps sur les commandes du quotidien

## `git new-mr` : Créer une MR/PR

## `git update-main` : Rebase de votre branche de feature les yeux fermé

## `git bisect-show-bad` : afficher le commit cassant

`git show $(git bisect log | grep "# bad" | tail -1 | awk '{print $3}' | tr -d '[]')`
