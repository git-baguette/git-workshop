---
sidebar_position: 2
---

# Gitflow

## Concept

Gitflow a été formalisé par Vincent Driessen en 2010. Il définit des rôles précis pour chaque branche et une procédure stricte pour les releases et hotfixes.

## Structure des branches

```
main          ──●────────────────────────────●──────────── (tags v1.0, v1.1)
                │                            │
hotfix/login   ─┼──●──●──────────────────────┤
                │                            │
develop       ──●────────────────────────────●──────────── (intégration continue)
                │         │        │
feature/A      ─┼──●──●───┤        │
                           │        │
feature/B                  ●──●─────┤
                                    │
release/1.1                         ●──●────────────────── (freeze, bug fixes only)
```

## Les 5 types de branches

| Branche     | Durée de vie | Créée depuis | Mergée dans        |
| ----------- | ------------ | ------------ | ------------------ |
| `main`      | Permanente   | —            | —                  |
| `develop`   | Permanente   | `main`       | —                  |
| `feature/*` | Temporaire   | `develop`    | `develop`          |
| `release/*` | Temporaire   | `develop`    | `main` + `develop` |
| `hotfix/*`  | Temporaire   | `main`       | `main` + `develop` |

## Exemple complet avec NG Baguette Conf

### Initialisation

```bash
cd ~/git-workshop/ng-baguette-conf
git switch main

# develop est la branche d'intégration
git switch -C develop
```

### Développer une feature

```bash
# Toujours depuis develop
git switch -C feature/dark-mode develop

# ... travail ...
git commit -m "feat(theme): add theme system"
git commit -m "feat(ui): apply dark mode to task list"

# Merger dans develop (jamais dans main directement)
git switch develop
git merge --no-ff feature/dark-mode -m "merge: feature/dark-mode"
git branch -d feature/dark-mode
```

:::tip `--no-ff` : merge commit obligatoire
Gitflow utilise systématiquement `--no-ff` pour créer un merge commit, même quand un fast-forward est possible. Cela préserve l'historique des features comme blocs distincts.
:::

### Préparer une release

```bash
# Créer la branche release depuis develop
git switch -C release/1.1.0 develop

# Sur la branche release : bug fixes UNIQUEMENT, pas de nouvelles features
echo "1.1.0" > VERSION
git commit -m "chore: bump version to 1.1.0"

# Bug trouvé en QA
git commit -m "fix(export): handle empty task list in CSV"

# Merger dans main ET dans develop
git switch main
git merge --no-ff release/1.1.0 -m "release: v1.1.0"
git tag -a v1.1.0 -m "Version 1.1.0"

git switch develop
git merge --no-ff release/1.1.0 -m "merge: back-merge release/1.1.0 into develop"

git branch -d release/1.1.0
```

### Hotfix en production

```bash
# Bug critique sur main (= prod)
git switch -C hotfix/login-crash main

git commit -m "fix(auth): prevent crash on empty email"

# Merger dans main ET dans develop
git switch main
git merge --no-ff hotfix/login-crash -m "hotfix: login crash"
git tag -a v1.0.1 -m "Version 1.0.1"

git switch develop
git merge --no-ff hotfix/login-crash -m "merge: hotfix/login-crash into develop"

git branch -d hotfix/login-crash
```

## Avantages et inconvénients

### ✅ Avantages

- Très lisible pour les équipes avec des releases planifiées
- Isolation claire entre features, releases et hotfixes
- Adapté aux apps avec plusieurs versions en prod simultanément

### ❌ Inconvénients

- Lourd à maintenir (beaucoup de merges, beaucoup de branches)
- `develop` peut dériver loin de `main`
- Décourage le déploiement continu
- Mauvais pour les équipes qui déploient plusieurs fois par jour

## Gitflow en 2024

Gitflow est souvent perçu comme **trop complexe pour la plupart des équipes modernes**. Vincent Driessen lui-même a ajouté une note à son article original :

> _"If your team is doing continuous delivery of software, I would suggest to adopt a much simpler workflow (like GitHub Flow) instead of trying to shoehorn git-flow into your team."_

Utilisez Gitflow si vous :

- Maintenez plusieurs versions majeures en parallèle
- Avez des cycles de release longs (hebdomadaires minimum)
- Avez une QA gate formelle avant chaque release
