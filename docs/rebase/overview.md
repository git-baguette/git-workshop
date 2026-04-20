---
sidebar_position: 1
---

# Rebase — Enfin comprendre ce que ça fait

:::info À savoir
Ce module est souvent la révélation du workshop. Prenez le temps de bien assimiler le modèle mental avant de passer aux exercices.
:::

## "Git rebase" — le mythe

Beaucoup de développeurs utilisent `git rebase` sans vraiment comprendre ce qu'il se passe. Ils suivent les instructions, ça marche, mais si quelque chose déraille, ils sont perdus.

Ce module démystifie rebase une fois pour toutes.

## Ce que fait rebase, vraiment

`git rebase` **rejoue vos commits sur une nouvelle base**.

```
Avant rebase :
           A──B──C  (main)
                  \
                   D──E──F  (feature/dark-mode)

Après git rebase main (depuis feature/dark-mode) :
           A──B──C  (main)
                  \
                   D'──E'──F'  (feature/dark-mode)
```

Les commits `D'`, `E'`, `F'` sont de **nouveaux commits** avec de nouveaux SHA. Ils contiennent les mêmes modifications que `D`, `E`, `F`, mais appliquées sur `C` au lieu de `B`.

:::warning L'idée clé
Rebase **réécrit l'historique**. Les anciens commits (`D`, `E`, `F`) deviennent orphelins. C'est pourquoi on ne rebase **jamais** une branche partagée sur laquelle d'autres ont pushé.
:::

## Merge vs Rebase — le choix fondamental

```
Merge :
           A──B──C──M  (main, avec merge commit M)
                  ↑ ↑
              D──E──F  (feature)

→ Préserve l'historique exact, mais crée un historique non-linéaire

Rebase :
           A──B──C──D'──E'──F'  (main, après fast-forward)

→ Historique linéaire, mais les SHA ont changé
```

| | Merge | Rebase |
|---|-------|--------|
| Historique | Non-linéaire (fidèle) | Linéaire (réécrit) |
| SHA des commits | Inchangés | Nouveaux SHA |
| Sûr sur branche partagée | ✅ Oui | ❌ Non |
| Lisibilité de `git log` | Moyen | Excellent |
| Reversibilité | `git revert M` | Plus complexe |

## La règle d'or du rebase

> **Ne jamais rebaser une branche sur laquelle quelqu'un d'autre a basé son travail.**

En pratique :
- ✅ Rebaser votre branche feature **locale** sur `main`
- ✅ Rebaser en interactif avant de pousser votre branche
- ❌ Rebaser `main` ou une branche partagée avec `--force`
- ❌ `git push --force` sur une branche que d'autres ont checkoutée

## Les commandes

```bash
# Rebase la branche courante sur main
git rebase main

# Rebase interactif : modifier les N derniers commits
git rebase -i HEAD~N
git rebase -i HEAD~3   # modifier les 3 derniers commits

# Rebase interactif depuis un commit précis
git rebase -i <hash>^  # le ^ inclut ce commit

# En cas de conflit pendant un rebase
git rebase --continue  # après avoir résolu
git rebase --skip      # ignorer ce commit
git rebase --abort     # tout annuler, retour à l'état initial

# Après un rebase, pousser (force nécessaire si déjà pushé)
git push --force-with-lease  # plus sûr que --force
```
