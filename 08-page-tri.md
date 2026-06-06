# Étape 8 · Page de tri

## Intention

Jusqu'ici tout vit dans la base et les logs.

Il manque l'écran où **toi**, l'humain, tu tranches.

La Page de tri montre la pile du jour (les items `etat='capté'`, avec le verdict de l'IA pour guider l'œil).

Elle te donne deux boutons : **Garder** ou **Jeter**.

C'est le moment où le partage des rôles devient tangible.

L'IA a pré-trié (verdict + ordre).

Mais le clic Garder / Jeter est le **seul acte qui compte**.

Un item `ignorer` reste visible, relégué en bas. Jamais masqué d'office.

Tu gardes la main sur ta propre mémoire.

## Actions · Vérifications · Constatations

### 1. Le serveur de tri tourne, en local sur `127.0.0.1`

Prompt à Claude :

```
App FastAPI : `GET /` sert une page HTML listant les items `etat='capté'` (titre, média, verdict IA, raison), triés pour que les `produire` remontent et les `ignorer` descendent (visibles, jamais masqués). Deux boutons Garder / Jeter par ligne. La pile (`GET`) est publique. L'action (`POST /trier`) derrière un login simple (basic auth, mot de passe dans `.env` sous `TRI_PASSWORD`). Sépare données et affichage : l'UI affiche ce que l'API renvoie, sans savoir si c'est la vraie pile ou une pile de démo. Installe : `uv add fastapi uvicorn`.
```

Lance le serveur :

```bash
uv run uvicorn app:app --host 127.0.0.1 --port 8000
```

Par défaut on écoute sur `127.0.0.1`. La page n'est accessible que depuis ta machine.

C'est le bon défaut. Une page de tri n'a aucune raison d'être ouverte au monde.

**Besoin de trier depuis ton téléphone, sur le même wifi ?**

Là seulement, passe l'hôte à `0.0.0.0` : `--host 0.0.0.0`.

La page devient visible par toutes les machines du réseau local.

À n'utiliser que sur un réseau de confiance. Jamais sur un wifi public (café, coworking).

Sur ta machine, reste sur `127.0.0.1`.

### 2. Tu tranches · Garder/Jeter change l'`etat` en base

C'est ton geste à toi, le seul qui grave.

L'IA a pré-trié, mais le clic compte.

Va sur `http://127.0.0.1:8000`.

Tu vois la pile, verdicts en couleur.

Clique Garder ou Jeter sur quelques lignes.

La preuve : va vérifier sur TablePlus.

L'`etat` de la ligne a changé (passé en `gardé` ou `jeté`).

Tu pilotes ta mémoire, d'un clic.

## Erreurs possibles

### Page vide

Vérifie que l'API renvoie des items.

Réservoir up ? Filtre `etat='capté'` correct ?

Lance un `SELECT COUNT(*) FROM items WHERE etat='capté'` dans TablePlus pour confirmer.

### `uvicorn` introuvable

Lance via `uv run uvicorn ...` pour qu'il tourne dans l'environnement du projet.

Vérifie que `fastapi` et `uvicorn` sont bien ajoutés : `uv add fastapi uvicorn`.

### Les boutons Garder / Jeter ne font rien

Ouvre la console du navigateur (F12) et regarde les erreurs.

Regarde les logs du serveur dans le terminal.

Vérifie la route `POST /trier` côté serveur, et que l'auth est bien passée.

### Tout le monde peut trier (pas d'auth)

Sépare « pile publique » (GET) et « action » (POST) dès le début.

Protège le POST avec basic auth, mot de passe dans `.env` sous `TRI_PASSWORD`.

Ne committe jamais ce mot de passe.
