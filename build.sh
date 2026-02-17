#!/bin/bash

# Chemin du dossier courant
dossier="$PWD"

# Parcourir tous les fichiers .md dans le dossier
for fichier in "$dossier"/*.md; do
    # Vérifier si le fichier existe
    if [ -f "$fichier" ] && [ "$(basename "$fichier")" != "README.md" ] && [ "$(basename "$fichier")" != "program.md" ] && [ "$(basename "$fichier")" != "contributor.md" ]; then
        # Vérifie si le fichier est bien un fichier régulier
        nom_fichier=$(basename "$fichier")
        claat export "$fichier"
        
        # Affiche le message de succès ou d'erreur
        if [ $? -eq 0 ]; then
        echo "Exportation réussie : $nom_fichier"
        else
        echo "Échec de l'exportation : $nom_fichier"
        fi
    fi
done

