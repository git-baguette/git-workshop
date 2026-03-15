---
sidebar_position: 2
---

# TP — Ressusciter des commits perdus

:::info Prérequis
Avoir exécuté le [script de setup](/docs/setup). Le projet ng-baguette-conf contient une branche `feature/cfp-form` **supprimée** à retrouver.
:::

## Scénario 1 — Le `reset --hard` catastrophique (15 min)

### Préparation

:::note Point de départ commun
Ces commandes créent 3 commits sur main pour simuler "un travail récent à ne pas perdre". Exécutez-les même si vous avez déjà fait les exercices précédents — elles sont idempotentes.
:::

```bash
cd ~/git-workshop/ng-baguette-conf
git switch main

# Créer 3 commits qui vont "disparaître"
echo "sponsor-gold: Vercel" >> src/data/sponsors.json 2>/dev/null || echo "Vercel" >> sponsors.txt
git add -A && git commit -m "feat(sponsors): add Vercel as gold sponsor"

echo "sponsor-silver: Netlify" >> src/data/sponsors.json 2>/dev/null || echo "Netlify" >> sponsors.txt
git add -A && git commit -m "feat(sponsors): add Netlify as silver sponsor"

echo "sponsor-silver: Clever Cloud" >> src/data/sponsors.json 2>/dev/null || echo "Clever Cloud" >> sponsors.txt
git add -A && git commit -m "feat(sponsors): add Clever Cloud as silver sponsor"

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
Si vous avez utilisé le script de setup, la branche est déjà supprimée — passez directement à [La situation](#la-situation).
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

### La situation {#la-situation}

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

Notez le hash du dernier commit **sur** la branche (avant le checkout vers main).

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

### La situation

Vous rebasez `feature/speaker-search` sur main. Quelque chose se passe mal. Vous vous retrouvez dans un état incompréhensible.

```bash
git checkout feature/speaker-search

# Simuler un rebase qui déraille
git rebase main
# (Des conflits apparaissent, vous faites des erreurs en les résolvant...)

# Votre code n'a plus l'air de ce qu'il devrait être
git log --oneline -5
# Quelque chose ne va pas
```

### Récupération immédiate

```bash
# Option 1 : abort si le rebase est encore en cours
git rebase --abort
# Revient à l'état exact AVANT git rebase

# Option 2 : si vous avez déjà fini mais que le résultat est mauvais
git reflog
# HEAD@{0}: rebase (finish): returning to refs/heads/feature/speaker-search
# HEAD@{1}: rebase (pick): feat: add SpeakerSearch component with live filtering
# HEAD@{2}: rebase (start): checkout main
# HEAD@{3}: commit: feat: add SpeakerSearch component  ← état avant rebase

# Revenir à l'état avant le rebase
git reset --hard HEAD@{3}
```

:::tip Identifier "avant le rebase" dans le reflog
Cherchez la ligne `rebase (start): checkout main`. La ligne juste **après** dans le reflog est l'état d'avant le rebase. Exemple : si le start est à `HEAD@{2}`, l'état avant est `HEAD@{3}`.
:::

## Scénario 4 — Récupérer un stash droppé (5 min)

```bash
# Créer et dropper un stash
echo "travail important non sauvé" > travail-urgent.txt
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
