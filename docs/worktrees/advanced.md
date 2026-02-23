---
sidebar_position: 3
---

# Worktrees — Patterns avancés

## Le combo ultime : bare repo + worktrees

Au lieu de cloner normalement, clonez en bare et utilisez uniquement des worktrees comme répertoires de travail. C'est le setup préféré des développeurs qui travaillent sur plusieurs branches en permanence.

```bash
# Cloner le repo en bare (pas de working tree)
git clone --bare https://github.com/monorg/todocraft.git todocraft.git
cd todocraft.git

# Créer des worktrees pour les branches dont vous avez besoin
git worktree add ../todocraft-main main
git worktree add ../todocraft-staging staging
git worktree add ../todocraft-feature feature/dark-mode
```

```
todocraft.git/          ← tous les objets (partagés, légers)
todocraft-main/         ← working tree sur main
todocraft-staging/      ← working tree sur staging
todocraft-feature/      ← working tree sur feature/dark-mode
```

**Avantages vs clone classique :**
- Un seul `.git/objects` partagé — économie de disque
- `git fetch` une seule fois, disponible partout
- Impossible d'être "sur la mauvaise branche" par accident

## Règles et contraintes à connaître

:::warning Contrainte principale
**Une branche ne peut être checkoutée que dans un seul worktree à la fois.** Tenter de checkout la même branche dans deux worktrees différents échoue avec une erreur claire.

```bash
git worktree add ../autre-dossier feature/dark-mode
# fatal: 'feature/dark-mode' is already checked out at '../todocraft'
```

C'est une protection intentionnelle — deux index sur la même branche créerait des conflits impossibles à résoudre.
:::

| Contrainte | Comportement |
|-----------|-------------|
| Même branche dans deux worktrees | Interdit (erreur claire) |
| Submodules | Non initialisés automatiquement dans les nouveaux worktrees |
| Hooks | Partagés (définis dans `.git/hooks`, s'appliquent à tous) |
| Sparse checkout | Indépendant par worktree |
| `git stash` | Partagé entre tous les worktrees |

## Alias pratique

Ajoutez ceci dans votre `.zshrc` / `.bashrc` :

```bash
# wt <branche> — ouvre une branche dans un nouveau worktree
wt() {
  local branch="${1:?Branche requise}"
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Pas un repo Git"; return 1; }
  local name
  name=$(basename "$root")
  local dest="${root}/../${name}-${branch//\//-}"

  if git worktree list | grep -q "$dest"; then
    echo "Le worktree existe déjà : $dest"
    return 1
  fi

  git worktree add "$dest" "$branch" && echo "Worktree créé : $dest"
}
```

Utilisation :

```bash
wt feature/payments
# Crée ../todocraft-feature-payments sur feature/payments
```

## Tests en parallèle sur plusieurs branches

```bash
# Lancer les tests sur deux branches simultanément
git worktree add /tmp/test-branch-a feature/auth
git worktree add /tmp/test-branch-b feature/payments

(cd /tmp/test-branch-a && npm test > /tmp/test-a.log 2>&1) &
(cd /tmp/test-branch-b && npm test > /tmp/test-b.log 2>&1) &
wait

echo "=== Résultats branch-a ===" && tail -5 /tmp/test-a.log
echo "=== Résultats branch-b ===" && tail -5 /tmp/test-b.log
```

Vos deux suites de tests tournent en parallèle pendant que vous continuez à travailler dans votre worktree principal.

## Inspecter les internals

```bash
# Le dossier .git/worktrees stocke la référence de chaque worktree lié
ls .git/worktrees/

# Pour chaque worktree lié :
cat .git/worktrees/todocraft-hotfix/gitdir
# /home/user/git-workshop/todocraft-hotfix/.git
# (fichier dans le working tree qui pointe vers ici)

cat .git/worktrees/todocraft-hotfix/HEAD
# ref: refs/heads/fix/login-prod

cat .git/worktrees/todocraft-hotfix/locked 2>/dev/null
# Présent si le worktree est verrouillé (ex: sur un disque réseau)
```

## `git switch` et worktrees (Git 2.23+)

`git switch` est le remplaçant moderne de `git checkout` pour changer de branche. Il respecte aussi les worktrees :

```bash
git switch feature/dark-mode
# fatal: 'feature/dark-mode' is already checked out at '../todocraft'
# Protection automatique — pas de corruption possible
```
