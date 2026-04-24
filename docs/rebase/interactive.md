---
sidebar_position: 2
---

# Rebase interactif — Réécrire l'histoire

Le rebase interactif (`git rebase -i`) est l'outil le plus puissant pour **nettoyer un historique** avant de pousser. Il vous permet de modifier, fusionner, réordonner et supprimer des commits comme si vous réécriviez le scénario d'un film.

## Les actions disponibles

Quand vous lancez `git rebase -i`, Git ouvre un éditeur avec une liste de commits et des actions :

```
pick a1b2c3 feat(nav): add responsive navigation
pick b2c3d4 fix typo in Header.astro
pick c3d4e5 feat(nav): add drawer for mobile
pick d4e5f6 WIP: broken, dont merge
pick e5f6a7 fix: actually make drawer close
```

| Commande                | Alias | Effet                                                                         |
| ----------------------- | ----- | ----------------------------------------------------------------------------- |
| `pick`                  | `p`   | Garder le commit tel quel                                                     |
| `reword`                | `r`   | Garder le commit, modifier le message                                         |
| `edit`                  | `e`   | S'arrêter pour modifier le contenu du commit                                  |
| `squash`                | `s`   | Fusionner avec le commit précédent, combiner les messages                     |
| `fixup`                 | `f`   | Fusionner avec le commit précédent, **garder seulement le message précédent** |
| `drop`                  | `d`   | Supprimer le commit                                                           |
| (réordonner les lignes) |       | Réordonner les commits                                                        |

## Exercice — `git commit --amend` — cas simple

Pour préparer le TP, créez un historique simple avec un dernier commit à amender :

```bash
echo "Contenu initial" > docs/notes.md
git add docs/notes.md
git commit -m "docs: add notse"
```

Pour modifier uniquement le dernier commit (avant de pusher) :

```bash
# Modifier le message du dernier commit
git commit --amend -m "docs: add notes"

# Ajouter un fichier oublié au dernier commit
echo "Contenu initial" > docs/notes2.md
git add docs/notes2.md
git commit --amend --no-edit  # garde le même message
```

:::warning
`--amend` réécrit le commit (nouveau SHA). Ne jamais amender un commit déjà pushé sur une branche partagée.
:::

## Exercice — Supprimer un commit

Pour préparer le TP, utilisez ce script simple :

```bash
mkdir -p src
echo "API_KEY=secret-123" >> src/credentials.txt
git add src/credentials.txt
git commit -m "add credentials file"

echo "Project notes" > README.md
git add README.md
git commit -m "docs: add README"
```

Vous avez commité des credentials ou du code qu'il ne fallait pas :

```bash
# Voir l'historique
git log --oneline -5

# Supprimer le commit coupable avec drop
git rebase -i HEAD~N
# Changez "pick" en "drop" sur la ligne concernée
```

:::warning Attention
Si le commit à supprimer modifie des fichiers que des commits suivants utilisent, `drop` créera des conflits. Résolvez-les normalement avec `git rebase --continue`.
:::

## Exercice — Squash/Fixup de commits WIP

Pour préparer le TP, créez cet historique :

```bash
mkdir -p src
cat > src/social-links.md <<'EOF'
- Twitter: @yatho
- LinkedIn: linkedin.com/in/example
EOF
git add src/social-links.md
git commit -m "feat: add social links (Bluesky, Twitter, LinkedIn)"

sed -i 's/linkedin.com\/in\/example/linkedin.com\/in\/yatho/' src/social-links.md
git add src/social-links.md
git commit -m "fix: correct LinkedIn URL"

echo "v1.0.0" > RELEASE.md
git add RELEASE.md
git commit -m "chore: release v1.0.0"
```

Scénario fréquent : vous avez commité en cours de route avec des messages `wip`, `fix`, `oups`.

```bash
# Voir les 5 derniers commits sur main
git log --oneline -5
```

Fusionner les 3 derniers commits en un seul :

```bash
git rebase -i HEAD~3
```

Mettez le second commit en `squash` et le troisième en `fixup` :

```
pick   abc123 feat: add social links (Bluesky, Twitter, LinkedIn)
squash  def456 fix: correct LinkedIn URL
fixup  ghi789 chore: release v1.0.0
```

:::tip `fixup` vs `squash`

- `fixup` : garde le message du commit au-dessus, jette le reste
- `squash` : vous demande de combiner les messages → ouvre l'éditeur
  :::

## `--autosquash` : le raccourci magique

Si vous commitez avec le préfixe `fixup!` ou `squash!` suivi du message de la cible, Git prépare le rebase automatiquement :

```bash
# Commit normal
git commit -m "feat: add Agenda component"

# Plus tard, fix à fusionner avec ce commit
git commit -m "fixup! feat: add Agenda component"

# Rebase avec autosquash
git rebase -i --autosquash main
# Git place automatiquement le fixup au bon endroit !
```

Combiner avec un alias :

```bash
git config --global alias.fixup 'commit --fixup'
git fixup HEAD~2  # crée un commit fixup! pour HEAD~2
```

## Exercice — Réordonner des commits

Pour préparer ce TP, utilisez ce script :

