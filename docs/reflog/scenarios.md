---
sidebar_position: 3
---

# Autres cas d'usage du reflog

## Retrouver quand un bug a été introduit (avant bisect)

Le reflog peut vous aider à réduire la fenêtre de recherche avant même de lancer `git bisect` :

```bash
# "Le bug est apparu il y a environ 2 jours"
git reflog --since="2 days ago"

# "Ça marchait encore hier matin"
git reflog --before="yesterday" --after="2 days ago"
```

Vous trouvez le commit suspect, vous le testez, et vous avez votre coupable sans bisect.

## Voir ce que vous avez fait (audit personnel)

```bash
# Journal des 20 dernières opérations sur HEAD
git reflog -20

# Avec les timestamps
git reflog --format="%C(yellow)%h%Creset %C(blue)%gd%Creset %C(white)(%cr)%Creset %gs"
```

Pratique pour reconstituer votre propre historique quand vous avez une réunion dans 5 minutes et que vous ne savez plus ce que vous avez fait.

## Annuler un `git commit --amend`

Vous avez amendé le mauvais commit, ou vous avez écrasé un message important. Le reflog vous sauve :

```bash
git commit --amend -m "mauvais message"  # oups

git reflog
# HEAD@{0}: commit (amend): mauvais message
# HEAD@{1}: commit: le bon message original  ← c'est ici

git reset --soft HEAD@{1}
# Revient au commit original, avec vos changements stagés
git commit -m "le bon message original"
```

## Comparer deux états du reflog

```bash
# Voir ce qui a changé entre maintenant et il y a 5 opérations
git diff HEAD@{0} HEAD@{5}

# Statistiques seulement
git diff --stat HEAD@{0} HEAD@{5}
```

## Récupérer après un `git clean -fd` ?

:::warning Attention
`git clean -fd` supprime les fichiers non-trackés. Le reflog ne sauve **pas** ces fichiers — Git ne les a jamais connus. Seuls les fichiers commités sont récupérables.

Avant tout `git clean`, faites toujours un `git clean -nd` (dry run) pour voir ce qui sera supprimé.
:::

## Récapitulatif des commandes

```bash
# Voir le reflog de HEAD
git reflog
git reflog show HEAD  # équivalent

# Reflog d'une branche
git reflog show ma-branche

# Avec dates relatives
git reflog --relative-date

# Récupérer un commit perdu
git reset --hard HEAD@{N}          # reset dur
git reset --soft HEAD@{N}          # garde les changements stagés
git switch -C nouvelle-branche HEAD@{N}  # sur une nouvelle branche
git cherry-pick HEAD@{N}           # applique UN commit

# Chercher dans le reflog
git reflog --since="2 days ago"
git reflog --grep-reflog="rebase"  # filtrer par type d'opération
```
