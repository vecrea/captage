# Étape 1 · Récupérer le repo dans VS Code

## Intention

Mettre en place l'environnement de travail unique pour tout le reste du parcours.

Un seul download GUI : VS Code.

Tout le reste passe par le terminal intégré.

C'est l'outil que tu utiliseras à 100 % jusqu'à la fin.

L'élève qui n'a jamais ouvert un terminal apprend ici, dans un cadre sain.

## Actions · Vérifications · Constatations

### 1. VS Code est installé et lancé

Télécharge VS Code depuis https://code.visualstudio.com/

Installe-le :

- Mac : glisse l'app dans `/Applications`
- Windows : lance l'installeur, accepte les défauts

Lance VS Code. Tu vois la page d'accueil.

### 2. Le terminal intégré est ouvert

Menu **Terminal → New Terminal**.

Raccourci :

- Mac : `Cmd + ` (backtick)
- Windows : `Ctrl + ` (backtick)

Une zone de commandes s'ouvre en bas.

Elle est placée dans ton home directory par défaut.

### 3. Le package manager est prêt

Sur Mac, installe Homebrew :

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

À la fin de l'install, Homebrew affiche 2 lignes « Add Homebrew to PATH ».

Copie-les et colle-les dans le terminal pour que `brew` devienne accessible.

Sur Windows, winget est natif sur Windows 11 et la plupart des Windows 10 récents.

Teste :

```powershell
winget --version
```

Si ça répond : continue.

Si ça ne répond pas (Windows 10 ancien) : ouvre Microsoft Store, cherche « App Installer », installe-le, ferme et rouvre le terminal, retest.

### 4. Git est installé · `git --version` répond

Mac :

```bash
brew install git
```

Windows :

```powershell
winget install Git.Git
```

Ferme et rouvre le terminal pour recharger le PATH.

La preuve :

```bash
git --version
```

### 5. Le repo Captage est cloné en local

**Où cloner :** un dossier de dev **hors Bureau et Documents**. Sur Mac, si « iCloud Drive → Bureau et dossiers Documents » est activé (souvent par défaut), et sur Windows si OneDrive gère tes Documents, ces dossiers sont synchronisés dans le cloud : iCloud/OneDrive décharge tes fichiers en stubs, casse git et le venv Python, et envoie ton `.env` (tes secrets) sur des serveurs distants. On clone donc dans `~/dev/captage`, à la racine de ton home, jamais synchronisé. `git clone` crée le dossier `dev` au passage.

Mac :

```bash
git clone https://github.com/vecrea/captage.git ~/dev/captage
```

Windows :

```powershell
git clone https://github.com/vecrea/captage.git $HOME\dev\captage
```

L'URL exacte du repo te sera fournie par ton formateur Krea, ou visible sur la page de cours dans Dojo.

### 6. VS Code ouvre le dossier cloné

Mac :

```bash
code ~/dev/captage
```

Windows :

```powershell
code $HOME\dev\captage
```

Une nouvelle fenêtre VS Code s'ouvre, déjà placée dans le bon dossier.

Tu peux fermer l'ancienne fenêtre vide.

La preuve : l'arborescence VS Code montre `README.md`, `CAPTAGE.md`, `CLAUDE.md`, `01-recup-repo.md`, ..., `09-promotion-reproductibilite.md`.

## Erreurs possibles

### `brew --version` ne répond pas après l'install

Tu as oublié de coller les 2 lignes « Add Homebrew to PATH » à la fin de l'install.

Ferme et rouvre le terminal, recolle-les si besoin.

Vérifie : `which brew`.

### `git: command not found` après brew/winget install

Le PATH n'est pas rechargé.

Ferme et rouvre le terminal.

Si ça persiste : `which git` (Mac) ou `where git` (Windows) pour diagnostiquer.

### `git clone` échoue avec « Repository not found »

L'URL est mauvaise ou tu n'as pas les droits d'accès (si repo privé).

Vérifie l'URL fournie par Krea.

Si privé, demande l'accès.

### `code` n'est pas reconnu après install VS Code

Mac : ouvre VS Code, lance la palette de commandes (`Cmd+Shift+P`), tape « Shell Command: Install 'code' command in PATH », valide.

Windows : la commande est ajoutée automatiquement, ferme et rouvre le terminal.

### Le projet est dans un dossier synchronisé (iCloud / OneDrive)

Symptômes : des fichiers s'affichent avec une icône de nuage (déchargés en stubs), git renvoie des erreurs incohérentes, ou le venv Python se casse. Ton projet est sous iCloud (Bureau/Documents) ou OneDrive.

Sors-le du cloud : reclone dans un dossier non synchronisé, puis jette l'ancien.

```bash
git clone https://github.com/vecrea/captage.git ~/dev/captage
code ~/dev/captage
```

Supprime ensuite le dossier resté dans `Documents`.
