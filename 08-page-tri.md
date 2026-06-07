# Étape 8 · La page de tri · tu tranches

## Intention

Ta page existe depuis l'étape 3. Elle a grandi : elle montre les items, leur source, le verdict de l'IA. Il lui manque le geste qui compte vraiment · **toi qui tranches**.

L'IA a pré-trié (verdict + ordre). Mais le clic **Garder / Jeter** est le seul acte qui grave.

On n'ajoute donc pas une nouvelle page. On **ajoute les actions** à celle qui tourne déjà sur `:3333`.

Un item `ignorer` reste visible, relégué en bas. Jamais masqué d'office. Tu gardes la main sur ta propre mémoire.

## Actions · Vérifications · Constatations

### 1. Les actions Garder / Jeter, sur ta page existante

Prompt à Claude :

```
Sur ma page :3333 (celle des étapes 3-5) : ajoute deux boutons Garder / Jeter par ligne, et des filtres « à trier / gardés / jetés » en haut. Trie pour que les `produire` remontent et les `ignorer` descendent (visibles, jamais masqués). « Garder » → `etat='gardé'`, « Jeter » → `etat='jeté'` dans le Réservoir. La pile (`GET`) reste publique ; l'action (`POST /trier`) passe derrière un login simple (basic auth, mot de passe dans `.env` sous `TRI_PASSWORD`). Garde la séparation données/affichage : l'UI affiche ce que l'API renvoie.
```

Rappel · ta page tourne sur **:3333** :

```bash
uv run uvicorn app:app --host 127.0.0.1 --port 3333
```

Par défaut on écoute sur `127.0.0.1` · la page n'est visible que depuis ta machine. C'est le bon défaut · une page de tri n'a aucune raison d'être ouverte au monde.

### 2. Tu tranches · Garder/Jeter change l'`etat`

Va sur **http://localhost:3333**. Tu vois la pile, verdicts en couleur. Clique Garder ou Jeter sur quelques lignes.

La preuve : la ligne change d'`etat` (`gardé` ou `jeté`) · visible dans ta page (via le filtre) et dans TablePlus si tu veux vérifier sous le capot.

Tu pilotes ta mémoire, d'un clic. L'IA a dégrossi, mais le geste est à toi.

### (Optionnel) Trier depuis ton téléphone, sur le même wifi

Besoin de trier depuis ton tél ? Passe l'hôte à `0.0.0.0` (`--host 0.0.0.0`) · la page devient visible par les machines du réseau local. À n'utiliser que sur un **réseau de confiance**, jamais un wifi public (café, coworking). Sur ta machine, reste sur `127.0.0.1`.

## Erreurs possibles

### Page vide

Vérifie que l'API renvoie des items. Réservoir up ? Filtre `etat='capté'` correct ? Lance `SELECT COUNT(*) FROM items WHERE etat='capté'` dans TablePlus pour confirmer.

### Les boutons Garder / Jeter ne font rien

Ouvre la console du navigateur (F12) et regarde les erreurs. Regarde les logs du serveur dans le terminal. Vérifie la route `POST /trier` et que l'auth est bien passée.

### Tout le monde peut trier (pas d'auth)

Sépare « pile publique » (GET) et « action » (POST) dès le début. Protège le POST avec basic auth, mot de passe dans `.env` sous `TRI_PASSWORD`. Ne committe jamais ce mot de passe.

### Le port 3333 est déjà pris

Un autre process écoute sur 3333. Arrête-le, ou change le port (`--port 3334`) et note-le dans `.env` (`PORT`). Reteste.
