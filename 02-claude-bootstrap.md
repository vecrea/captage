# Étape 2 · Claude Code & bootstrap

## Intention

À l'étape 1, tu as récupéré le repo et préparé l'environnement.

Maintenant tu installes Claude Code (l'agent IA qui va construire le système) et tu lui passes la main.

Premier prompt = bootstrap : Claude lit le repo, détecte ton environnement, prépare les fichiers d'état (`JOURNAL.md`, `.env`), fait le commit qui marque ton point de départ personnel.

À partir de la fin de cette étape, tu ne tapes plus de commandes. Tu donnes des intentions.

## Les 2 fichiers d'état (que Claude va créer)

`JOURNAL.md` · le carnet de bord des bugs.

Chaque entrée respecte le format défini dans `CLAUDE.md` section « Format JOURNAL.md ».

`.env` · les réglages sensibles.

Mots de passe, tokens, ports, nom du modèle. Vit en local, n'est jamais commité (il est déjà dans le `.gitignore`).

Les décisions architecturales, elles, vont dans `CLAUDE.md` section `## Décisions historiques` (pas dans JOURNAL.md).

Règle simple : un bug → JOURNAL. Un choix qui engage la suite → Décisions historiques.

## Actions · Vérifications · Constatations

### 1. Claude Code est installé · `claude --version` répond

Mac :

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Windows :

```powershell
irm https://claude.ai/install.ps1 | iex
```

Ferme et rouvre le terminal.

La preuve :

```bash
claude --version
```

Lance Claude (depuis le dossier `captage` ouvert dans VS Code) :

```bash
claude
```

Note : Claude Code nécessite un abonnement **Claude Pro** (~20 $/mois) ou Max.

À la première utilisation, connecte-toi avec ton compte Anthropic.

Vérifie le statut : tape `/status` dans Claude.

### 2. Claude bootstrappe le projet

Premier prompt à Claude :

```
Lis `CLAUDE.md` et `CAPTAGE.md`. Détecte mon OS et mon shell. Inventorie ce qui tourne déjà : `lsof -i -P | grep LISTEN` sur Mac, conteneurs Docker s'il y en a (`docker ps -a`), modèles Ollama s'il y en a (`ollama list`). Complète la section ## Environnement détecté de `CLAUDE.md`. Crée `JOURNAL.md` (vide, prêt à recevoir des entrées au format défini). Crée `.env` (vide, à remplir au fur et à mesure). Fais un commit "Initial setup [date du jour]". Demande-moi confirmation avant de passer à l'étape 3.
```

La preuve :

- Ouvre `CLAUDE.md`, la section ## Environnement détecté est remplie.
- `JOURNAL.md` existe (vide).
- `.env` existe (vide).
- `git log --oneline` montre 2 commits : le commit initial du repo Krea + ton « Initial setup ».

## Erreurs possibles

### `claude` introuvable après l'install

Ferme et rouvre le terminal. Le PATH n'est pas rechargé.

Vérifie : `which claude`.

### Claude demande une clé API au lieu d'un login

L'install par défaut passe par le compte Anthropic (Claude Pro / Max).

Si tu n'as pas d'abonnement, prends Claude Pro.

L'install standard ne fonctionne pas avec une clé API directe.

### `git commit` échoue avec « Please tell me who you are »

Git n'a pas ton identité configurée.

Configure-la :

```bash
git config --global user.name "Ton Nom"
git config --global user.email "ton.email@exemple.com"
```

Puis relance le commit (ou demande à Claude de le relancer).

### Claude n'écrit pas dans `CLAUDE.md`

Vérifie qu'il a les droits d'écriture sur le dossier.

Vérifie que tu es bien dans le bon dossier : `pwd` doit pointer vers `~/dev/captage`.

### Tu (ou Claude) as lancé `/init` par erreur

`/init` regénère un `CLAUDE.md` générique et écrase celui qui était préparé pour Captage.

Restore-le depuis le repo :

```bash
git checkout CLAUDE.md
```

Relance ensuite le bootstrap normal (le prompt du checkpoint 2).

Note : `CLAUDE.md` contient déjà l'instruction « tu ne lances jamais `/init` ». Si Claude l'a fait quand même, signale-le-lui pour qu'il ne recommence pas.
