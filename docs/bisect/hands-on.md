---
sidebar_position: 2
---

# TP — Débusquer le bug de tri dans NG Baguette Conf

:::info Prérequis
Avoir exécuté le [script de setup](/docs/setup). Le bug est planté dans le projet ng-baguette-conf.
:::

## Vérifier la présence du bug

```bash
cd ~/git-workshop/ng-baguette-conf
./bisect-test.sh; echo "Exit: $?"
# Exit: 1  ← le bug est là
```

Le symptôme visible : l'agenda affiche les sessions en ordre **anti-chronologique** (la dernière session de la journée apparaît en premier).

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
Bisecting: 14 revisions left to test after this (roughly 4 steps)
[<hash>] <message du commit au milieu>
```

Git vous a checkout un commit au milieu. Testez-le :

```bash
./bisect-test.sh; echo "Exit: $?"
```

Selon le résultat :
- **Exit: 0** → `git bisect good`
- **Exit: 1** → `git bisect bad`
- **Exit: 125** → `git bisect skip` (fichier pas encore créé dans les premiers commits)

Répétez 4-5 fois jusqu'à ce que Git annonce :

```
<hash> is the first bad commit
commit <hash>
Author: NG Baguette Dev <workshop@ngbaguette.dev>
Date:   ...

    refactor(schedule): optimize session sort for performance
```

**Vous avez trouvé le coupable.**

### Inspecter le commit coupable

```bash
# Voir le diff du commit
git show $(git bisect log | grep "# bad" | tail -1 | awk '{print $3}' | tr -d '[]')

# Ou pendant la session
git diff HEAD^ HEAD -- src/utils/schedule.ts
```

Vous verrez :

```diff
-    (a, b) => new Date(a.start).getTime() - new Date(b.start).getTime()
+    (a, b) => new Date(b.start).getTime() - new Date(a.start).getTime()
```

Voilà le bug : l'ordre des opérandes `a` et `b` a été inversé dans le comparateur.

### Terminer la session

```bash
git bisect reset
# HEAD est de retour sur votre branche d'origine
```

## Partie 2 — Bisect automatique (20 min)

Le projet dispose d'un script de test prêt à l'emploi : `bisect-test.sh`.

```bash
cat bisect-test.sh
```

Il détecte le bug en inspectant le fichier `schedule.ts` :
- Exit 0 → commit bon (`a.start - b.start` = ordre chronologique)
- Exit 1 → commit mauvais (`b.start - a.start` = ordre inversé)
- Exit 125 → commit à skipper (fichier pas encore créé dans les commits 1-11)

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
<hash> is the first bad commit
```

```bash
git bisect reset
```

### Comparer les durées

- **Manuel** : 4-5 questions, ~5 min de TP
- **Automatique** : 0 question, ~3 secondes

## Partie 3 — Corriger et nettoyer (5 min)

Maintenant que vous savez quel commit a introduit le bug, corrigez-le :

```bash
# Ouvrir src/utils/schedule.ts et corriger getSortedSessions
# Remplacer :
#   (a, b) => new Date(b.start).getTime() - new Date(a.start).getTime()
# Par :
#   (a, b) => new Date(a.start).getTime() - new Date(b.start).getTime()

git add src/utils/schedule.ts
git commit -m "fix(schedule): restore correct chronological sort order in getSortedSessions"

# Vérifier
./bisect-test.sh; echo "Exit: $?"
# Exit: 0  ← bug corrigé
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

Introduisez un second bug : `getAllSpeakers()` retourne une liste vide.

1. Modifiez `getAllSpeakers` pour retourner `[]`
2. Committez avec un message trompeur
3. Écrivez un script de test qui détecte ce bug
4. Utilisez `git bisect run` pour retrouver le commit coupable

```bash
# Hint : votre script de test doit vérifier que getAllSpeakers retourne des données
node --input-type=module << 'EOF'
import { readFileSync } from "fs";
const code = readFileSync("src/utils/schedule.ts", "utf8");
const isCorrect = !code.includes("return []");
process.exit(isCorrect ? 0 : 1);
EOF
```
