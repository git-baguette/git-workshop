---
sidebar_position: 2
---

# TP — Ressusciter des commits perdus

:::info Prérequis
Avoir exécuté le [setup](/docs/setup). 

Si vous avez déjà executé un module précedent, lancer la commande `git switch main && git reset --hard origin/main`.

Le projet ng-baguette-conf doit être fonctionnel.
:::

## Scénario 1 — Le `reset --hard` catastrophique (15 min)

### Préparation

:::note Point de départ commun
Ces commandes créent 3 commits sur main pour simuler "un travail récent à ne pas perdre".
:::

```bash
cd ~/git-workshop/ng-baguette-conf
git switch main

# Créer 3 commits qui vont "disparaître"
echo "sponsor-gold: Google" >> src/data/sponsors.json 2>/dev/null || echo "Google" >> sponsors.txt
git add -A && git commit -m "feat(sponsors): add Google as gold sponsor"

echo "sponsor-silver: Angular" >> src/data/sponsors.json 2>/dev/null || echo "Angular" >> sponsors.txt
git add -A && git commit -m "feat(sponsors): add Angular as silver sponsor"

echo "sponsor-silver: Devoxx" >> src/data/sponsors.json 2>/dev/null || echo "Devoxx" >> sponsors.txt
git add -A && git commit -m "feat(sponsors): add Devoxx as silver sponsor"

git log --oneline -5
# Vous devriez voir vos 3 nouveaux commits en tête de liste
```

### La situation

Vous venez de finir 3 commits importants. En voulant "nettoyer", vous faites un `reset --hard` d'une de trop.

```bash
# Notez le hash du dernier commit avant l'accident
LAST=$(git rev-parse HEAD)
echo "Dernier commit : $LAST"

# L'accident : reset trop loin (on voulait HEAD~2, on a tapé HEAD~5)
git reset --hard HEAD~5

git log --oneline -3
# Les commits récents ont disparu !
```

### Diagnostic

```bash
git reflog | head -10
```

Vous verrez :

```
abc1234 HEAD@{0}: reset: moving to HEAD~5
def5678 HEAD@{1}: commit: feat(sponsors): add Clever Cloud as silver sponsor  ← votre dernier "bon" commit
ghi9012 HEAD@{2}: commit: feat(sponsors): add Netlify as silver sponsor
jkl3456 HEAD@{3}: commit: feat(sponsors): add Vercel as gold sponsor
...
```

### Récupération

```bash
# Option 1 : revenir exactement où on était
git reset --hard HEAD@{1}

# Vérifier
git log --oneline -5
# Les 3 commits sponsors sont de retour !

# Option 2 : si vous avez noté le hash
git reset --hard $LAST
```

:::tip Réflexe à avoir
Avant tout `git reset --hard`, notez le hash actuel :

```bash
git rev-parse HEAD  # copier ce hash dans votre terminal
```

Ou configurez votre terminal pour afficher le hash dans le prompt.
:::

## Scénario 2 — La branche supprimée (15 min)

### Préparation

