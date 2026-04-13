---
sidebar_position: 10
---

# Rebase vs Merge — Choisir au bon moment

## Les deux histoires du même projet

Imaginez que vous travaillez sur `feature/dark-mode`. Pendant ce temps, deux commits sont arrivés sur `main` (un fix de login et une nouvelle feature de cache).

Voici ce que donnent les deux approches :

### Avec merge

```bash
git switch feature/dark-mode
git merge main
```

```
main:     A──B──fix──cache
                          \
feature:  A──B──D──E──────M   (M = merge commit)
```

`git log --graph --oneline` :
```
*   abc123 Merge branch 'main' into feature/dark-mode
|\
| * def456 feat(cache): add memoize utility
| * efg789 fix(auth): add email validation
* | hij012 feat(ui): add dark mode toggle
* | klm345 feat(theme): add theme system
|/
* nop678 feat(utils): add sortByPriority
```

**→ L'historique est fidèle mais difficile à lire.**

### Avec rebase

```bash
git switch feature/dark-mode
git rebase main
```

```
main:     A──B──fix──cache
                          \
feature:                   D'──E'   (nouveaux SHA)
```

`git log --oneline` :
```
e5f6a7b feat(ui): add dark mode toggle
d4e5f6a feat(theme): add theme system
def456  feat(cache): add memoize utility
efg789  fix(auth): add email validation
nop678  feat(utils): add sortByPriority
```

**→ Historique linéaire, comme si la feature avait été développée sur la version la plus récente.**

## TP — Mettre à jour une feature branch avec rebase

```bash
cd ~/git-baguette/git-workshop-starter
git switch feature/speaker-search

# Vérifier la divergence avec main
git log --oneline feature/export-csv ^main
# 1 commit en avance

git log --oneline main ^feature/export-csv
# Tous les commits de main (la feature est basée sur un ancien état)

# Rebaser sur main
git rebase main

# Résoudre les éventuels conflits, puis :
git rebase --continue

# Vérifier le résultat
git log --oneline -5
# Vos commits de feature apparaissent EN DERNIER (les plus récents)
# après tous les commits de main
```

## TP — Gérer un conflit de rebase

Les conflits en rebase se gèrent comme en merge, mais **un commit à la fois** :

```bash
# Simuler un conflit
git switch main
echo "// version main" >> src/utils/sort.js
git add . && git commit -m "refactor(sort): add main comment"

git switch feature/export-csv
echo "// version feature" >> src/utils/sort.js
git add . && git commit -m "refactor(sort): add feature comment"

# Rebaser (va créer un conflit)
git rebase main
```

Git s'arrête sur le commit conflictuel :

```
CONFLICT (content): Merge conflict in src/utils/sort.js
error: could not apply abc123... refactor(sort): add feature comment
```

Résolvez le conflit :

```bash
# Voir les fichiers en conflit
git status

# Éditer le fichier pour résoudre
# Choisir ou combiner les deux versions

# Stager la résolution
git add src/utils/sort.js

# Continuer le rebase
git rebase --continue
# Git vous demandera peut-être de valider/modifier le message
```

Si vous vous perdez, **annulez tout** et recommencez :

```bash
git rebase --abort
# Revient à l'état exact avant git rebase
```

## `--force-with-lease` : pousser après rebase

Après un rebase, les SHA ont changé. Un `git push` normal sera rejeté si la branche a déjà été pushée. Vous devez forcer :

```bash
# ❌ Dangereux : écrase tout ce que quelqu'un aurait pushé entre temps
git push --force

# ✅ Sûr : refuse si quelqu'un a pushé depuis votre dernier pull
git push --force-with-lease
```

`--force-with-lease` vérifie que votre référence remote locale correspond à l'état réel du serveur. Si quelqu'un d'autre a pushé, le push échoue avec un message clair.

## Stratégie recommandée

```
┌─────────────────────────────────────────────────────┐
│  Branche locale, non encore pushée ?                │
│  → git rebase main librement                        │
├─────────────────────────────────────────────────────┤
│  Branche pushée, mais personne d'autre ne l'utilise │
│  → git rebase main + git push --force-with-lease    │
├─────────────────────────────────────────────────────┤
│  Branche partagée (main, develop, staging...)       │
│  → JAMAIS de rebase. Utilisez git merge.            │
└─────────────────────────────────────────────────────┘
```

## Checklist avant un rebase

```bash
# 1. Sauvegarder sa position actuelle (par précaution)
git log --oneline -1
# Notez le hash — vous pouvez toujours revenir ici avec git reset --hard

# 2. Vérifier que personne n'a basé son travail sur votre branche
git log origin/feature/dark-mode..feature/dark-mode  # commits locaux non pushés

# 3. Lancer le rebase
git rebase main

# 4. En cas de problème, utiliser le reflog pour revenir en arrière
git reflog
git reset --hard HEAD@{N}
```

## Challenge — Rebase + bisect

Après avoir trouvé le bug avec bisect (module précédent), nettoyez l'historique de `main` pour que la correction soit propre :

1. Créez une branche `fix/sort-priority` depuis le commit juste **avant** le bug
2. Appliquez la correction dans `src/utils/sort.js` (`high: 0`)
3. Rebaser `fix/sort-priority` sur `main`
4. Faire un fast-forward merge dans `main`
5. Vérifier avec `node tests/sort.test.js` que les tests passent

```bash
# Hint : trouver le hash du commit juste avant le bug
git log --oneline | grep "update priority constants"
# abc123 refactor(sort): update priority constants

git switch -C fix/sort-priority abc123^
# (le ^ remonte d'un commit)
```
