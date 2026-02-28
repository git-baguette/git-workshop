---
sidebar_position: 2
---

# git init — Les options que personne ne connaît

## `--bare` : les dépôts sans working tree

Un **dépôt bare** contient uniquement les internals Git (contenu du `.git/`) sans répertoire de travail. C'est la cible des push, pas un endroit pour travailler.

```bash
# Créer un dépôt bare (suffixe .git par convention)
git init --bare ~/serveur/ng-baguette-conf.git

# Cloner depuis le bare
git clone ~/serveur/ng-baguette-conf.git ~/ng-baguette-dev

# Push vers le bare
cd ~/ng-baguette-dev
git push origin main
```

**Quand l'utiliser :** serveur Git maison, partage sur un disque réseau, "origin" local pour tester des workflows.

:::tip Pourquoi ne pas pusher vers un repo non-bare ?
Git refuse de mettre à jour une branche checkoutée. Résultat : `error: refusing to update checked out branch`. Le bare repo n'a pas de working tree, donc pas de branche checkoutée. Le push fonctionne toujours.
:::

## `--template` : hooks pré-installés sur chaque nouveau dépôt

```bash
# Créer un template avec un hook commit-msg
mkdir -p ~/team-template/hooks
cat > ~/team-template/hooks/commit-msg << 'HOOK'
#!/bin/sh
MSG=$(cat "$1")
PATTERN="^(feat|fix|docs|refactor|test|chore|ci|perf)(\(.+\))?: .+"
if ! echo "$MSG" | grep -qE "$PATTERN"; then
  echo "❌ Conventional Commits requis : <type>(<scope>): <desc>"
  exit 1
fi
HOOK
chmod +x ~/team-template/hooks/commit-msg

# Configurer globalement
git config --global init.templateDir ~/team-template

# Maintenant CHAQUE git init installe le hook automatiquement
git init nouveau-projet
ls nouveau-projet/.git/hooks/commit-msg  # présent !
```

## `--separate-git-dir` : .git ailleurs sur le disque

```bash
# Le .git est stocké dans ~/dotfiles.git
# Le working tree est ~/
git init --separate-git-dir ~/.dotfiles.git ~/

# ~/. git est un FICHIER (pas un dossier) qui pointe vers ~/.dotfiles.git
cat ~/.git
# gitdir: /home/user/.dotfiles.git

# Utilisation classique : versionner ses dotfiles sans mettre .git dans ~
echo "*" > ~/.gitignore
echo "!.zshrc" >> ~/.gitignore
echo "!.vimrc" >> ~/.gitignore
git -C ~ add .zshrc .vimrc
git -C ~ commit -m "feat: initial dotfiles"
```

## `--initial-branch` : choisir le nom de la branche par défaut

```bash
# Créer un repo sur main directement
git init -b main mon-projet

# Configurer globalement (une fois pour toutes)
git config --global init.defaultBranch main
```

## `--shared` : permissions multi-utilisateurs sur un serveur

```bash
# Plusieurs développeurs Unix peuvent pousser vers ce bare repo
git init --bare --shared=group /srv/git/ng-baguette-conf.git

# Vérifier les permissions
ls -la /srv/git/ng-baguette-conf.git
# drwxrwsr-x (sticky bit de groupe)
```

## Cheat sheet

```bash
git init --bare repo.git                           # cible de push
git init --template=/chemin/template mon-repo      # hooks pré-installés
git init --separate-git-dir /autre/chemin mon-repo # .git ailleurs
git init -b main mon-repo                          # branche initiale
git init --bare --shared=group --initial-branch=main equipe.git  # tout à la fois
```
