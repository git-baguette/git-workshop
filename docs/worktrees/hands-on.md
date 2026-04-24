---
sidebar_position: 2
---

# Exercice — Jongler avec 3 branches simultanément

:::info Prérequis
Avoir exécuté le [setup](/docs/setup).

Si vous avez déjà executé un autre module, lancer la commande `git switch main && git reset --hard origin/main`.

Ng-baguette-conf doit exister dans `$WORKSHOP_DIR/ng-baguette-conf` avec les branches `feature/responsive-nav` et `feature/speaker-search`.
:::

## Exercice 1 — Visualiser la situation initiale (5 min)

```bash
cd $WORKSHOP_DIR/ng-baguette-conf

# État actuel
git worktree list
# $WORKSHOP_DIR/ng-baguette-conf  <hash> [main]

# Branches disponibles
git branch
# * main
#   feature/responsive-nav
#   feature/speaker-search

# Vérifier qu'il y a du travail en cours sur responsive-nav
git log --oneline feature/responsive-nav ^main
# feat(nav): replace dropdown with drawer for mobile navigation

git stash list
# (rien — les modifs sont dans le working tree de la branche)
```

## Exercice 2 — L'urgence en prod (15 min)

Vous êtes supposé être en train de travailler sur `main`. Une alerte arrive : l'agenda affiche les sessions en ordre anti-chronologique (le bug de `getSortedSessions` que vous découvrirez dans le module Bisect).

**Sans quitter votre contexte de travail**, créez un worktree pour le hotfix :

<details>
  <summary>Afficher le code</summary>

```bash
# Depuis le répertoire principal (ou n'importe quel worktree)
git worktree add -b fix/schedule-sort ../ng-baguette-hotfix main

# Vérifier
git worktree list
# $WORKSHOP_DIR/ng-baguette-conf          <hash> [main]
# $WORKSHOP_DIR/ng-baguette-hotfix        <hash> [fix/schedule-sort]
```

</details>

**Dans un nouveau terminal**, travaillez sur le hotfix :

<details>
  <summary>Afficher le code</summary>

```bash
cd $WORKSHOP_DIR/ng-baguette-hotfix

# Vérifier qu'on est bien sur fix/schedule-sort
git branch
# * fix/schedule-sort

# Vérifier le bug
./bisect-test.sh; echo "Exit: $?"
# Exit: 1  ← bug confirmé

# Appliquer le correctif dans src/utils/schedule.ts
# Remplacer la ligne :
#   (a, b) => new Date(b.start).getTime() - new Date(a.start).getTime()
# Par :
#   (a, b) => new Date(a.start).getTime() - new Date(b.start).getTime()

git add src/utils/schedule.ts
git commit -m "fix(schedule): restore chronological sort order in getSortedSessions"

# Vérifier que le bug est corrigé
./bisect-test.sh; echo "Exit: $?"
# Exit: 0  ← bug corrigé
```

</details>

**Dans le premier terminal** (worktree principal), vérifiez que rien n'a bougé :

<details>
  <summary>Afficher le code</summary>

```bash
# Dans $WORKSHOP_DIR/ng-baguette-conf
git branch
# * main   ← on n'a pas bougé

# feature/responsive-nav est intacte
git log --oneline feature/responsive-nav ^main
# feat(nav): replace dropdown with drawer for mobile navigation  ← toujours là
```

</details>

Mergez le hotfix dans main :

```bash
cd $WORKSHOP_DIR/ng-baguette-conf
git merge fix/schedule-sort --ff-only
git log --oneline -3
# fix(schedule): restore chronological sort order  ← le fix est là
```

Nettoyez le worktree hotfix :

<details>
  <summary>Afficher le code</summary>

```bash
git worktree remove ../ng-baguette-hotfix
git branch -d fix/schedule-sort
```

</details>

## Exercice 3 — Travailler sur 2 features simultanément (15 min)

Maintenant que le hotfix est en prod, vous reprenez vos features. Créez un worktree pour `feature/speaker-search` :

