# Étape 3 · Le Réservoir + ta première page

## Intention

Avant de capter quoi que ce soit, il faut un endroit où l'eau patiente.

Le Réservoir, c'est une base Postgres jetable. Une seule table `items` où chaque source vient déposer ses trouvailles en vrac, avant tout tri.

On la dresse maintenant, tôt, parce que tout le reste écrit dedans. Sans Réservoir, les modules suivants n'ont nulle part où poser leurs lignes.

« Jetable » est un mot important : si la table part en vrille, tu la recrées en dix secondes. La Vérité, elle, ne vit pas ici. Elle vivra en aval, dans Notion (étape 9). Ici on accumule du brut, sans peur de le casser.

Et surtout, deuxième moitié de l'étape : **ta page naît**. Une petite page web locale sur `localhost:3333` qui montre le Réservoir. Même vide, tu l'ouvres dans ton navigateur et tu vois TON app tourner. C'est ton premier vrai « ça marche ». À partir d'ici, ta fenêtre c'est cette page · TablePlus passe inspecteur sous le capot.

## Pourquoi Postgres et pas autre chose

3 raisons structurelles :

1. **Dédup baked** : `url TEXT UNIQUE` + `ON CONFLICT DO NOTHING`. Pas de bricolage.
2. **Machine à états** : la colonne `etat` transitionne 100 fois par jour sans casse.
3. **Concurrence** : RSS auto + page captée + image au clic écrivent en parallèle sans conflit.

Notion ou des fichiers md ne donnent rien de tout ça nativement. Le bon outil au bon endroit.

## Actions · Vérifications · Constatations

### 1. Docker Desktop est installé et lancé

Docker, c'est le moteur qui fait tourner le Réservoir dans sa bulle isolée. Installe **Docker Desktop** (le paquet qui fournit le moteur et le CLI d'un coup) depuis https://www.docker.com/products/docker-desktop/ · même logique que VS Code à l'étape 1, un download GUI, tu acceptes les défauts. Sur Windows, même page (ou `winget install Docker.DockerDesktop`).

**Lance l'app et laisse-la tourner en fond** (icône baleine dans la barre de menus) · sans elle, le daemon est éteint et toutes les commandes `docker` échouent. Tu piloteras tout au terminal · le GUI ne sert qu'à voir d'un coup d'œil que c'est vert.

La preuve, le moteur répond :

```bash
docker ps   # « CONTAINER ID … » (liste vide) = le daemon tourne
```

### 2. Le conteneur `reservoir` tourne · la table `items` existe, vide

Le Réservoir tient dans un seul fichier `docker-compose.yml` :

```yaml
services:
  reservoir:
    image: postgres:16
    environment: { POSTGRES_PASSWORD: captage, POSTGRES_DB: captage }
    ports: ["5432:5432"]
    volumes: ["reservoir_data:/var/lib/postgresql/data"]
volumes: { reservoir_data: {} }
```

Et la table qui va recevoir l'eau :

```sql
CREATE TABLE items (
  id SERIAL PRIMARY KEY,
  source TEXT,
  titre TEXT,
  contenu TEXT,
  media_url TEXT,
  url TEXT UNIQUE,
  capte_le TIMESTAMPTZ DEFAULT now(),
  verdict TEXT,
  raison TEXT,
  etat TEXT DEFAULT 'capté'
);
```

Note le `url TEXT UNIQUE`. La dédup est dans le design, pas un rattrapage.

Prompt à Claude :

```
Crée `docker-compose.yml` avec le service `reservoir` Postgres 16 (specs ci-dessus). Lance le conteneur. Crée la table `items` avec le schema ci-dessus. Toutes les écritures futures utiliseront `ON CONFLICT (url) DO NOTHING`. Mets à jour `CLAUDE.md` à la section ## Environnement détecté avec « Postgres : conteneur "reservoir" sur :5432 ». Montre-moi les commandes avant de les lancer.
```

La preuve :

```bash
docker compose ps   # le service "reservoir" doit être "running"
```

### 3. Ta page tourne sur `localhost:3333`

C'est ta fenêtre à toi. Une page web locale, minimale, qui lit le Réservoir et l'affiche. Pour l'instant elle dira « 0 item » · et c'est exactement le but : voir l'app vivante avant même qu'elle serve à quelque chose.

Prompt à Claude :

```
Monte une petite app web FastAPI dans `app.py`. Mets en place l'environnement Python avec `uv` (`uv add fastapi uvicorn psycopg2-binary`). `GET /` sert une page HTML qui liste les items du Réservoir (titre, source, capté le) en lecture seule, lue depuis Postgres (connexion lue depuis `.env`). Si la table est vide, affiche « Réservoir : 0 item ». L'app tourne sur le port 3333. Ajoute la convention « le front tourne sur :3333 » dans `CLAUDE.md`, et `PORT=3333` dans `.env`.
```

Lance-la :

```bash
uv run uvicorn app:app --host 127.0.0.1 --port 3333
```

La preuve : ouvre **http://localhost:3333** dans ton navigateur. Tu vois ta page, « Réservoir : 0 item ». Elle est moche, elle est vide, et c'est **ton app qui tourne**. Voilà le premier « ça marche ».

### 4. TablePlus, l'inspecteur sous le capot (optionnel)

Quand tu voudras regarder la base à cru (debug), installe TablePlus (Mac/Windows) ou DBeaver. Connecte-toi à `localhost:5432`, database `captage`, user `postgres`, password `captage`. Tu y verras la table `items`. Mais ta vraie fenêtre, désormais, c'est `:3333`.

## Erreurs possibles

### `docker: command not found` ou « Cannot connect to the Docker daemon »

Deux cas. Soit Docker Desktop n'est pas installé (`command not found`) : pose-le depuis https://www.docker.com/products/docker-desktop/, lance l'app, puis ferme et rouvre le terminal. Soit il est installé mais l'app n'est pas lancée (« Cannot connect to the daemon ») : ouvre Docker Desktop, attends qu'elle passe au vert, relance `docker compose up`. Le daemon doit tourner en fond ; ce n'est pas optionnel.

### Conteneur up mais refuse les connexions

Lis les logs : `docker logs reservoir`. Vérifie les credentials (`POSTGRES_PASSWORD`) et le mapping de port (`5432:5432`).

### Port 5432 déjà utilisé

Quelque chose tourne déjà sur 5432 (probablement un Postgres installé en natif). Change le port dans `docker-compose.yml` : `"5433:5432"`. Mets à jour `CLAUDE.md`.

### Les données « disparaissent » après un redémarrage

Tu n'as pas de volume, ou tu l'as renommé. Vérifie la section `volumes:` et que `reservoir_data` existe. Attention : `docker compose down -v` supprime le volume.

### La page `:3333` ne charge pas

Le serveur tourne ? Il faut qu'`uv run uvicorn app:app --host 127.0.0.1 --port 3333` reste lancé dans un terminal ouvert. `uv` introuvable → `brew install uv` (Mac) / `winget install astral-sh.uv` (Windows), ferme et rouvre le terminal.

### Le port 3333 est déjà pris

Un autre process écoute sur 3333. Arrête-le, ou change le port (`--port 3334`) et note-le dans `.env` (`PORT`). Reteste.
