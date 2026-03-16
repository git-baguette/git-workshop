---
sidebar_position: 2
---

# git push options — Manipuler GitLab depuis votre CLI

:::warning
Bien que reposant sur une fonctionnalité standard de `git`, ce qui suit ne fonctionne qu'avec GitLab nativement. On peut par contre créer des intégrations ou des hooks qui exploitent les push options.
:::

- Lien vers la documentation Git : https://git-scm.com/docs/git-push#Documentation/git-push.txt--ooption
- Lien vers la documentation GitLab : https://docs.gitlab.com/topics/git/commit/#push-options-for-merge-requests

## Qu'est-ce que les push options ?

Les push options permettent de transmettre des chaînes de caractères personnalisées au serveur Git lors d'un push. Ces options sont passées aux hooks `pre-receive` et `post-receive`. Elles ne doivent pas contenir de caractères NUL ou LF.

Avec GitLab, ces options peuvent être utilisées pour manipuler les merge requests directement depuis la ligne de commande, sans passer par l'interface web.

## Options disponibles pour GitLab

Voici les principales options supportées par GitLab pour les merge requests :

- `merge_request.create` : Crée une merge request au moment du push.
- `merge_request.draft` : Marque la merge request comme brouillon (draft).
- `merge_request.title="Titre personnalisé"` : Définit le titre de la merge request.
- `merge_request.description="Description"` : Définit la description de la merge request.
- `merge_request.target="branche-cible"` : Spécifie la branche cible (par défaut : main).
- `merge_request.auto_merge` : Active l'auto-merge si les conditions sont remplies.
- `merge_request.merge_when_pipeline_succeeds` : Fusionne automatiquement quand le pipeline CI/CD réussit.
- `merge_request.remove_source_branch` : Supprime la branche source après fusion.

## Exemples pratiques

### Créer une merge request simple

```bash
git push -o merge_request.create origin ma-branche
```

### Créer une merge request en draft avec un titre personnalisé

```bash
git push -o merge_request.create -o merge_request.draft -o merge_request.title="feat(front): ma super fonctionnalité" origin ma-branche
```

### Pousser et préparer l'auto-merge

```bash
git push -o merge_request.create -o merge_request.auto_merge -o merge_request.remove_source_branch origin ma-branche
```

## Cheat sheet

```bash
# Créer une MR
git push -o merge_request.create origin/branche

# MR en draft
git push -o merge_request.draft origin/branche

# Titre personnalisé
git push -o merge_request.title="Mon titre" origin/branche

# Auto-merge activé
git push -o merge_request.auto_merge origin/branche

# Combinaison complète
git push -u origin ma-branche \
  -o merge_request.create \
  -o merge_request.draft \
  -o merge_request.title="feat: nouvelle feature" \
  -o merge_request.description="Description détaillée"
```
