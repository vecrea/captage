# Étape 9 · Ajout au CKM & Touches finales

## Intention

Trois finitions qui transforment l'exercice en système.

**Promotion** · le geste Garder ne doit plus seulement changer un état en base. Il doit **graver l'item dans la Vérité** · une page dans Notion (data source K³-CKM ou la database de ton choix). C'est le passage Réservoir → Vérité · l'item promu quitte le brut pour devenir un morceau de mémoire.

**Relevé quotidien** · tes abonnements (étape 4) ne se relèvent que quand tu le demandes. On automatise · un job passe une fois par jour sur tous les abonnements actifs.

**Reproductibilité** · un système qui ne tourne que sur ta machine n'est pas un système, c'est une chance. On dockerise tout, sauf Ollama (natif pour le GPU), et on enrichit le `README.md` pour qu'un inconnu (ou Claude, sur une machine vierge) reconstruise Captage de zéro.

Notion redevient ce qu'il est · un store en aval, remplaçable. Le cœur, lui, reste local.

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
Modifie l'action `POST /trier` de l'étape 8. Sur « Garder » : crée une page dans la database Notion (`NOTION_DB_ID`) à l'état « Qualifié » via l'API Notion, en mappant la structure { source, titre, contenu, url, capte_le } vers les propriétés Notion. Puis passe l'item `etat='promu'` dans le Réservoir. Sur « Jeter » : `etat='rejeté'`. Gèle le mapping structure → Notion à un seul endroit (un dict ou une fonction). Si un champ manque côté Notion, valeur par défaut + log dans `JOURNAL.md`, jamais de crash. Installe : `uv add notion-client`.
```

La preuve : clique « Garder » sur un item dans ta page de tri (`:3333`). Va voir dans Notion · une page est née dans ta database. Sur TablePlus, sa ligne est passée `etat='promu'`.

### 3. Le relevé quotidien des abonnements

Prompt à Claude :

```
Écris `relever_abonnements()` : pour chaque ligne `actif=true` de la table `abonnements`, fait `SourceRSS(url).recolter()` → `reservoir.ecrire(...)`, met à jour `dernier_releve_le`. Idempotent (le `ON CONFLICT (url)` évite les doublons). Puis planifie-le une fois par jour : un cron (`crontab` sur Mac/Linux) ou un service launchd qui lance ce job chaque matin. Logue chaque passage dans `JOURNAL.md`.
```

La preuve : lance le job une fois à la main (`relever_abonnements()`), regarde de nouveaux items tomber dans ta page `:3333`. Puis vérifie que le cron est posé : `crontab -l`.

**Le caveat honnête « tous les jours »** · un cron sur ta machine se déclenche **quand ta machine est allumée** à cette heure-là. Mac en veille = pas de relevé. Pour un « tous les jours » garanti, machine éteinte ou pas, il faut un hôte **toujours allumé** · un petit VPS. C'est un choix d'hébergement, pas un défaut du code · le cœur local marche, le VPS ne fait que garantir l'horaire (même logique que n8n, voir bonus).

### 4. Captage se remonte sur une machine vierge

Prompt à Claude :

```
Dockerise tout SAUF Ollama (qui reste natif sur l'hôte pour le GPU) : Réservoir + worker (RSS, page, image, son, juger, relevé des abonnements) + la page :3333 dans le `docker-compose.yml`. Enrichis le `README.md` existant : ajoute une section « From scratch » qui permet à un nouvel utilisateur de tout relancer sur une machine vierge en partant du clone du repo. Mentionne les prérequis (Docker Desktop, Ollama), les commandes dans l'ordre, l'URL de la page (`:3333`), et les secrets à remplir dans `.env`. Teste-le réellement dans un environnement neuf si possible.
```

Le partage final ressemble à ça :

```bash
# Ollama natif (GPU)
ollama serve

# Le reste en conteneurs (Réservoir + worker + page :3333)
docker compose up -d
```

La preuve : clone le projet sur un environnement neuf (autre machine, ou dossier vide), suis ton propre `README.md`, ouvre `:3333`, et regarde Captage se remonter sans toi. Chaque écart que tu rencontres enrichit le README. C'est ça, un système reproductible.

## Erreurs possibles

### « Marche chez moi, pas chez l'autre »

Chaque écart enrichit le README. C'est le test ultime de reproductibilité, pas un échec.

### Notion : création de page échoue (permissions, schema)

Vérifie que tu écris dans le bon data source (`NOTION_DB_ID`). Vérifie les **noms exacts** des propriétés Notion (sensible à la casse). Vérifie que l'intégration a les droits d'écriture (Connections sur la database).

### Le mapping structure → Notion dérive

Gèle un mapping (dict ou fonction). Teste avec un item minimal d'abord. Si un champ manque côté Notion, valeur par défaut + log, jamais crash.

### Le cron ne se déclenche pas

Vérifie `crontab -l`. Souviens-toi du caveat : il ne tire que machine allumée. Logue chaque passage dans `JOURNAL.md` pour savoir s'il est passé. Pour de l'always-on, vois le bonus VPS.

### Différences Mac / Windows à la dockerisation

Documente les ports (`:3333`, `:5432`), volumes, commandes exactes. Teste sur une machine vierge. Note chaque écart dans le `README.md`.

## Bonus (plus tard)

- **Capture mobile** · t'abonner depuis ton téléphone, sans laptop. L'app Claude (mobile) sait écrire dans Notion · tu poses l'URL dans une DB Notion « Abonnements », et le relevé quotidien la draine vers ta table `abonnements` locale. ⚠️ Ici tu **sors du local** · tu acceptes un sas cloud (Notion) en échange de la capture mobile. C'est un choix assumé, pas le défaut.
- **n8n** · l'automatiseur visuel sans code, auto-hébergé via Docker. Sert uniquement en aval, après la promotion. Inutile avant d'avoir un Inventaire qui tourne.
- Modules **X.com** (API + vision conditionnelle), **YouTube** (galères yt-dlp assumées).
