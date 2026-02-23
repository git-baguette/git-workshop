---
sidebar_position: 2
---

# TP — Jongler avec 3 branches simultanément

:::info Prérequis
Avoir exécuté le [script de setup](/docs/setup). TodoCraft doit exister dans `~/git-workshop/todocraft` avec les branches `feature/dark-mode` et `feature/export-csv`.
:::

## Exercice 1 — Visualiser la situation initiale (5 min)

```bash
cd ~/git-workshop/todocraft

# État actuel
git worktree list
# ~/git-workshop/todocraft  <hash> [main]

# Branches disponibles
git branch
# * main
#   feature/dark-mode
#   feature/export-csv

# Vérifier qu'il y a du travail en cours sur dark-mode
git log --oneline feature/dark-mode ^main
# feat(ui): add dark mode toggle button component

git diff feature/dark-mode..main -- src/ui/darkmode.js
# Voir les modifications non committées (preloadTheme en WIP)
```

## Exercice 2 — L'urgence en prod (15 min)

Vous êtes supposé être en train de travailler sur `feature/dark-mode`. Une alerte arrive : le tri des tâches est cassé en prod (le bug de `sortByPriority` que vous découvrirez dans le module Bisect).

**Sans quitter votre contexte de travail**, créez un worktree pour le hotfix :

```bash
# Depuis le répertoire principal (ou n'importe quel worktree)
git worktree add -b fix/sort-priority ../todocraft-hotfix main

# Vérifier
git worktree list
# ~/git-workshop/todocraft          <hash> [main]
# ~/git-workshop/todocraft-hotfix   <hash> [fix/sort-priority]
```

**Dans un nouveau terminal**, travaillez sur le hotfix :

```bash
cd ~/git-workshop/todocraft-hotfix

# Vérifier qu'on est bien sur fix/sort-priority
git branch
# * fix/sort-priority

# Appliquer le correctif
cat > src/utils/sort.js << 'EOF'
// Ordre correct : 0 = plus urgent
const PRIORITY_ORDER = { high: 0, medium: 1, low: 2 };

export function sortByPriority(tasks) {
  return [...tasks].sort(
    (a, b) => PRIORITY_ORDER[a.priority] - PRIORITY_ORDER[b.priority]
  );
}

export function filterDone(tasks) {
  return tasks.filter(t => !t.done);
}

export function sortByDate(tasks) {
  return [...tasks].sort(
    (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
  );
}
EOF

git add .
git commit -m "fix(sort): restore correct priority order (high first)"

# Lancer le test
node tests/sort.test.js
# ✅ Tests OK
```

**Dans le premier terminal** (worktree principal), vérifiez que rien n'a bougé :

```bash
# Dans ~/git-workshop/todocraft
git branch
# * main   ← on n'a pas bougé

# feature/dark-mode est intacte
git status  # propre sur main
git log --oneline feature/dark-mode ^main
# feat(ui): add dark mode toggle button component  ← toujours là
```

Mergez le hotfix dans main :

```bash
cd ~/git-workshop/todocraft
git merge fix/sort-priority --ff-only
git log --oneline -3
# fix(sort): restore correct priority order (high first)  ← le fix est là
```

Nettoyez le worktree hotfix :

```bash
git worktree remove ../todocraft-hotfix
git branch -d fix/sort-priority
```

## Exercice 3 — Travailler sur 2 features simultanément (15 min)

Maintenant que le hotfix est en prod, vous reprenez vos features. Créez un worktree pour `feature/export-csv` :

```bash
git worktree add ../todocraft-export feature/export-csv
```

**Terminal 1** — Continuer `feature/dark-mode` :

```bash
git checkout feature/dark-mode
# Finir le preloadTheme
cat >> src/ui/darkmode.js << 'EOF'

export function preloadTheme() {
  // Appelé dans <head> pour éviter le FOUC (Flash Of Unstyled Content)
  const theme = localStorage.getItem("todocraft-theme") ?? "light";
  document.documentElement.dataset.theme = theme;
}
EOF
git add . && git commit -m "feat(ui): add preloadTheme to prevent FOUC"
```

**Terminal 2** — Continuer `feature/export-csv` :

```bash
cd ~/git-workshop/todocraft-export

cat > src/ui/ExportMenu.js << 'EOF'
import { ExportButton } from "./ExportButton.js";

export function ExportMenu({ getTasks }) {
  const menu = document.createElement("div");
  menu.className = "export-menu";
  menu.innerHTML = `<h3>Exporter</h3>`;

  const csvBtn = ExportButton({ getTasks, format: "csv" });
  menu.appendChild(csvBtn);

  return menu;
}
EOF
git add . && git commit -m "feat(ui): add ExportMenu with format selection"
```

Vérifier l'état global depuis n'importe quel worktree :

```bash
git worktree list
# ~/git-workshop/todocraft          <hash> [main]
# ~/git-workshop/todocraft-export   <hash> [feature/export-csv]

# Voir les branches dans leur état respectif
git log --oneline feature/dark-mode ^main
git log --oneline feature/export-csv ^main
```

## Exercice 4 — Merge des features (5 min)

```bash
cd ~/git-workshop/todocraft
git checkout main

# Merger dark-mode
git merge feature/dark-mode --no-ff -m "merge: feature/dark-mode"
git branch -d feature/dark-mode
git worktree remove ../todocraft-export 2>/dev/null || true

# Merger export-csv
git merge feature/export-csv --no-ff -m "merge: feature/export-csv"
git branch -d feature/export-csv

# Nettoyage
git worktree prune
git worktree list
# ~/git-workshop/todocraft  <hash> [main]
```

## Exercice 5 — Contrainte : même branche dans 2 worktrees (2 min)

Testez la protection de Git :

```bash
git checkout -b test-branch
git worktree add ../test-wt main

# Essayer d'accéder à test-branch depuis le second worktree
cd ../test-wt
git checkout test-branch
# fatal: 'test-branch' is already checked out at '~/git-workshop/todocraft'

# Nettoyage
cd ~/git-workshop/todocraft
git worktree remove ../test-wt
git branch -d test-branch
git checkout main
```

## Récapitulatif des commandes

```bash
git worktree add ../nom-dossier branche-existante
git worktree add -b nouvelle-branche ../nom-dossier point-de-depart
git worktree list
git worktree remove ../nom-dossier
git worktree prune
```

---

## 🏆 Challenge — Le setup bare + worktrees

Pour les plus rapides : refaites l'exercice avec le setup **bare repo + worktrees** (le pattern le plus propre pour les équipes avancées) :

```bash
cd ~/git-workshop

# Cloner le todocraft existant en bare
git clone --bare todocraft todocraft-bare.git
cd todocraft-bare.git

# Créer les worktrees depuis le bare
git worktree add ../tc-main main
git worktree add ../tc-feature feature/dark-mode

# Comparer la structure
ls -la ../tc-main/
# Pas de .git/ mais un fichier .git qui pointe vers todocraft-bare.git

cat ../tc-main/.git
# gitdir: /home/user/git-workshop/todocraft-bare.git/worktrees/tc-main
```

**Question :** quelle est la différence entre `~/git-workshop/todocraft/.git/` et `~/git-workshop/todocraft-bare.git/` ?
