---
sidebar_position: 3
---

# git alias — Gagner du temps sur les commandes du quotidien

Les alias Git permettent de créer des raccourcis pour les commandes fréquemment utilisées. Au lieu de taper `git status`, vous pouvez simplement écrire `git st`. Cela rend votre workflow plus efficace et personnalisé.

## Alias simples : raccourcir les commandes courantes

Pour créer un alias, utilisez `git config --global alias.<nom> "<commande>"`. Voici quelques exemples classiques :

```bash
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
```

Maintenant, `git st` équivaut à `git status`. Vous pouvez créer des alias pour toutes les commandes que vous utilisez souvent.

### Alias utiles pour le quotidien

- `unstage` : pour désindexer un fichier (équivalent à `reset HEAD --`)

```bash
git config --global alias.unstage 'reset HEAD --'
```

- `last` : afficher le dernier commit

```bash
git config --global alias.last 'log -1 HEAD'
```

## Définir les alias dans le fichier `.gitconfig`

Au lieu d'utiliser `git config` à chaque fois, vous pouvez éditer directement votre fichier `~/.gitconfig` :

```ini
[alias]
    co = checkout
    br = branch
    ci = commit
    st = status
    unstage = reset HEAD --
    last = log -1 HEAD
```

## Alias avancés : fonctions Bash personnalisées

Pour des commandes plus complexes, vous pouvez créer des alias qui exécutent des fonctions Bash. Commencez par `!` pour indiquer une commande externe.

Exemple simple (pour illustration) :

```ini
[alias]
    echo = "!f() { echo $1; }; f"
```

## Exemples pratiques pour les workflows Git

### `git new-mr` : Créer une merge request en une commande

Cet alias bascule sur `main`, pousse les changements locaux, crée une nouvelle branche, et initie une merge request sur GitLab.

```ini
[alias]
    new-mr = "!f() { git switch main && git push -r --autostash && git switch -c \"$1\" && git push -u origin \"$1\" -o merge_request.create -o merge_request.draft -o merge_request.title=\"${2:-${1}}\"; }; f"
```

Utilisation : `git new-mr ma-branche "Titre de la MR"`

Note : `${2:-${1}}` signifie "utiliser $2 si défini, sinon $1" (équivalent à `$2 ?? $1` en JavaScript).

Si vous n'utilisez pas GitLab, retirez les options `-o`.

### `git update-mr` : Rebase et pousser la branche courante

Met à jour la branche `main`, rebase la branche courante, et pousse sans écraser les commits distants.

```ini
[alias]
    update-mr = "!f() { git fetch --all && git rebase origin/main && git push --force-with-lease; }; f"
```

### `git bisect-show-bad` : Afficher le commit fautif après un bisect

```ini
[alias]
    bisect-show-bad = "!git show $(git bisect log | grep '# bad' | tail -1 | awk '{print $3}' | tr -d '[]')"
```

## Cheat sheet

```bash
# Alias simples
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'

# Alias avancés (ajoutez dans ~/.gitconfig)
[alias]
    new-mr = "!f() { git switch main && git push -r --autostash && git switch -c \"$1\" && git push -u origin \"$1\" -o merge_request.create -o merge_request.draft -o merge_request.title=\"${2:-${1}}\"; }; f"
    update-mr = "!f() { git fetch --all && git rebase origin/main && git push --force-with-lease; }; f"
    bisect-show-bad = "!git show $(git bisect log | grep '# bad' | tail -1 | awk '{print $3}' | tr -d '[]')"
```
