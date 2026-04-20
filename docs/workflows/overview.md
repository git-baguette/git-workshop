---
sidebar_position: 1
---

# Workflows Git — Lequel choisir ?

:::info À savoir
Ce module est une vue d'ensemble comparative. Les pages suivantes détaillent chaque workflow pour approfondir après le workshop.
:::

## Le vrai problème des workflows

Ce n'est pas technique. C'est organisationnel.

Git ne vous impose aucune façon de travailler. C'est une force — et une source de chaos quand toute l'équipe a une vision différente de "comment on travaille".

Un bon workflow répond à 4 questions :

1. **Comment les features arrivent-elles en prod ?**
2. **Comment gère-t-on les hotfixes ?**
3. **Comment les branches sont-elles nommées et supprimées ?**
4. **Quand est-ce qu'on rebase vs qu'on merge ?**

## Les trois grandes familles

| Workflow | Pour qui | Rythme de déploiement | Complexité |
|----------|----------|----------------------|------------|
| **Gitflow** | Équipes avec releases planifiées | Hebdomadaire / mensuel | Élevée |
| **GitHub Flow** | Équipes agiles, CI/CD | Pluriquotidien | Faible |
| **Trunk-Based** | Organisations tech matures | Continu | Faible (mais forte discipline) |

Il n'y a pas de meilleur workflow universel. Il y a celui qui correspond à **votre rythme de déploiement** et **la maturité de votre CI/CD**.

:::tip La règle d'or
Plus votre pipeline CI/CD est rapide et fiable, plus vous pouvez aller vers Trunk-Based. Plus vos releases sont rigides et planifiées, plus Gitflow a du sens.
:::
