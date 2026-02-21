---
sidebar_position: 2
---

# TP — Débusquer le bug de tri dans TodoCraft

:::info Prérequis
Avoir exécuté le [script de setup](/docs/setup). Le bug est planté dans le projet TodoCraft.
:::

## Vérifier la présence du bug

```bash
cd ~/git-workshop/todocraft
node tests/sort.test.js
# AssertionError: FAIL [0]: attendu high, obtenu low
```

Vous savez :
- **Maintenant** (`HEAD`) : le bug est là
- **Au début** (premier commit) : le code était correct

## Partie 1 — Bisect manuel (20 min)

### Lancer la session

```bash
# Démarrer
git bisect start

# HEAD est mauvais
git bisect bad

# Le premier commit de l'historique était bon
FIRST=$(git log --oneline | tail -1 | awk '{print $1}')
git bisect good $FIRST
```

Git vous répond :

```
Bisecting: 23 revisions left to test after this (roughly 5 steps)
[<hash>] <message du commit au milieu>
```

Git vous a checkout un commit au milieu. Testez-le :

```bash
node tests/sort.test.js
```

Selon le résultat :
- **Tests OK** → `git bisect good`
- **Tests KO** → `git bisect bad`

Répétez 4-5 fois jusqu'à ce que Git annonce :

```
<hash> is the first bad commit
commit <hash>
Author: TodoCraft Dev <workshop@todocraft.io>
Date:   ...

    refactor(sort): update priority constants for new design system
```

**Vous avez trouvé le coupable.**

### Inspecter le commit coupable

```bash
# Voir le diff du commit
git show $(git bisect log | grep "# bad" | tail -1 | awk '{print $3}')

# Ou pendant la session
git diff HEAD^ HEAD -- src/utils/sort.js
```

Vous verrez :

```diff
-const PRIORITY_ORDER = { high: 0, medium: 1, low: 2 };
+const PRIORITY_ORDER = { high: 2, medium: 1, low: 0 };
```

Voilà le bug : les valeurs ont été inversées.

### Terminer la session

```bash
git bisect reset
# HEAD est de retour sur votre branche d'origine
```

## Partie 2 — Bisect automatique (20 min)

Le projet TodoCraft a un script de test prêt à l'emploi : `bisect-test.sh`.

```bash
cat bisect-test.sh
```

Il détecte le bug en inspectant le fichier `sort.js` :
- Exit 0 → commit bon (`high: 0`)
- Exit 1 → commit mauvais (`high: 2`)
- Exit 125 → commit à skipper (fichier pas encore créé)

### Lancer le bisect automatisé

```bash
git bisect start
git bisect bad HEAD
git bisect good $(git log --oneline | tail -1 | awk '{print $1}')

# Laisser Git tout faire
git bisect run ./bisect-test.sh
```

Git enchaine les checkouts et les tests sans aucune intervention. Résultat en quelques secondes :

```
running ./bisect-test.sh
running ./bisect-test.sh
running ./bisect-test.sh
running ./bisect-test.sh
running ./bisect-test.sh
<hash> is the first bad commit
```

```bash
git bisect reset
```

### Comparer les durées

- **Manuel** : 5-6 questions, ~5 min de TP
- **Automatique** : 0 question, ~3 secondes

## Partie 3 — Corriger et nettoyer (5 min)

Maintenant que vous savez quel commit a introduit le bug, corrigez-le :

```bash
# Option 1 : corriger sur main directement (GitHub Flow)
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

git add . && git commit -m "fix(sort): restore correct priority order (high: 0)"

# Vérifier
node tests/sort.test.js
# ✅ Tests OK — sortByPriority fonctionne correctement
```

## Commandes utiles pendant une session bisect

```bash
# Voir l'historique des décisions prises
git bisect log

# Voir les commits restants à tester
git bisect visualize --oneline

# Passer un commit qui ne compile pas / ne peut pas être testé
git bisect skip

# Sauvegarder une session (pour la reprendre plus tard)
git bisect log > session-bisect.log
git bisect reset
# Reprendre :
git bisect replay session-bisect.log
```

---

## 🏆 Challenge — Bisect sur votre propre historique

Imaginez que le bug soit différent : la function `filterDone` retourne les tâches **terminées** au lieu des **non-terminées**.

1. Modifiez `filterDone` pour introduire ce bug dans un nouveau commit
2. Ajoutez un test qui détecte ce bug dans `tests/sort.test.js`
3. Utilisez `git bisect run` avec le test pour retrouver le commit coupable

```bash
# Hint : votre script de test doit tester filterDone
node --input-type=module << 'EOF'
import { filterDone } from "./src/utils/sort.js";
const tasks = [{ done: true }, { done: false }];
const result = filterDone(tasks);
// filterDone doit retourner uniquement les non-terminées
process.exit(result.length === 1 && !result[0].done ? 0 : 1);
EOF
```
