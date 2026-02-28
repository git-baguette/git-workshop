---
sidebar_position: 3
---

# Bisect automatique — `git bisect run`

## Le problème avec le bisect manuel

Quand votre test est scriptable — et il devrait l'être — pourquoi cliquer "good" ou "bad" à la main 6 fois ? `git bisect run` exécute votre script de test à chaque étape et décide tout seul.

## Fonctionnement

```bash
git bisect run <commande>
```

Git évalue la commande après chaque checkout :
- **Exit code 0** → commit good
- **Exit code 1-127** → commit bad
- **Exit code 125** → commit skippé (ne peut pas être testé)

## Application au projet ng-baguette-conf

```bash
cd ~/git-workshop/ng-baguette-conf

git bisect start
git bisect bad HEAD
git bisect good $(git log --oneline | tail -1 | awk '{print $1}')

# Lance le test automatiquement à chaque étape
git bisect run ./bisect-test.sh
```

Git va :
1. Checkout un commit
2. Lancer `./bisect-test.sh`
3. Lire le code de sortie
4. Décider good/bad
5. Répéter jusqu'au commit coupable

Résultat final sans aucune intervention :

```
running ./bisect-test.sh
Bisecting: 7 revisions left to test (roughly 3 steps)
running ./bisect-test.sh
Bisecting: 3 revisions left to test (roughly 2 steps)
...
<hash> is the first bad commit
commit <hash>
    refactor(schedule): optimize session sort for performance
```

## Le script de test bisect-test.sh

Le projet fournit un script dédié :

```bash
#!/bin/bash
# Exit 0 = commit bon, Exit 1 = commit mauvais, Exit 125 = skip

# Vérifier que le fichier schedule.ts existe (commits 1-11 ne l'ont pas encore)
if [ ! -f "src/utils/schedule.ts" ]; then
  exit 125
fi

# Tester le sens du tri dans getSortedSessions
node --input-type=module << 'EOF'
import { readFileSync } from "fs";
const code = readFileSync("src/utils/schedule.ts", "utf8");
const isCorrect = code.includes("new Date(a.start).getTime() - new Date(b.start).getTime()");
process.exit(isCorrect ? 0 : 1);
EOF
```

### Pourquoi exit 125 pour les commits 1-11 ?

Les commits 1 à 11 n'ont pas encore créé `src/utils/schedule.ts` (il est ajouté au commit 12). Le script vérifie donc d'abord si le fichier existe, et si ce n'est pas le cas, retourne `125` pour que Git **skippe** ce commit au lieu de le marquer bad.

Sans ce garde-fou, Git marquerait les commits 1-11 comme mauvais à tort, et bisect ne convergerait pas vers le bon commit.

## Script de test dédié — bonne pratique

Pour les projets réels, créez un script dédié au bisect :

```bash
cat > bisect-test.sh << 'EOF'
#!/bin/bash
set -e

# Installer les dépendances si nécessaire (sans output)
npm ci --silent 2>/dev/null || true

# Lancer les tests ciblés
npm test -- --testPathPattern="schedule" --silent

# Exit code automatique : 0=good, 1=bad
EOF
chmod +x bisect-test.sh

git bisect run ./bisect-test.sh
```

:::tip Conseil
Ciblez le test le plus rapide et le plus précis possible. Si votre suite de tests complète prend 5 minutes, un bisect sur 100 commits = 7 étapes = **35 minutes**. Un test unitaire ciblé qui prend 2 secondes → **14 secondes**. Choisissez bien.
:::

## Gestion des commits qui ne compilent pas

Certains commits intermédiaires peuvent être dans un état non testable (en plein milieu d'une migration, dépendances cassées, etc.) :

```bash
cat > bisect-test.sh << 'EOF'
#!/bin/bash

# Vérifier que le projet peut être buildé
if ! npm ci --silent 2>/dev/null; then
  exit 125  # skip ce commit
fi

if ! npm run build --silent 2>/dev/null; then
  exit 125  # skip si le build échoue
fi

# Maintenant tester
npm test -- --testPathPattern="schedule" --silent
EOF
```

## Bisect avec une regex sur les messages de commit

Parfois vous savez que le bug vient d'un certain type de commit :

```bash
# Trouver le premier commit "refactor" qui a introduit le bug
git log --oneline --grep="refactor" main
# Utilisez ces hashes comme points de départ/fin
```

## Visualiser la progression

```bash
# Pendant une session bisect manuelle
git bisect visualize
# Ouvre gitk (GUI) avec les commits restants à tester

git bisect visualize --oneline
# Version texte dans le terminal
```

## Résumé des exit codes

| Code de sortie | Signification |
|---------------|---------------|
| `0` | Good — ce commit ne contient pas le bug |
| `1` à `127` | Bad — ce commit contient le bug |
| `125` | Skip — ce commit ne peut pas être testé |
| `128` à `255` | Erreur fatale — bisect s'arrête |

## Reset propre après bisect

```bash
git bisect reset
# HEAD est de retour sur votre branche d'origine
# Tous les fichiers de session (.git/BISECT_*) sont nettoyés
```
