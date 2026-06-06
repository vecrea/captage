# Étape 4 · Structure commune + Module RSS

## Intention

Deux choses d'un coup, et c'est le tournant du projet.

D'abord on fige la **structure commune** : le format unique que toute source produira, quelle qu'elle soit (texte, image, son).

Une fois cette structure posée, ajouter une source ne veut plus dire « refaire le pipeline ».

Ça veut dire « écrire un petit traducteur qui la remplit ».

Ensuite on le prouve avec la source la plus simple : un flux RSS (Texte, déclencheur automatique).

C'est ici que la première vraie ligne tombe dans le Réservoir.

À la fin de l'étape, tu ne lis plus de la théorie. Tu regardes une pile monter. Pour de vrai.

C'est le premier « ah, ça marche ».

## La structure commune (à graver dans la tête)

```
{ source, titre, contenu, media_url, url, capte_le }
```

C'est la sortie unique de tout module, aujourd'hui et demain.

Le module RSS produit ce format. Le module image aussi. Le module son aussi. Sans exception.

## Actions · Vérifications · Constatations

### 1. La première ligne tombe dans le Réservoir

Prompt à Claude :

```
Définis une interface `Source` avec une méthode `recolter() -> list[Item]`, où `Item` suit exactement cette structure : { source, titre, contenu, media_url, url, capte_le }. Implémente `SourceRSS(url, cadence)` avec `feedparser` : tire le flux, normalise chaque entrée à cette structure, écrit dans le Réservoir avec `ON CONFLICT (url) DO NOTHING`. Ne plante jamais sur une entrée malformée : skip + log dans `JOURNAL.md`. Installe les dépendances : `uv add feedparser psycopg2-binary`. Si `uv` n'est pas installé : `brew install uv` (Mac) ou `winget install astral-sh.uv` (Windows).
```

Donne ensuite à Claude un vrai flux RSS (un blog que tu suis, un média) et demande-lui de lancer `recolter()` une fois.

Exemple de prompt suivant :

```
Lance `SourceRSS("https://example.com/feed").recolter()` une fois.
```

La preuve : retourne sur TablePlus, rafraîchis la table `items`.

Les entrées du flux sont là, avec leur `titre`, leur `url`, leur `capte_le`.

Tu viens de capter, en vrai, pour la première fois.

Garde ce réflexe : à chaque nouveau module, tu reviens regarder la pile monter ici.

## Erreurs possibles

### Feed introuvable ou champ manquant

Valide l'URL d'abord dans ton navigateur.

Ne plante jamais sur une entrée malformée : fallback ou skip, log dans `JOURNAL.md`.

### Encodage ou HTML illisible dans `contenu`

Nettoie : strip HTML, normalise les whitespace.

Fallback sur `summary` si `content` est vide.

### RSS bloqué, rate limit, timeout

Ajoute un timeout et un retry.

Si le site bloque, bascule sur une autre source ou réduis la cadence.

### `uv: command not found`

Installe-le : `brew install uv` (Mac) ou `winget install astral-sh.uv` (Windows).

Ferme et rouvre le terminal.
