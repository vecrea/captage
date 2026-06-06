# Captage

Un parcours pédagogique gratuit pour construire un système de captage de contenu (RSS, image, son) avec une IA locale.

Tu apprends en passant :

- Postgres + Docker
- Python + interfaces réutilisables
- Une IA locale (Gemma via Ollama) qui pré-trie
- Une UI où l'humain tranche
- La promotion vers une Vérité (Notion)

## Prérequis matériel

- macOS 12 (Monterey) ou plus récent
- Windows 10 (avec MAJ récentes) ou Windows 11
- 16 Go de RAM recommandés (Ollama + Whisper tirent dessus)
- 10 Go libres sur le disque

## Comment démarrer

Va à `01-recup-repo.md` et suis les étapes dans l'ordre.

Si tu veux comprendre la pédagogie et la philosophie d'abord, lis `CAPTAGE.md`.

## Structure du repo

- `README.md` · ce fichier
- `CAPTAGE.md` · prose pédagogique humaine (concepts, philosophie, contexte)
- `CLAUDE.md` · brief Claude Code (règles, état partagé, formats)
- `01-recup-repo.md` à `09-promotion-reproductibilite.md` · les 9 étapes exécutables

`JOURNAL.md` et `.env` seront créés à l'étape 2.