```bash
mkdir -p src
cat > src/Speaker.astro <<'EOF'
<div class="speaker">Speaker component</div>
EOF
git add src/Speaker.astro
git commit -m "feat: add Speaker component"

cat > src/CFP.astro <<'EOF'
<div class="cfp">Page CFP</div>
EOF
git add src/CFP.astro
git commit -m "feat: add CFP page"

echo "<style>.speaker img { width: 100px; }</style>" >> src/Speaker.astro
git add src/Speaker.astro
git commit -m "fix: fix Speaker avatar size"

echo "schedule tests" > src/schedule-tests.txt
git add src/schedule-tests.txt
git commit -m "test: add schedule tests"
```

Parfois vous voulez changer l'ordre pour grouper des changements logiquement :

```bash
git rebase -i HEAD~4
```

```
# Avant :
pick a feat: add Speaker component
pick b feat: add CFP page
pick c fix: fix Speaker avatar size
pick d test: add schedule tests

# Après (réordonner + squash) :
pick a feat: add Speaker component
fixup c fix: fix Speaker avatar size
pick b feat: add CFP page
drop  d test: add schedule tests
```

## Exercice — Nettoyer l'historique de feature/responsive-nav

### Situation de départ

La branche `feature/responsive-nav` ressemble à ça dans la vraie vie :

```bash
cd $WORKSHOP_DIR
git switch feature/responsive-nav

# Ce qu'on aimerait voir sur la branche
git log --oneline feature/responsive-nav ^main
# e.g.:
# a1b2c3 feat(nav): replace dropdown with drawer for mobile navigation
```

Ajoutons l'historique réaliste d'une vraie session de travail :

```bash
#!/bin/bash

# Script pour créer la branche feature/responsive-nav avec un historique de travail
# À exécuter depuis le répertoire racine du repo git-workshop-starter

set -e  # Arrêter en cas d'erreur

echo "Création de la branche feature/responsive-nav..."

# Assumer qu'on est sur main
git switch main

# Créer la branche
git switch -C feature/responsive-nav

# Premier commit : feat(nav): replace dropdown with drawer for mobile navigation
# Simuler en créant/modifiant un fichier de base
mkdir -p src/components
cat > src/components/Drawer.astro << 'EOF'
---
// Composant Drawer de base pour la navigation mobile
---

<div id="mobile-nav-drawer" class="drawer">
  <!-- Contenu du drawer -->
</div>
EOF
git add src/components/Drawer.astro
git commit -m "feat(nav): replace dropdown with drawer for mobile navigation"

# Commit 2 : close on ESC
cat >> src/components/Drawer.astro << 'EOF'

<script>
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      const cb = document.getElementById('mobile-nav') as HTMLInputElement | null;
      if (cb) cb.checked = false;
    }
  });
</script>
EOF
git add .
git commit -m "close on ESC"

# Commit 3 : add focus trap comment
cat >> src/components/Header.astro << 'EOF'
<!-- focus trap à ajouter -->
EOF
git add .
git commit -m "add focus trap comment"

# Commit 4 : fix bug
# Supprimer le commentaire ajouté précédemment
sed -i 's/<!-- focus trap à ajouter -->//' src/components/Header.astro
git add .
git commit -m "fix bug"

# Commit 5 : wip
echo "" >> src/components/Drawer.astro
git add .
git commit -m "wip"

# Commit 6 : done I think
git commit --allow-empty -m "done I think"

echo "Branche feature/responsive-nav créée avec succès."
echo "Historique :"
git log --oneline feature/responsive-nav ^main
```

L'historique est maintenant honteux :

```bash
git log --oneline feature/responsive-nav ^main
# 5f6a7b8 done I think
# 4e5f6a7 wip
# 3d4e5f6 fix bug
# 2c3d4e5 add focus trap comment
# 1b2c3d4 close on ESC
# a9b0c1d feat(nav): replace dropdown with drawer for mobile navigation
```

### Nettoyer avec rebase -i

```bash
# Ouvrir le rebase interactif sur tous les commits depuis main
git rebase -i main
```

L'éditeur s'ouvre avec :

```
pick a9b0c1d feat(nav): replace dropdown with drawer for mobile navigation
pick 1b2c3d4 close on ESC
pick 2c3d4e5 add focus trap comment
pick 3d4e5f6 fix bug
pick 4e5f6a7 wip
pick 5f6a7b8 done I think
```

Modifiez-le pour obtenir :

```
reword a9b0c1d feat(nav): replace dropdown with drawer for mobile navigation
fixup  1b2c3d4 close on ESC
drop   2c3d4e5 add focus trap comment
fixup  3d4e5f6 fix bug
fixup  4e5f6a7 wip
fixup  5f6a7b8 done I think
```

Sauvegardez et quittez. Git vous demandera de reword le premier commit :

```
feat(nav): replace dropdown with drawer for mobile navigation
```

Corrigez en :

```
feat(nav): replace dropdown with accessible drawer (mobile)
```

### Résultat final

```bash
git log --oneline feature/responsive-nav ^main
# a9b0c1d feat(nav): replace dropdown with accessible drawer (mobile)
```

Six commits douteux → un seul commit propre qui raconte une histoire claire.
