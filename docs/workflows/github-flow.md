---
sidebar_position: 3
---

# GitHub Flow

## Concept

GitHub Flow est radicalement plus simple que Gitflow. Il n'y a qu'une seule règle fondamentale :

> **`main` est toujours déployable.**

Tout ce qui est sur `main` peut être mis en prod à n'importe quel moment. C'est une contrainte forte, mais elle simplifie tout le reste.

## Structure

```
main  ──●──────────────────────●──────────●──────── (déployé en continu)
         │                     │          │
         └── feature/A ──●──●──┘          │
                                          │
              feature/B ─────────●──●─────┘
```

Deux branches actives à tout moment : `main` et votre feature en cours.

## La boucle de travail

```
1. Créer une branche depuis main
2. Committer dessus
3. Ouvrir une Pull Request
4. Discuter, reviewer, itérer
5. Déployer depuis la branche (optionnel, pour tester en staging)
6. Merger dans main
7. Supprimer la branche
```

C'est tout.

## Exemple avec TodoCraft

### Nouvelle feature

```bash
# Toujours depuis main à jour
git checkout main
git pull origin main
git checkout -b feature/export-csv

# Développement
cat > src/utils/export.js << 'EOF'
export function tasksToCSV(tasks) {
  const header = "id,title,priority,done";
  const rows = tasks.map(t => `${t.id},"${t.title}",${t.priority},${t.done}`);
  return [header, ...rows].join("\n");
}
EOF
git add .
git commit -m "feat(export): add CSV export utility"

# Tests OK, on push et on ouvre une PR
git push -u origin feature/export-csv
# → Ouvrir la PR sur GitHub/GitLab
```

### Après review et approbation

```bash
# Option 1 : Merge commit (historique lisible)
git checkout main
git merge --no-ff feature/export-csv

# Option 2 : Squash merge (historique propre)
git merge --squash feature/export-csv
git commit -m "feat(export): add CSV export (#42)"

# Option 3 : Rebase (linéaire, sans merge commits)
git rebase main feature/export-csv
git checkout main
git merge --ff-only feature/export-csv

# Supprimer la branche
git branch -d feature/export-csv
git push origin --delete feature/export-csv
```

### Hotfix en production

Pas de branche spéciale — même process qu'une feature :

```bash
git checkout main
git checkout -b fix/login-validation
git commit -m "fix(auth): add input validation"
# PR → review → merge → déploiement
```

## Rebase ou merge dans GitHub Flow ?

C'est le seul vrai sujet de débat dans GitHub Flow. Voici les positions :

### Merge commit (`--no-ff`)
```
main: A──B──M──────
            │
feature:  C──D
```
- ✅ Contexte préservé (savoir qu'on était sur une feature)
- ✅ Facile à reverter (un seul commit à reverter)
- ❌ Historique non linéaire

### Squash merge
```
main: A──B──CD──────
```
- ✅ Historique ultra-propre
- ✅ Chaque feature = 1 commit sur main
- ❌ Perd le détail des commits intermédiaires

### Rebase + fast-forward
```
main: A──B──C──D──────
```
- ✅ Historique linéaire, tous les commits visibles
- ❌ Réécriture de l'historique (SHA différents)
- ❌ Force push nécessaire sur la branche

:::tip Conseil
Choisissez **une politique** et tenez-y. L'incohérence est pire que n'importe quelle option. Sur GitHub, configurez l'option autorisée dans les Settings du repo.
:::

## Avantages et inconvénients

### ✅ Avantages
- Extrêmement simple à expliquer et à suivre
- Favorise le déploiement continu
- Peu de branches longues = moins de conflits
- Adapté aux petites et moyennes équipes

### ❌ Inconvénients
- Requiert une CI/CD solide (sinon `main` n'est pas "toujours déployable")
- Pas adapté si vous maintenez plusieurs versions en prod
- Les feature flags deviennent indispensables pour les grosses features
