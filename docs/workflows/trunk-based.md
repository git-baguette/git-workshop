---
sidebar_position: 4
---

# Trunk-Based Development

## Concept

Trunk-Based Development (TBD) pousse GitHub Flow à l'extrême : tout le monde commit **directement sur `main`** (le "trunk"), ou sur des branches de très courte durée (< 2 jours).

> L'objectif : l'intégration continue n'est plus un outil — c'est une pratique quotidienne.

## Pourquoi ?

Les branches longues créent de la **dette d'intégration**. Plus une branche vit longtemps, plus elle diverge, plus le merge est douloureux. TBD élimine ce problème à la racine.

```
main  ──●──●──●──●──●──●──●──●──●── (déployé en continu)
         └─●─┘  └─●─┘  └─●─┘
         (<2j)  (<2j)   (<2j)
```

## Les feature flags : la clé de voûte

Puisqu'on ne peut pas cacher une feature incomplète derrière une branche longue, on la cache derrière un **feature flag** :

```js
// src/config/features.js
export const FEATURES = {
  darkMode:   process.env.FEATURE_DARK_MODE   === "true",
  exportCsv:  process.env.FEATURE_EXPORT_CSV  === "true",
  analytics:  process.env.FEATURE_ANALYTICS   === "true",
};
```

```js
// Dans le composant
import { FEATURES } from "../config/features.js";

function AppMenu() {
  return (
    <menu>
      <li>Tasks</li>
      {FEATURES.darkMode  && <li>Dark Mode</li>}
      {FEATURES.exportCsv && <li>Export CSV</li>}
    </menu>
  );
}
```

La feature est dans `main`, mais invisible tant que le flag est `false`. On active le flag en prod quand on est prêt.

## Pratiques associées indispensables

| Pratique | Pourquoi c'est critique |
|---------|------------------------|
| **Tests automatisés** | Sans tests solides, merger direct sur main = chaos |
| **CI rapide** | Si la CI prend 30 min, personne ne voudra merger souvent |
| **Feature flags** | Pour déployer sans exposer les features incomplètes |
| **Pair programming / code review async** | Le review se fait sur de petits commits, pas des PRs de 1000 lignes |
| **Rollback facile** | `git revert` doit être réflexe |

## Exemple avec NG Baguette Conf

### Committer directement sur main (petits changements)

```bash
git checkout main
git pull

# Fix rapide
sed -i '' 's/timeout: 30/timeout: 45/' src/api/config.js
git add . && git commit -m "fix(api): increase default timeout to 45s"
git push
# → CI lance les tests automatiquement → déploiement si OK
```

### Feature avec branche courte (moins de 2 jours)

```bash
git checkout main && git pull
git checkout -b feature/keyboard-shortcuts  # max 2 jours de vie

# Jour 1 : implémentation
git commit -m "feat(ui): add keyboard shortcut handler"

# Jour 2 : tests + finalisation
git commit -m "test: add keyboard shortcuts tests"
git commit -m "feat(ui): add shortcuts for new task and search"

# Merger rapidement
git checkout main && git pull
git rebase main feature/keyboard-shortcuts  # ou merge, selon votre politique
git checkout main
git merge --ff-only feature/keyboard-shortcuts
git push
git branch -d feature/keyboard-shortcuts
```

### Feature longue : derrière un flag

```bash
# On travaille directement sur main, feature cachée par flag
git checkout main

# Jour 1
cat >> src/config/features.js << 'EOF'
// analyticsV2: feature in progress
export const ANALYTICS_V2 = process.env.FEATURE_ANALYTICS_V2 === "true";
EOF
git commit -m "feat(analytics): scaffold v2 analytics (flag off)"

# Jour 3
git commit -m "feat(analytics): add event tracking (flag off)"

# Jour 7 : ready, on active le flag en staging
# Jour 10 : on active le flag en prod
git commit -m "feat(analytics): enable analytics v2 by default"
```

## Avantages et inconvénients

### ✅ Avantages
- Intégration vraiment continue — pas de "merge hell"
- Feedback immédiat sur la qualité du code
- Releases triviales (main est toujours prêt)
- Détection précoce des conflits

### ❌ Inconvénients
- Requiert une discipline d'équipe très forte
- La CI doit être ultra-rapide et fiable
- Les feature flags doivent être gérés (nettoyés quand obsolètes)
- Difficile à adopter sans culture DevOps établie

## Qui utilise TBD ?

Google, Facebook, Netflix, Etsy. En général : les organisations qui déploient **des dizaines à des centaines de fois par jour**.
