# Étape 3 · Réservoir Postgres

## Intention

Avant de capter quoi que ce soit, il faut un endroit où l'eau patiente.

Le Réservoir, c'est une base Postgres jetable.

Une seule table `items` où chaque source vient déposer ses trouvailles en vrac, avant tout tri.

On la dresse maintenant, tôt, parce que tout le reste écrit dedans.

Sans Réservoir, les modules suivants n'ont nulle part où poser leurs lignes.

« Jetable » est un mot important : si la table part en vrille, tu la recrées en dix secondes.

La Vérité, elle, ne vit pas ici. Elle vivra en aval, dans Notion (étape 9).

Ici on accumule du brut, sans peur de le casser.

## Pourquoi Postgres et pas autre chose

3 raisons structurelles :

1. **Dédup baked** : `url TEXT UNIQUE` + `ON CONFLICT DO NOTHING`. Pas de bricolage.
2. **Machine à états** : la colonne `etat` transitionne 100 fois par jour sans casse.
3. **Concurrence** : RSS auto + podcast manuel + image au clic écrivent en parallèle sans conflit.

Notion ou des fichiers md ne donnent rien de tout ça nativement.

Le bon outil au bon endroit.

## Actions · Vérifications · Constatations

### 1. Le conteneur `reservoir` tourne · la table `items` existe, vide

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

Prérequis : **Docker Desktop installé et lancé** (icône baleine dans la barre de menus). Sans le daemon qui tourne, `docker compose` échoue. Le prompt ci-dessous demande à Claude d'installer Docker s'il manque ; à toi de **lancer l'app** ensuite.

Prompt à Claude :

```
Crée `docker-compose.yml` avec le service `reservoir` Postgres 16 (specs ci-dessus). Lance le conteneur. Crée la table `items` avec le schema ci-dessus. Toutes les écritures futures utiliseront `ON CONFLICT (url) DO NOTHING`. Mets à jour `CLAUDE.md` à la section ## Environnement détecté avec « Postgres : conteneur "reservoir" sur :5432 ». Si tu installes Docker (Mac : `brew install --cask docker`, Windows : `winget install Docker.DockerDesktop`), précise-le. Montre-moi les commandes avant de les lancer.
```

La preuve :

```bash
docker compose ps   # le service "reservoir" doit être "running"
```

### 2. Tu vois la table dans une UI

Installe TablePlus (Mac/Windows) ou DBeaver (multi-plateforme, gratuit).

Connecte-toi à `localhost:5432`.

Database : `captage`. User : `postgres`. Password : `captage`.

Tu dois voir la table `items`, vide.

C'est l'écran que tu garderas ouvert pour les étapes suivantes.

## Erreurs possibles

### `docker: command not found` ou « Cannot connect to the Docker daemon »

Deux cas. Soit Docker Desktop n'est pas installé (`command not found`) : laisse Claude l'installer via le prompt, ou pose-le depuis https://www.docker.com/products/docker-desktop/, puis ferme et rouvre le terminal. Soit il est installé mais l'app n'est pas lancée (« Cannot connect to the daemon ») : ouvre Docker Desktop, attends qu'elle passe au vert, relance `docker compose up`. Le daemon doit tourner en fond ; ce n'est pas optionnel.

### Conteneur up mais refuse les connexions

Lis les logs : `docker logs reservoir`.

Vérifie les credentials (`POSTGRES_PASSWORD`) et le mapping de port (`5432:5432`).

### Port 5432 déjà utilisé

Quelque chose tourne déjà sur 5432 (probablement un Postgres installé en natif).

Change le port dans `docker-compose.yml` : `"5433:5432"`.

Mets à jour `CLAUDE.md` en conséquence.

### Les données « disparaissent » après un redémarrage

Tu n'as pas de volume, ou tu l'as renommé.

Vérifie la section `volumes:` et que `reservoir_data` existe.

Attention : `docker compose down -v` supprime le volume.
