---
sidebar_position: 5
---

# git hook — Automatiser des tâches répétitives

Les hooks Git permettent d'exécuter automatiquement des scripts à des moments clés du workflow Git (commit, push, etc.). Ils sont stockés dans le dossier `.git/hooks/` et doivent être exécutables.

## Avantages et inconvénients

- **Gagner en efficacité** : Automatisez des tâches comme le formatage de code ou la validation de messages de commit.
- **Créer de la friction** : Si les hooks sont lents (ex. : ne lancez pas les tests unitaires), ils ralentissent le workflow.
- **Setup individuel** : Chaque développeur doit installer les hooks sur sa machine.
- **Templates** : Utilisez `git init --template` pour pré-installer des hooks sur tous les nouveaux dépôts.

:::warning
Les hooks sont locaux : ils ne sont pas partagés avec l'équipe. Pour une cohérence d'équipe, utilisez des outils comme Husky ou des CI/CD.
:::

## Hooks courants

- `pre-commit` : Avant le commit, pour valider le code (formatage, tests légers).
- `commit-msg` : Après la saisie du message, pour le valider (conventional commits).
- `pre-push` : Avant le push, pour vérifier les commits ou lancer des tests.
- `post-commit` : Après le commit, pour notifications (ex. : envoi d'email).

Les hooks côté serveur (pre-receive, post-receive) sont pour les dépôts bare, comme sur GitLab/GitHub.

## Exercice : Setup d'un hook pre-commit pour valider les commits

Créons un hook qui refuse les commits avec des messages ne respectant pas les conventional commits.

### Étape 1 : Créer le hook

```bash
# Aller dans le dossier hooks
cd .git/hooks

# Créer le fichier pre-commit
cat > pre-commit << 'EOF'
#!/bin/sh

# Lire le message du commit
MSG=$(cat "$1")

# Pattern pour conventional commits
PATTERN="^(feat|fix|docs|refactor|test|chore|ci|perf)(\(.+\))?: .+"

if ! echo "$MSG" | grep -qE "$PATTERN"; then
  echo "❌ Message de commit invalide !"
  echo "Utilisez le format : <type>(<scope>): <description>"
  echo "Exemples : feat: add login, fix(ui): resolve button bug"
  exit 1
fi

echo "✅ Message de commit valide"
EOF

# Rendre exécutable
chmod +x pre-commit
```

### Étape 2 : Tester le hook

```bash
# Essayer un commit avec un mauvais message
git commit -m "bad commit"

# Devrait afficher l'erreur et annuler le commit

# Essayer avec un bon message
git commit -m "feat: add user authentication"

# Devrait réussir
```

### Étape 3 : Contourner le hook (si nécessaire)

Pour forcer un commit malgré le hook :

```bash
git commit --no-verify -m "urgent fix"
```

## Cheat sheet

```bash
# Lister les hooks disponibles
ls .git/hooks/

# Rendre un hook exécutable
chmod +x .git/hooks/pre-commit

# Désactiver un hook temporairement
git commit --no-verify

# Utiliser un template pour nouveaux dépôts
git config --global init.templateDir ~/mon-template-hooks
mkdir -p ~/mon-template-hooks/hooks
# Copiez vos hooks dans ce dossier
```
