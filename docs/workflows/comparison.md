---
sidebar_position: 5
---

# Comparatif — Lequel choisir ?

## Tableau de décision

| Critère | Gitflow | GitHub Flow | Trunk-Based |
|---------|---------|-------------|-------------|
| Rythme de déploiement | Mensuel / hebdomadaire | Quotidien / pluriquotidien | Continu |
| Nombre de versions en prod | Plusieurs | Une | Une |
| CI/CD requise | Non (utile) | Oui (indispensable) | Oui (critique) |
| Feature flags | Non nécessaires | Optionnels | Indispensables |
| Complexité du workflow | Élevée | Faible | Faible (discipline forte) |
| Risque de merge hell | Élevé | Modéré | Faible |
| Adapté aux petites équipes | Moyen | Oui | Oui |
| Adapté aux grandes équipes | Oui | Oui | Oui |

## L'arbre de décision

```
Déployez-vous plusieurs versions en prod simultanément ?
├── OUI → Gitflow
└── NON
    │
    Déployez-vous plus d'une fois par semaine ?
    ├── NON → Gitflow ou GitHub Flow
    └── OUI
        │
        Avez-vous une CI/CD rapide et fiable ?
        ├── NON → GitHub Flow (et investissez dans votre CI)
        └── OUI
            │
            Êtes-vous à l'aise avec les feature flags ?
            ├── NON → GitHub Flow
            └── OUI → Trunk-Based Development
```

## Antipatterns courants

### "On fait Gitflow mais sans discipline"

```
develop traîne 3 mois derrière main.
Les feature branches vivent 6 semaines.
Personne ne fait le back-merge des hotfixes.
```

Résultat : tous les inconvénients de Gitflow, aucun des avantages. Passez à GitHub Flow.

### "On fait GitHub Flow mais sans CI"

```
main "devrait" toujours être déployable.
Mais les tests ne sont pas automatisés.
Chaque merge est une prière.
```

Résultat : vous faites juste du développement sur feature branches sans filet. Investissez dans la CI.

### "On fait Trunk-Based mais les commits sont énormes"

```
"Petites branches de moins de 2 jours"
→ PR de 47 fichiers modifiés
→ Review impossible
→ Personne ne sait ce qui est mergé
```

Trunk-Based requiert des **petits commits atomiques**. Si vous ne savez pas découper vos features, commencez par GitHub Flow.

## Le workflow des commits — peu importe votre choix

Quelle que soit la stratégie, ces pratiques s'appliquent :

```bash
# ✅ Commits atomiques : une idée = un commit
git commit -m "feat(auth): add email validation"
git commit -m "test(auth): add email validation tests"

# ❌ Commits "sac à dos"
git commit -m "fix stuff and add feature and update deps"

# ✅ Messages conventionnels
git commit -m "feat(export): add PDF export support"
git commit -m "fix(sort): correct priority order (high first)"
git commit -m "refactor(api): extract HTTP client"

# ✅ Rebase avant de merger (historique propre)
git rebase main feature/my-feature

# ✅ Vérifier ce qu'on merge
git diff main...feature/my-feature --stat
```

## Conventional Commits en 30 secondes

Format : `<type>(<scope>): <description>`

| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalité |
| `fix` | Correction de bug |
| `refactor` | Refactoring (pas de new feature, pas de bug fix) |
| `test` | Ajout ou modification de tests |
| `docs` | Documentation |
| `chore` | Tâches de maintenance (deps, config) |
| `ci` | Pipeline CI/CD |
| `perf` | Amélioration de performance |

Avec ce format, vous pouvez générer un CHANGELOG automatiquement et déclencher des bumps de version sémantique.
