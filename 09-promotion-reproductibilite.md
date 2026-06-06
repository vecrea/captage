# Étape 9 · Promotion + run from scratch

## Intention

Deux finitions qui transforment l'exercice en système.

La première : le geste Garder ne doit plus seulement changer un état en base.

Il doit **graver l'item dans la Vérité**.

Ici, une page dans Notion (data source K³-CKM ou la database de ton choix).

C'est le passage Réservoir → Vérité.

L'item promu quitte le brut pour devenir un morceau de mémoire.

La seconde : la **reproductibilité**.

Un système qui ne tourne que sur ta machine n'est pas un système. C'est une chance.

On dockerise tout, sauf Ollama (qui reste natif sur l'hôte pour le GPU).

Et on enrichit le `README.md` du repo pour qu'un inconnu (ou Claude, sur une machine vierge) reconstruise Captage de zéro en suivant les étapes.

Notion redevient ce qu'il est : un store en aval, remplaçable.

Le cœur, lui, reste local.

## Actions · Vérifications · Constatations

### 1. Setup Notion (intégration + database)

Avant le code, prépare Notion :

1. Crée une intégration sur https://www.notion.so/profile/integrations
2. Copie le token, mets-le dans `.env` : `NOTION_TOKEN=secret_xxx`
3. Crée (ou choisis) une database Notion qui recevra la Vérité. Propriétés minimales : `Titre` (title), `Source` (select), `URL` (url), `État` (select avec au moins « Qualifié »), `Capté le` (date)
4. Partage la database avec ton intégration (menu `...` → Connections)
5. Copie le data source ID de la database, mets-le dans `.env` : `NOTION_DB_ID=xxx`

Mets à jour `CLAUDE.md` à la section ## Environnement détecté : « Notion : data source `NOTION_DB_ID` ».

### 2. Garder grave une page dans Notion · l'item passe `promu`

Prompt à Claude :

```
Modifie l'action `POST /trier` de l'étape 8. Sur « Garder » : crée une page dans la database Notion (`NOTION_DB_ID`) à l'état « Qualifié » via l'API Notion, en mappant la structure `{ source, titre, contenu, url, capte_le }` vers les propriétés Notion. Puis passe l'item `etat='promu'` dans le Réservoir. Sur « Jeter » : `etat='rejeté'`. Gèle le mapping `structure → Notion` à un seul endroit (un dict ou une fonction). Si un champ manque côté Notion, valeur par défaut + log dans `JOURNAL.md`, jamais de crash. Installe : `uv add notion-client`.
```

La preuve : clique « Garder » sur un item dans ta page de tri.

Va voir dans Notion. Une page est née dans ta database.

Sur TablePlus, sa ligne est passée `etat='promu'`.

### 3. Captage se remonte sur une machine vierge

Prompt à Claude :

```
Dockerise tout SAUF Ollama (qui reste natif sur l'hôte pour le GPU) : Réservoir + worker (RSS, image, son, juger) + page de tri dans le `docker-compose.yml`. Enrichis le `README.md` existant : ajoute une section « From scratch » qui permet à un nouvel utilisateur de tout relancer sur une machine vierge en partant du clone du repo. Mentionne les prérequis (Docker Desktop, Ollama), les commandes dans l'ordre, et les secrets à remplir dans `.env`. Teste-le réellement dans un environnement neuf si possible.
```

Le partage final ressemble à ça :

```bash
# Ollama natif (GPU)
ollama serve

# Le reste en conteneurs
docker compose up -d
```

La preuve : clone le projet sur un environnement neuf (autre machine, ou dossier vide), suis ton propre `README.md`, et regarde Captage se remonter sans toi.

Chaque écart que tu rencontres enrichit le README.

C'est ça, un système reproductible.

## Erreurs possibles

### « Marche chez moi, pas chez l'autre »

Chaque écart enrichit le README.

C'est le test ultime de reproductibilité, pas un échec.

### Notion : création de page échoue (permissions, schema)

Vérifie que tu écris dans le bon data source (`NOTION_DB_ID`).

Vérifie les **noms exacts** des propriétés Notion (sensible à la casse).

Vérifie que l'intégration a les droits d'écriture (Connections sur la database).

### Le mapping structure → Notion dérive

Gèle un mapping (dict ou fonction).

Teste avec un item minimal d'abord.

Si un champ manque côté Notion, valeur par défaut + log, jamais crash.

### Différences Mac / Windows à la dockerisation

Documente les ports, volumes, commandes exactes.

Teste sur une machine vierge.

Note chaque écart dans le `README.md`.

## Bonus (plus tard, sous forme de vidéos YouTube)

- Module **X.com** (API + vision conditionnelle)
- Module **YouTube** (galères yt-dlp assumées)
- **n8n** : l'automatiseur visuel sans code, auto-hébergé via Docker. Il sert uniquement en aval, pour déclencher des actions après la promotion. Inutile de l'installer avant d'avoir un Inventaire qui tourne.
