# CLAUDE.md · Captage

## Ton rôle

Tu pilotes la construction du système Captage en suivant les 9 étapes md de ce dossier.

Tu lis ce fichier à chaque session.

Tu inventories avant d'agir.

Tu fais un seul changement à la fois.

Tu documentes les bugs dans `JOURNAL.md`.

Tu ne lances jamais `/init`. Ce fichier est déjà préparé pour Captage. Tu le complètes (section ## Environnement détecté, ## Décisions historiques), tu ne le regénères pas.

## Le projet

Captage est un système qui :

- Capte du contenu (RSS, image, son) dans un Réservoir Postgres local
- Le pré-trie avec une IA locale (Gemma via Ollama)
- Laisse l'humain trancher (Garder / Jeter)
- Grave les items gardés dans une base de Vérité Notion

Le guide humain canonique vit dans `CAPTAGE.md` (la prose pédagogique).

Les 9 fichiers `0X-*.md` sont tes briefs exécutables, un par étape.

## Environnement détecté

À compléter à l'étape 2.

- OS :
- Shell :
- Postgres : (à venir, étape 3)
- Ollama : (à venir, étape 5)
- Modèle Ollama : `gemma3:4b` par défaut, défini dans `.env` comme `OLLAMA_MODEL`
- Notion : (à venir, étape 9)

## Règles de discipline

1. Inventaire avant action. `lsof`, `docker ps`, `ollama list` avant toute install.
2. Un seul changement à la fois. Si un test échoue, ne change qu'une variable.
3. Idempotent par défaut. Tout script doit être relançable sans dégât.
4. `.env` n'est jamais commité. Sécurité non négociable.
5. Sortie JSON forcée pour les appels IA. Parser défensivement.
6. `ON CONFLICT (url) DO NOTHING` sur toute écriture Réservoir.
7. Logue les ratés dans `JOURNAL.md`.
8. Avant de diagnostiquer un bug, grep `JOURNAL.md` pour le symptôme. Si tu trouves une entrée, applique la solution connue avant d'en chercher une nouvelle.
9. JOURNAL.md s'écrit après résolution (format ci-dessous). Si le bug n'est pas résolu, écris quand même avec `Résultat: à creuser`, ne laisse pas perdre l'info.
10. Bugs → `JOURNAL.md` (factuel, temporel). Choix architecturaux qui engagent la suite → section `## Décisions historiques` de ce fichier (append-only, datés). Ne jamais mélanger.

## Format JOURNAL.md

Chaque entrée respecte ce format :

```
## [YYYY-MM-DD] Symptôme en une ligne

**Contexte** : étape, fichier, commande qui a déclenché
**Erreur** : message exact / comportement observé
**Hypothèse** : ce qu'on a pensé
**Action** : ce qu'on a fait (un seul changement à la fois)
**Résultat** : résolu / à creuser
```

## Décisions historiques

Append-only. Date + décision + raison.

Format :

```
### YYYY-MM-DD · Titre court de la décision
Raison : pourquoi. Si remplace une décision passée, mentionner laquelle.
```

(Les décisions concrètes seront ajoutées au fil des étapes.)
