# Étape 5 · IA Locale & Filtre automatique

## Intention

Le Réservoir se remplit (les lignes RSS sont tombées).

Il lui manque un cerveau. Quelque chose qui regarde chaque item et dit « ça vaut le coup », « à ignorer », « peut-être ».

C'est le rôle de Gemma, et on l'installe ici, au moment précis où on s'en sert.

Le test est minuscule mais décisif. Gemma lit un texte et rend un verdict, en local, sans clé, sans compte, avec une sortie parseable (JSON).

Sans ça, tout le workflow devient du théâtre. Tu captes, mais tu ne sais pas filtrer.

Rappel : l'IA pré-trie. L'humain tranche. Le clic Garder / Jeter viendra à l'étape 8.

## Le choix du modèle

Le modèle est la pièce qui vieillit le plus vite. Un meilleur sort tous les quelques mois.

On épingle un défaut qui marche aujourd'hui, et on te donne les critères pour le remplacer plus tard.

Défaut testé en 06/2026 : `gemma3:4b`. Multimodal, ~3.3 Go, contexte 128K.

Pour en changer, juge n'importe quel modèle sur 3 critères qui ne périment pas :

1. **Multimodal obligatoire** : le même modèle sert au verdict (ici) ET à lire les images (étape 6). Un modèle « texte seul » casse l'étape 6.
2. **Taille ≲ ta RAM** : sinon ça rame sur disque, inutilisable.
3. **Sort du JSON** : le verdict en dépend.

Où chercher : familles Gemma, Qwen-VL, Llama-Vision, ou la bibliothèque Ollama (filtre « vision »).

On remplace sur critères, pas sur hype.

## Actions · Vérifications · Constatations

### 1. Ollama est installé et tourne

Mac :

```bash
brew install --cask ollama
```

⚠️ Bien **`--cask`** (l'app). La formule simple `brew install ollama` est cassée : il lui manque le moteur d'inférence `llama-server`, et tu te prends une erreur 500 sur chaque appel.

Windows :

```powershell
winget install Ollama.Ollama
```

Lance Ollama (sur Mac, ouvre l'app une fois pour démarrer le service ; sur Windows, le service démarre seul).

### 2. Le modèle local est là et il répond

```bash
ollama pull gemma3:4b
ollama list
```

La preuve qu'il répond, en local, sans clé :

```bash
curl http://localhost:11434/api/generate -d '{
 "model":"gemma3:4b",
 "prompt":"Donne un verdict (produire/ignorer/peut-être) sur ce contenu. Réponds UNIQUEMENT en JSON {verdict, raison}.\n\nCONTENU :\nLa Triple Liberté (Temps / Argent / Clients) dit que ton système doit t acheter trois marges de manoeuvre.",
 "format":"json",
 "stream":false }'
```

Tu dois recevoir un JSON avec `verdict` et `raison`.

Ici le tag du modèle est en dur, juste pour la démo. Le vrai code lira depuis `.env`.

Ajoute la ligne dans `.env` :

```
OLLAMA_MODEL=gemma3:4b
```

Mets à jour `CLAUDE.md` à la section ## Environnement détecté : « Ollama : natif sur :11434, modèle gemma3:4b ».

### 3. Le Réservoir est pré-trié · `verdict` et `raison` se remplissent

Prompt à Claude (la fonction `juger()`) :

```
Écris `juger(texte) -> {verdict, raison}` : lis le nom du modèle depuis `.env` (`OLLAMA_MODEL`), appelle Ollama en local sur 11434, force `format: json`, parse défensivement. Le verdict doit être **exactement** l'un de ces trois mots : `produire`, `ignorer`, `peut-être` — dis-le explicitement dans le prompt envoyé au modèle (sinon il répond « Analyser », « Oui »… et ton parsing rabat tout en `peut-être`). Si le JSON est invalide : retente une fois, sinon renvoie `{verdict: "peut-être", raison: "json invalide"}`.
```

Prompt à Claude (la passe de qualification, agnostique de la source) :

```
Écris une passe de qualification : pour chaque item du Réservoir où `etat='capté'`, appelle `juger(contenu)` et écris le `verdict` et la `raison` dans sa ligne. Idempotente : relançable sans re-juger ce qui a déjà un verdict. Logue les ratés dans `JOURNAL.md`.
```

Puis fais remonter le verdict dans ta page :

```
Sur ma page :3333, ajoute une colonne « verdict » : une pastille couleur par item (vert = produire, gris = ignorer, orange = peut-être), avec la raison en infobulle.
```

La preuve : ouvre **http://localhost:3333**. Chaque item porte maintenant sa pastille de verdict. (Sous le capot, les colonnes `verdict` et `raison` se sont remplies dans la table — vérifiable dans TablePlus.)

Le Réservoir n'est plus une pile muette. Il est pré-trié, et ça se voit dans ta page.

## Erreurs possibles

### Modèle faux ou trop lent

Vérifie le tag : `ollama list`.

Lent ? Assure-toi qu'Ollama tourne en natif (pas dans Docker sur Mac) pour profiter du GPU.

### `ollama: command not found`

Pas installé, ou PATH pas rechargé.

Ferme et rouvre le terminal.

Toujours KO : réinstalle Ollama, puis relance.

### L'API répond mais le JSON est cassé

Force le format dans le prompt (déjà fait avec `format: json`) et parse défensivement.

Au besoin, baisse la `temperature` à 0 et répète « réponds UNIQUEMENT en JSON ».

### Erreur 500 sur chaque appel · `llama-server binary not found`

Tu as installé Ollama avec la **formule** `brew install ollama` (cassée). Désinstalle-la (`brew uninstall ollama`) et pose l'**app** : `brew install --cask ollama`, puis relance le serveur.

### Tous les verdicts finissent en `peut-être`

Le modèle ne respecte pas le vocabulaire (il répond « Analyser », « Oui »…) et ton parsing rabat tout en `peut-être`. Rends le prompt strict : « le verdict est EXACTEMENT l'un de ces trois mots : produire, ignorer, peut-être ».

### Port 11434 inaccessible

Vérifie qu'Ollama tourne : `ollama list`, ou `ollama serve`.

Test rapide : `curl http://localhost:11434/`.

Sur Mac, vérifie qu'aucun VPN ou firewall ne bloque.
