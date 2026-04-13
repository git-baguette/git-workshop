#!/bin/bash

# Script pour créer la branche feature/responsive-nav avec l'historique décrit dans rebase/interactive.md
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