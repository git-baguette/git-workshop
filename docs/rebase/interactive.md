---
sidebar_position: 2
---

# Rebase interactif — Réécrire l'histoire

Le rebase interactif (`git rebase -i`) est l'outil le plus puissant pour **nettoyer un historique** avant de pousser. Il vous permet de modifier, fusionner, réordonner et supprimer des commits comme si vous réécriviez le scénario d'un film.

## Les actions disponibles

Quand vous lancez `git rebase -i`, Git ouvre un éditeur avec une liste de commits et des actions :

```
pick a1b2c3 feat(theme): add theme system
pick b2c3d4 fix typo in theme.js
pick c3d4e5 feat(ui): add dark mode toggle
pick d4e5f6 WIP: broken, dont merge
pick e5f6a7 fix: actually make dark mode work
```

| Commande | Alias | Effet |
|----------|-------|-------|
| `pick` | `p` | Garder le commit tel quel |
| `reword` | `r` | Garder le commit, modifier le message |
| `edit` | `e` | S'arrêter pour modifier le contenu du commit |
| `squash` | `s` | Fusionner avec le commit précédent, combiner les messages |
| `fixup` | `f` | Fusionner avec le commit précédent, **garder seulement le message précédent** |
| `drop` | `d` | Supprimer le commit |
| (réordonner les lignes) | | Réordonner les commits |

## TP — Nettoyer l'historique de feature/dark-mode

### Situation de départ

La branche `feature/dark-mode` ressemble à ça dans la vraie vie :

```bash
cd ~/git-workshop/todocraft
git checkout feature/dark-mode

# Simuler un historique de feature "honnête"
git log --oneline feature/dark-mode ^main
# e.g.:
# a1b2c3 feat(ui): add dark mode toggle button component
```

Ajoutons l'historique réaliste d'une vraie session de travail :

```bash
# La suite du travail en cours (commitée rapidement)
cat >> src/ui/darkmode.js << 'EOF'

export function preloadTheme() {
  const theme = localStorage.getItem("todocraft-theme") ?? "light";
  document.documentElement.dataset.theme = theme;
}
EOF
git add . && git commit -m "preload theme"

# Oops, typo dans le message précédent, et on oublie un fichier
echo "/* dark mode transitions */" > src/ui/transitions.css
git add . && git commit -m "add transitions css"

# Fix d'un bug découvert en testant
sed -i '' 's/dataset.theme/setAttribute("data-theme",/' src/ui/darkmode.js 2>/dev/null || \
sed -i 's/dataset.theme/setAttribute("data-theme",/' src/ui/darkmode.js
git add . && git commit -m "fix bug"

# Encore un oubli
echo "@keyframes theme-transition { from { opacity: 0.8; } to { opacity: 1; } }" >> src/ui/transitions.css
git add . && git commit -m "wip"

# Finalisation
git commit --allow-empty -m "done I think"
```

L'historique est maintenant honteux :

```bash
git log --oneline feature/dark-mode ^main
# 5f6a7b8 done I think
# 4e5f6a7 wip
# 3d4e5f6 fix bug
# 2c3d4e5 add transitions css
# 1b2c3d4 preload theme
# a9b0c1d feat(ui): add dark mode toggle button component
```

### Nettoyer avec rebase -i

```bash
# Ouvrir le rebase interactif sur tous les commits depuis main
git rebase -i main
```

L'éditeur s'ouvre avec :

```
pick a9b0c1d feat(ui): add dark mode toggle button component
pick 1b2c3d4 preload theme
pick 2c3d4e5 add transitions css
pick 3d4e5f6 fix bug
pick 4e5f6a7 wip
pick 5f6a7b8 done I think
```

Modifiez-le pour obtenir :

```
reword a9b0c1d feat(ui): add dark mode toggle button component
fixup  1b2c3d4 preload theme
pick   2c3d4e5 add transitions css
fixup  3d4e5f6 fix bug
fixup  4e5f6a7 wip
fixup  5f6a7b8 done I think
```

Sauvegardez et quittez. Git vous demandera de reword le premier commit :

```
feat(ui): add dark mode toggle button component
```

Corrigez en :

```
feat(ui): add dark mode toggle with theme persistence
```

Et renommez le commit de `add transitions css` :

```
feat(ui): add smooth theme transition animation
```

### Résultat final

```bash
git log --oneline feature/dark-mode ^main
# b2c3d4e feat(ui): add smooth theme transition animation
# a9b0c1d feat(ui): add dark mode toggle with theme persistence
```

Six commits douteux → deux commits propres qui racontent une histoire claire.

## TP — Squash de commits WIP

Scénario fréquent : vous avez commité en cours de route avec des messages `wip`, `fix`, `oups`.

```bash
# Voir les 5 derniers commits sur main
git log --oneline -5
```

Fusionner les 3 derniers commits en un seul :

```bash
git rebase -i HEAD~3
```

Mettez tous sauf le premier en `fixup` :

```
pick   abc123 feat(cache): add memoize utility with TTL
fixup  def456 chore: update dependencies
fixup  ghi789 chore: release v1.0.0
```

:::tip `fixup` vs `squash`
- `fixup` : garde le message du commit au-dessus, jette le reste
- `squash` : vous demande de combiner les messages → ouvre l'éditeur
:::

## TP — Supprimer un commit

Vous avez commité des credentials ou du code qu'il ne fallait pas :

```bash
# Voir l'historique
git log --oneline -5

# Supprimer le commit coupable avec drop
git rebase -i HEAD~N
# Changez "pick" en "drop" sur la ligne concernée
```

:::warning Attention
Si le commit à supprimer modifie des fichiers que des commits suivants utilisent, `drop` créera des conflits. Résolvez-les normalement avec `git rebase --continue`.
:::

## TP — Réordonner des commits

Parfois vous voulez changer l'ordre pour grouper des changements logiquement :

```bash
git rebase -i HEAD~4
```

```
# Avant :
pick a feat(ui): add export button
pick b feat(auth): add OAuth
pick c fix(ui): fix export button color
pick d test(auth): add OAuth tests

# Après (réordonner + squash) :
pick a feat(ui): add export button
fixup c fix(ui): fix export button color
pick b feat(auth): add OAuth
fixup d test(auth): add OAuth tests
```

## `--autosquash` : le raccourci magique

Si vous commitez avec le préfixe `fixup!` ou `squash!` suivi du message de la cible, Git prépare le rebase automatiquement :

```bash
# Commit normal
git commit -m "feat(cache): add memoize utility"

# Plus tard, fix à fusionner avec ce commit
git commit -m "fixup! feat(cache): add memoize utility"

# Rebase avec autosquash
git rebase -i --autosquash main
# Git place automatiquement le fixup au bon endroit !
```

Combiner avec un alias :

```bash
git config --global alias.fixup 'commit --fixup'
git fixup HEAD~2  # crée un commit fixup! pour HEAD~2
```

## `git commit --amend` — cas simple

Pour modifier uniquement le dernier commit (avant de pusher) :

```bash
# Modifier le message du dernier commit
git commit --amend -m "feat(ui): correct message"

# Ajouter un fichier oublié au dernier commit
git add fichier-oublie.js
git commit --amend --no-edit  # garde le même message
```

:::warning
`--amend` réécrit le commit (nouveau SHA). Ne jamais amender un commit déjà pushé sur une branche partagée.
:::
