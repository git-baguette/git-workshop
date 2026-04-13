---
sidebar_position: 4
---

# Rerere — Ne résolvez jamais deux fois le même conflit

## Le problème

Vous maintenez une feature branch pendant 3 semaines. Vous rebaser sur `main` deux fois par semaine. À chaque rebase, le même conflit réapparaît dans le même fichier, entre votre code et un refactor upstream. Vous le résolvez. Encore. Encore.

**Git rerere enregistre vos résolutions et les rejoue automatiquement.**

**rerere** = **Re**use **Re**corded **Re**solution

## Activer rerere

```bash
# Globalement (recommandé)
git config --global rerere.enabled true

# Pour un seul dépôt
git config rerere.enabled true
```

## Comment ça fonctionne

```
Première fois :
  conflit détecté → vous résolvez → rerere enregistre la résolution

Fois suivantes (même conflit) :
  conflit détecté → rerere rejoue votre résolution automatiquement
```

Les résolutions sont stockées dans `.git/rr-cache/` :

```
.git/rr-cache/
└── <hash-du-contexte-de-conflit>/
    ├── preimage   ← à quoi ressemblait le conflit
    └── postimage  ← comment vous l'avez résolu
```

## Hands-on

### Setup

```bash
cd ~/git-workshop
mkdir rerere-demo && cd rerere-demo
git init -b main
git config rerere.enabled true

cat > config.js << 'EOF'
module.exports = {
  timeout: 30,
  retries: 3,
  endpoint: "https://api.ngbaguette.dev",
};
EOF
git add . && git commit -m "feat: initial config"
```

### Créer le conflit

```bash
# Branche A : augmente le timeout
git switch -C feature/longer-timeout
sed -i '' 's/timeout: 30/timeout: 60/' config.js
git add . && git commit -m "feat: double the timeout"

# Branche B : valeur différente
git switch main
git switch -C feature/custom-timeout
sed -i '' 's/timeout: 30/timeout: 45/' config.js
git add . && git commit -m "feat: set timeout to 45s"

git switch main
git merge feature/longer-timeout
```

### Premier merge — enregistrement de la résolution

```bash
git merge feature/custom-timeout
# CONFLICT (content): Merge conflict in config.js
# Recorded preimage for 'config.js'  ← rerere a capturé le conflit
```

Résolvez le conflit manuellement :

```bash
cat > config.js << 'EOF'
module.exports = {
  timeout: 45,
  retries: 3,
  endpoint: "https://api.ngbaguette.dev",
};
EOF

git add config.js
git commit -m "merge: combine timeout branches"
# Recorded resolution for 'config.js'  ← rerere a enregistré la résolution !
```

### Rejouer — le même conflit résolu automatiquement

```bash
git reset --hard HEAD~1  # undo pour simuler une prochaine fois
git merge feature/custom-timeout

# Recorded preimage for 'config.js'
# Resolved 'config.js' using previous resolution.  ← auto-résolu !
```

Le fichier est déjà résolu. Il suffit de :

```bash
git add config.js
git commit -m "merge: combine timeout branches (rerere auto-résolu)"
```

## `rerere.autoUpdate` : aller encore plus loin

```bash
git config --global rerere.autoUpdate true
```

Avec ce flag, rerere non seulement résout le conflit mais **stage le fichier automatiquement**. Vous n'avez plus qu'à `git commit`.

:::warning
Utilisez `rerere.autoUpdate` avec précaution. Vérifiez toujours les fichiers résolus avant de committer — une résolution incorrecte serait stagée sans vous demander votre avis.
:::

## Gérer le cache rerere

```bash
# Voir les résolutions en attente
git rerere status

# Diff entre preimage et postimage
git rerere diff

# Oublier une résolution spécifique (pour re-résoudre manuellement)
git rerere forget config.js

# Vider tout le cache
rm -rf .git/rr-cache
```

## Cas d'usage idéaux

- **Rebase d'une feature branch longue** : même conflit à chaque rebase → rerere le résout tout seul après la première fois
- **Cherry-pick répétitifs** : même correctif appliqué sur plusieurs branches de release
- **Monorepos** : plusieurs équipes touchent les mêmes fichiers de config

## Nettoyage

```bash
cd ~/git-workshop && rm -rf rerere-demo
```