<details>
  <summary>Afficher le code</summary>

```bash
git worktree add ../ng-baguette-search feature/speaker-search
git worktree add ../ng-baguette-nav feature/responsive-nav
```

</details>

**Terminal 1** — Continuer `feature/responsive-nav` :

```bash
cd $WORKSHOP_DIR/ng-baguette-nav

# Ajouter le listener ESC à la fin de Drawer.astro
cat >> src/components/Drawer.astro << 'EOF'

<script>
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      const drawer = document.getElementById("my-drawer") as HTMLInputElement | null;
      if (drawer) drawer.checked = false;
    }
  });
</script>
EOF

git add src/components/Drawer.astro
git commit -m "feat(nav): add ESC key to close mobile drawer"
```

**Terminal 2** — Continuer `feature/speaker-search` :

```bash
cd $WORKSHOP_DIR/ng-baguette-search

# Ajouter la page speakers
cat > src/pages/fr/speakers.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
import SpeakerSearch from "../../components/SpeakerSearch.astro";
---
<Layout title="Speakers — NG Baguette Conf">
  <h1 class="text-3xl font-bold mb-6">Speakers</h1>
  <SpeakerSearch />
</Layout>
EOF
git add . && git commit -m "feat: add speakers listing page with search"
```

Vérifier l'état global depuis n'importe quel worktree :

<details>
  <summary>Afficher le code</summary>

```bash
git worktree list
# $WORKSHOP_DIR/ng-baguette-conf          <hash> [main]
# $WORKSHOP_DIR/ng-baguette-nav           <hash> [feature/responsive-nav]
# $WORKSHOP_DIR/ng-baguette-search        <hash> [feature/speaker-search]

# Voir les branches dans leur état respectif
git log --oneline feature/responsive-nav ^main
git log --oneline feature/speaker-search ^main
```

</details>

## Exercice 4 — Merge des features (5 min)

```bash
cd $WORKSHOP_DIR/ng-baguette-conf
git switch main

# Nettoyer le worktree nav
git worktree remove ../ng-baguette-nav

# Merger responsive-nav
git merge feature/responsive-nav --no-ff -m "merge: feature/responsive-nav"
git branch -D feature/responsive-nav

# Nettoyer le worktree search
git worktree remove ../ng-baguette-search

# Merger speaker-search
git merge feature/speaker-search --no-ff -m "merge: feature/speaker-search"
git branch -D feature/speaker-search

# Nettoyage
git worktree prune
git worktree list
# $WORKSHOP_DIR/ng-baguette-conf  <hash> [main]
```

## Exercice 5 — Contrainte : même branche dans 2 worktrees (2 min)

Testez la protection de Git :

```bash
git switch -C test-branch
git worktree add ../test-wt main

# Essayer d'accéder à test-branch depuis le second worktree
cd ../test-wt
git switch test-branch
# fatal: 'test-branch' is already used by worktree at '$WORKSHOP_DIR/ng-baguette-conf'

# Nettoyage
cd $WORKSHOP_DIR/ng-baguette-conf
git worktree remove ../test-wt
git switch main
git branch -d test-branch
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
cd $WORKSHOP_DIR
mkdir bare
cd bare

# Cloner le ng-baguette-conf existant en bare
git clone --bare https://github.com/git-baguette/git-workshop-starter.git .git

# Créer les worktrees depuis le bare
git worktree add ./nb-main main
git worktree add ./nb-feature feature/responsive-nav 2>/dev/null || echo "branche déjà mergée"

# Comparer la structure
ls -la ./nb-main/
# Pas de .git/ mais un fichier .git qui pointe vers $WORKSHOP_DIR/bare/.git

cat ./nb-main/.git
# gitdir: /home/user/git-workshop/bare/.git/worktrees/nb-main
```

**Question :** quelle est la différence entre `$WORKSHOP_DIR/ng-baguette-conf/.git/` et `$WORKSHOP_DIR/bare/.git/` ?
