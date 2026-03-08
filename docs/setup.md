---
sidebar_position: 2
---

# Setup — Préparer le projet NG Baguette Conf

:::info Durée : 5 minutes
Faites ceci avant tout autre module. Tous les TPs s'appuient sur ce projet.
:::

## Ce que le repo contient

- Un site de conférence **Astro + Tailwind/DaisyUI** avec ~32 commits d'historique réaliste
- Un **bug planté au commit 21** dans `src/utils/schedule.ts` (vous le trouverez avec bisect)
- Deux **branches en cours** : `feature/responsive-nav`, `feature/speaker-search`
- Une **branche supprimée** `feature/cfp-form` à retrouver avec reflog
- Un **script de test** pour bisect automatisé

## Cloner le repo

```bash
mkdir -p ~/git-workshop && cd ~/git-workshop
git clone https://github.com/yatho/git-workshop-starter.git ng-baguette-conf
cd ng-baguette-conf
git fetch origin feature/responsive-nav:feature/responsive-nav
git fetch origin feature/speaker-search:feature/speaker-search
```

## Vérifier le setup

```bash
# Nombre de commits
git log --oneline | wc -l
# ~32

# Branches disponibles
git branch
# * main
#   feature/responsive-nav
#   feature/speaker-search

# Le bug est bien là (doit afficher Exit: 1)
./bisect-test.sh; echo "Exit: $?"
```

## Option alternative — Script de setup local

Si vous ne pouvez pas cloner le repo, vous pouvez recréer l'historique depuis zéro :

```bash
bash /path/to/git-workshop-starter/scripts/setup-workshop.sh
cd ~/git-workshop/ng-baguette-conf
```

Le script tourne en moins de 30 secondes et crée exactement le même historique.

## Aide-mémoire du projet

| Élément                  | Emplacement                  | Rôle dans le workshop |
| ------------------------ | ---------------------------- | --------------------- |
| `src/utils/schedule.ts`  | Fichier avec le bug          | Module Bisect         |
| `bisect-test.sh`         | Script bisect automatisé     | Module Bisect         |
| `feature/responsive-nav` | Branche en cours (WIP)       | Module Worktrees      |
| `feature/speaker-search` | Branche complète             | Module Worktrees      |
| `feature/cfp-form`       | **Supprimée** — à retrouver  | Module Reflog         |
| Commit 21                | Bug dans `getSortedSessions` | Module Bisect         |