:::note Script de setup
Si vous avez utilisé le script de setup, la branche est déjà supprimée — passez directement à [La situation](#la-situation2).
:::

Si vous avez cloné le repo, simulez l'accident maintenant :

```bash
cd ~/git-workshop/ng-baguette-conf
git switch main

# Vérifier que la branche n'existe pas déjà
git branch | grep cfp-form || (
  git switch -c feature/cfp-form
  mkdir -p src/pages/fr
  cat > src/pages/fr/cfp.astro << 'EOF'
---
import Layout from "../../layouts/Layout.astro";
---
<Layout title="CFP — NG Baguette Conf">
  <div class="max-w-2xl">
    <h1 class="text-3xl font-bold mb-6">Call for Papers</h1>
    <form class="space-y-4" action="/api/cfp" method="POST">
      <input name="title" type="text" class="input input-bordered" required />
      <textarea name="abstract" class="textarea textarea-bordered h-32" required></textarea>
      <button type="submit" class="btn btn-primary w-full">Soumettre ma proposition</button>
    </form>
  </div>
</Layout>
EOF
  git add src/pages/fr/cfp.astro
  git commit -m "feat(cfp): add CFP submission form"
  git switch main
  git branch -D feature/cfp-form
)
```

### La situation {#la-situation2}

La branche `feature/cfp-form` a été supprimée après avoir été mergée (enfin, c'est ce qu'on croyait). Votre mission : la retrouver.

```bash
# Vérifier que la branche n'existe plus
git branch | grep cfp-form
# (rien)

# Mais elle était là !
git reflog | grep cfp-form
# HEAD@{N}: commit: feat(cfp): add CFP submission form
# (ou similaire)
```

### Méthode 1 : via `git reflog`

```bash
# Chercher le moment où vous étiez sur cette branche
git reflog | grep -E "(cfp-form|cfp)"
# HEAD@{5}: checkout: moving from feature/cfp-form to main
# HEAD@{6}: commit: feat(cfp): add CFP submission form  ← dernier commit de la branche
```

Notez le hash du dernier commit **sur** la branche (avant le switch vers main).

```bash
# Recréer la branche à partir de ce commit (ajustez le numéro selon votre reflog)
git switch -C feature/cfp-form HEAD@{6}
# OU avec le hash directement (plus fiable)
git switch -C feature/cfp-form <hash>

git log --oneline -3
# feat(cfp): add CFP submission form  ← récupéré !
```

### Méthode 2 : `git fsck` pour trouver les commits orphelins

```bash
git fsck --lost-found
# dangling commit abc1234
# dangling commit def5678
# ...

# Inspecter les commits orphelins
git show abc1234 --stat
# S'il s'agit de votre commit, récupérez-le
git switch -C feature/cfp-form abc1234
```

### Vérification

```bash
git log --oneline feature/cfp-form ^main
# feat(cfp): add CFP submission form

cat src/pages/fr/cfp.astro
# <form ... action="/api/cfp">  ← le formulaire est là !
```

## Scénario 3 — Le rebase catastrophique (10 min)

### Préparation

:::note Branche créée ici
Ce scénario crée sa propre branche — pas de dépendance avec les autres modules.
:::

```bash
cd ~/git-workshop/ng-baguette-conf
git switch main

# Créer une branche feature qui diverge de main
git switch -c feature/speaker-bio

# Ajouter un fichier sur la branche
mkdir -p src/data
cat > src/data/bio.md << 'EOF'
# Bio Template
Speaker: À définir
Topic: À définir
EOF
git add src/data/bio.md
git commit -m "feat(speakers): add bio template"

# Faire diverger main (simule un commit d'un collègue)
git switch main

mkdir -p src/data
cat > src/data/bio.md << 'EOF'
# Bio Template
Speaker: Jane Smith
Topic: Angular 2025 State of the Art
EOF
git add src/data/bio.md
git commit -m "docs(speakers): fill bio with confirmed speaker"

# Retourner sur la branche
git switch feature/speaker-bio
```

### La situation

Vous rebasez `feature/speaker-bio` sur main. Un conflit apparaît. Vous tentez de le résoudre à la va-vite — et vous vous trompez.

```bash
git rebase main
# CONFLICT (add/add): Merge conflict in src/data/bio.md
# error: could not apply...

# Mauvaise résolution : vous écrasez tout
echo "# Bio mal fusionnée — travail perdu" > src/data/bio.md
git add src/data/bio.md
git rebase --continue

# Le rebase termine, mais le contenu est mauvais
git log --oneline -5
cat src/data/bio.md
# Pas ce qu'on voulait...
```

### Récupération immédiate

```bash
# Option 1 : abort si le rebase est encore en cours
git rebase --abort
# Revient à l'état exact AVANT git rebase

# Option 2 : si vous avez déjà fini mais que le résultat est mauvais
git reflog
# HEAD@{0}: rebase (finish): returning to refs/heads/feature/speaker-bio
# HEAD@{1}: rebase (pick): feat(speakers): add bio template
# HEAD@{2}: rebase (start): checkout main
# HEAD@{3}: commit: feat(speakers): add bio template  ← état avant rebase

# Revenir à l'état avant le rebase
git reset --hard HEAD@{3}

# Vérifier
cat src/data/bio.md
# Le contenu original est restauré !
```

:::tip Identifier "avant le rebase" dans le reflog
Cherchez la ligne `rebase (start): checkout main`. La ligne juste **après** dans le reflog est l'état d'avant le rebase. Exemple : si le start est à `HEAD@{2}`, l'état avant est `HEAD@{3}`.
:::

## Scénario 4 — Récupérer un stash droppé (5 min)

```bash
# Créer et dropper un stash
echo "travail important non sauvé" > travail-urgent.txt
git add -A
git stash push -m "WIP: travail urgent"
git stash drop
# Dropped refs/stash@{0} (abc1234)

# Le trouver
git fsck --lost-found | grep commit
# dangling commit abc1234

git show abc1234
# Le contenu du stash est là

# Récupérer
git stash apply abc1234
# OU créer une branche
git switch -C rescue/stash abc1234
```

## Configurer une rétention plus longue

```bash
# Voir la config actuelle
git config gc.reflogExpire
# (vide = valeur par défaut 90 days)

# Augmenter la rétention (recommandé en équipe)
git config --global gc.reflogExpire "180 days"
git config --global gc.reflogExpireUnreachable "90 days"
```

## Commandes reflog essentielles

```bash
git reflog                          # journal de HEAD
git reflog show ma-branche          # journal d'une branche spécifique
git reflog --relative-date          # avec timestamps lisibles
git reflog --since="2 days ago"     # filtrer par date
git reflog | grep "commit"          # filtrer par type d'opération

# Récupération
git reset --hard HEAD@{N}           # revenir N étapes en arrière
git switch -C rescue HEAD@{N}     # créer une branche de secours
git cherry-pick HEAD@{N}            # récupérer un seul commit
```

---

## 🏆 Challenge — Le "vendredi soir"

Situation : votre collègue vous passe son laptop et dit :

> _"J'ai fait `git reset --hard` mais je sais plus sur quoi j'étais. Aide-moi."_

```bash
# Recréer l'état désastreux
git switch main
git reset --hard HEAD~8

# À vous de jouer :
# 1. Trouvez ce qu'il a perdu avec le reflog
# 2. Identifiez les commits "disparus"
# 3. Récupérez-les sur une branche de rescue
# 4. Vérifiez que les fichiers sont bien là
```
