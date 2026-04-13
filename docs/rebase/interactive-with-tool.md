---
sidebar_position: 3
---

# Rebase interactif avec un outil — Réécrire l'histoire avec moins d'effort

Comme on l'a vu dans la partie précédente, `git rebase -i` est super puissant ! Mais manipuler le plan de rebase peut prendre un peu de temps. Heureusement, git est très extensible, donc on peut ajouter un outil pour faciliter les rebase interactif !

## Installer `git-interactive-rebase-tool`

- Documentation pour l'installation : https://github.com/MitMaro/git-interactive-rebase-tool/blob/master/readme/install.md
- Documentation pour la configuration : https://github.com/MitMaro/git-interactive-rebase-tool?tab=readme-ov-file#setup

Dans notre cas :

```Bash
git config --global sequence.editor interactive-rebase-tool
```

:::warning
TODO: penser à inclure git-interactive-rebase-tool dans le codespace
:::

## TP — Une autre branche bourrée de commits intermédiaires

### Situation de départ

Imaginons que vous travailliez sur un nouveau composant de recherche. La branche `feature/search-bar` contient déjà un premier commit :

```bash
cd ~/git-baguette/git-workshop-starter
git switch feature/search-bar

# historique initial
git log --oneline feature/search-bar ^main
# e.g.:
# b3c4d5e feat(search): add basic search bar component
```

Nous allons jouer la suite de la session de développement avec plusieurs aller-retours et oublis.

```bash
# implémentation rapide du style
cat >> src/components/SearchBar.astro << 'EOF'
<form class="search">
  <input type="text" placeholder="Search…" />
</form>
EOF

git add . && git commit -m "style for search bar"

# bug annexe 1 : corriger une coquille dans README
sed -i '' 's/Seach/Search/' README.md 2>/dev/null || \
sed -i 's/Seach/Search/' README.md
git add README.md && git commit -m "fix typo in README (bug 1)"

# bug annexe 2 : retrait d'un console.log oublié
sed -i '' '/console\.log/d' src/utils/helpers.ts 2>/dev/null || \
sed -i '/console\.log/d' src/utils/helpers.ts
git add src/utils/helpers.ts && git commit -m "remove stray console.log (bug 2)"

# oubli du bouton submit
cat >> src/components/SearchBar.astro << 'EOF'
<!-- add submit button later -->
EOF

git add . && git commit -m "wip: placeholder for submit"

# ajout du bouton et test
sed -i '' 's/<!-- add submit button later -->/<button>Go<\/button>/' src/components/SearchBar.astro 2>/dev/null || \
sed -i 's/<!-- add submit button later -->/<button>Go<\/button>/' src/components/SearchBar.astro

git add . && git commit -m "add submit button"

# bug : accès clavier oublié
cat >> src/components/SearchBar.astro << 'EOF'
<!-- need aria-label on input -->
EOF

git add . && git commit -m "accessibility reminder"

# correction du bug
sed -i '' 's/<!-- need aria-label on input -->//' src/components/SearchBar.astro 2>/dev/null || \
sed -i 's/<!-- need aria-label on input -->//' src/components/SearchBar.astro
sed -i '' 's/<input /<input aria-label="search" /' src/components/SearchBar.astro 2>/dev/null || \
sed -i 's/<input /<input aria-label="search" /' src/components/SearchBar.astro

git add . && git commit -m "fix accessibility issue"

# oubli de l'import dans la page principale
cat >> src/pages/index.astro << 'EOF'
---
import SearchBar from '../components/SearchBar.astro'
---

<SearchBar />
EOF

git add src/pages/index.astro && git commit -m "import search bar in layout"

# remise en place du code commenté par erreur
sed -i '' 's/<SearchBar \/>//' src/pages/index.astro 2>/dev/null || \
sed -i 's/<SearchBar \/>//' src/pages/index.astro

git add src/pages/index.astro && git commit -m "remove accidental placeholder"

# bug annexe 3 : mise à jour d'un commentaire inexact
sed -i '' 's/@@TODO/@@ done/' src/components/Footer.astro 2>/dev/null || \
sed -i 's/@@TODO/@@ done/' src/components/Footer.astro
git add src/components/Footer.astro && git commit -m "update misleading footer comment (bug 3)"

# bug annexe 4 : corriger l'import cassé d'un test
sed -i '' 's/\.{2}\/oldPath/..\/newPath/' tests/search.spec.ts 2>/dev/null || \
sed -i 's/\.{2}\/oldPath/..\/newPath/' tests/search.spec.ts
git add tests/search.spec.ts && git commit -m "fix test import path (bug 4)"

# petit raté dans le message
git commit --allow-empty -m "search bar done?"
```

L'historique ressemble maintenant à ceci :

```bash
git log --oneline feature/search-bar ^main
# z9y8x7 search bar done?
# r1q0p9 fix test import path (bug 4)
# q0p9o8 update misleading footer comment (bug 3)
# y8x7w6 remove accidental placeholder
# x7w6v5 import search bar in layout
# w6v5u4 fix accessibility issue
# v5u4t3 accessibility reminder
# u4t3s2 add submit button
# t3s2r1 wip: placeholder for submit
# s2r1q0 style for search bar
# p9o8n7 remove stray console.log (bug 2)
# o8n7m6 fix typo in README (bug 1)
# b3c4d5e feat(search): add basic search bar component
```

L'exercice consiste à utiliser `git rebase -i` (avec l'outil si vous l'avez installé) pour :

1. Déplacer tous les commits de bug au début de l'historique de la branche.
2. Réorganiser ou fusionner les commits superflus (`style for search bar`, `wip: placeholder for submit`, etc.).
3. Beautifier les messages en suivant le style conventionnel (exemple `feat(search): …`).
4. Effacer le commit vide de fin ou le combiner avec le précédent.

On attend à la fin un historique qui ressemble à ceci :

```bash
git log --oneline feature/search-bar ^main
# b3c4d5e feat(search): add search bar component
# r1q0p9 fix: test import path
# q0p9o8 fix: update misleading footer comment
# p9o8n7 fix: remove stray console.log
# o8n7m6 fix: typo in README
```

Bon rebasage ! :rocket:
