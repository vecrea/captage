# Étape 4 · Structure commune + premières sources · ta page s'allume

## Intention

Le tournant du projet. Deux idées, puis ta page prend vie.

D'abord on fige la **structure commune** : le format unique que TOUTE source produira, quelle qu'elle soit (RSS, page web, image, son). Une fois cette structure posée, ajouter une source ne veut plus dire « refaire le pipeline ». Ça veut dire « écrire un petit traducteur qui la remplit ».

Ensuite on pose la **séparation propre** : une source *récolte* (elle retourne des items), le Réservoir *écrit* (il persiste). La source ne connaît jamais Postgres.

Et on le prouve avec deux sources d'un coup : un **flux RSS** (tu t'abonnes) et une **page web simple** (tu captes). À la fin, tu colles une URL dans TA page (`:3333`) et du contenu réel tombe sous tes yeux.

C'est le gros « ah, ça marche ».

## La structure commune (à graver dans la tête)

```
{ source, titre, contenu, media_url, url, capte_le }
```

La sortie unique de tout module, aujourd'hui et demain. Le module RSS produit ce format. La page web aussi. L'image aussi. Le son aussi. Sans exception.

## S'abonner ou capter · deux gestes, un seul Réservoir

- **S'abonner** · un flux RSS · tu colles l'URL une fois, c'est relevé en continu (le relevé automatique quotidien arrive à l'étape 9). C'est un **abonnement**.
- **Capter** · une page web simple, un fichier · tu déclenches une fois, sur le moment. C'est **ponctuel**.

Les deux produisent le même `Item` et finissent dans le même Réservoir. Seul le déclencheur change.

## Actions · Vérifications · Constatations

### 1. L'interface des sources, et le writer du Réservoir (séparés)

C'est le cœur de l'archi. Une source RETOURNE des items. Un seul writer les ÉCRIT. Ne mélange jamais les deux.

Prompt à Claude :

```
Définis l'interface `Source` : une méthode `recolter() -> list[Item]`, où `Item` suit exactement la structure { source, titre, contenu, media_url, url, capte_le }. `recolter()` est PUR : il RETOURNE des items, il ne touche jamais à la base. Sépare la persistance : écris `reservoir.ecrire(items)` qui insère dans la table `items` avec `ON CONFLICT (url) DO NOTHING`. C'est le SEUL endroit qui parle à Postgres. Range les sources dans `sources/` (`sources/base.py` = l'interface) et le writer dans `reservoir.py`.
```

Le découpage à retenir :

```
sources/base.py   → le contrat : Source.recolter() -> list[Item]   (pur)
sources/rss.py    → SourceRSS, sources/page.py → SourcePage, …      (un fichier par source)
reservoir.py      → ecrire(items)   ON CONFLICT (url) DO NOTHING    (le seul à parler à la base)
```

### 2. Le flux RSS · tu t'abonnes

Prompt à Claude :

```
Implémente `SourceRSS(url)` avec `feedparser` (`uv add feedparser`) : tire le flux, normalise chaque entrée à la structure commune, RETOURNE une `list[Item]`. Ne plante JAMAIS sur une entrée malformée : skip + log dans `JOURNAL.md`. Nettoie le `contenu` (strip HTML, fallback sur `summary` si `content` vide). Crée la table `abonnements( id, type, url, cadence, actif, dernier_releve_le )`. Écris `abonner(url)` : insère l'URL dans `abonnements` (actif=true), puis fait une première récolte tout de suite (`SourceRSS(url).recolter()` → `reservoir.ecrire(...)`) pour que ça tombe immédiatement.
```

Donne un vrai flux à Claude (un blog que tu suis, un média) et demande-lui d'abonner :

```
Abonne-moi à https://korben.info/feed
```

### 3. La page simple · tu captes (la preuve que l'interface paie)

Une page web normale n'est pas un flux. C'est juste une **autre Source**. Et l'ajouter coûte presque rien · c'est exactement la promesse de la structure commune.

Prompt à Claude :

```
Implémente `SourcePage(url)` : fetch le HTML, extrait titre + contenu lisible avec `trafilatura` (`uv add trafilatura`), retourne UN `Item`. Même interface `recolter() -> list[Item]`, même `reservoir.ecrire()`. Écris `capter(url)` : un one-shot qui récolte une page et l'écrit, SANS l'enregistrer dans `abonnements`.
```

### 4. Ta page s'allume · le champ URL

Prompt à Claude :

```
Sur ma page :3333 (l'app FastAPI de l'étape 3), ajoute en haut un champ « colle une URL » avec deux boutons : « S'abonner » (appelle `abonner(url)`, pour un flux RSS) et « Capter la page » (appelle `capter(url)`, pour une page simple). Après l'action, la liste des items se rafraîchit. Garde la page lisible : titre, source, capté le.
```

La preuve : va sur **http://localhost:3333**. Colle l'URL d'un flux, clique « S'abonner » · les entrées tombent **dans ta page**, sous tes yeux. Colle l'URL d'un article, clique « Capter la page » · il apparaît aussi.

Tu viens de capter, en vrai, dans TON interface. Pas dans TablePlus. Dans ta page.

Un `Item` rempli, pour fixer les idées :

```json
{
  "source": "rss:korben",
  "titre": "Un nouveau plugin pour…",
  "contenu": "Texte de l'article, HTML nettoyé…",
  "media_url": "https://korben.info/img/cover.jpg",
  "url": "https://korben.info/2026/06/mon-article.html",
  "capte_le": "2026-06-07T11:42:00Z"
}
```

## Erreurs possibles

### `recolter()` écrit en base (au lieu de retourner)

C'est l'erreur d'archi à ne pas faire. Une source RETOURNE des items · seul `reservoir.ecrire()` parle à Postgres. Si tu mélanges, ajouter une source devient un copier-coller de SQL. Reviens au découpage `sources/` ⊥ `reservoir.py`.

### Feed introuvable ou champ manquant

Valide l'URL dans ton navigateur d'abord. Ne plante jamais sur une entrée malformée : fallback ou skip, log dans `JOURNAL.md`.

### Encodage ou HTML illisible dans `contenu`

Nettoie : strip HTML, normalise les whitespace. Fallback sur `summary` si `content` est vide.

### RSS bloqué, rate limit, timeout

Ajoute un timeout et un retry. Si le site bloque, réduis la cadence ou change de source.

### La page simple ne donne que du vide

Certaines pages sont du JS pur (rien dans le HTML brut). `trafilatura` fait au mieux ; si vraiment vide, skip + log. Pas de navigateur headless ici, on reste léger.

### `uv: command not found`

Installe-le : `brew install uv` (Mac) ou `winget install astral-sh.uv` (Windows). Ferme et rouvre le terminal.
