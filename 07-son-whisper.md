# Étape 7 · Module 3 Son (Whisper)

## Intention

Troisième type de source, dernier traducteur : le Son.

Un podcast, c'est un flux RSS (on réutilise le module de l'étape 4) dont chaque entrée porte un fichier audio.

Le travail en plus : transformer cet audio en texte, en local, avec Whisper.

Ensuite c'est une ligne comme une autre dans le Réservoir.

Et c'est tout. Ce module **capte seulement**.

Il n'a rien à juger. La passe de qualification (étape 5) tourne déjà sur tout item `etat='capté'`.

Dès que le son atterrit dans le Réservoir, il est jugé comme le reste.

Une seule passe de qualification, trois types de source qui la nourrissent. C'est le bénéfice de la structure commune.

## Pourquoi HTTP direct, surtout pas yt-dlp

Un podcast expose déjà son audio en clair dans le flux RSS, champ `enclosure`.

Un simple téléchargement HTTP suffit.

yt-dlp est fait pour gratter des plateformes qui ne veulent pas qu'on télécharge.

Ses extracteurs cassent à chaque changement côté plateforme (maintenance sans fin).

Il navigue dans une zone grise vis-à-vis des CGU.

Il ramène une lourdeur inutile ici.

La règle : le format le plus simple qui marche.

## Actions · Vérifications · Constatations

### 1. Un épisode est capté · transcription dans `contenu`, verdict tout seul

Prompt à Claude :

```
Implémente `SourcePodcast(feed_url)`. C'est un RSS (réutilise `SourceRSS` de l'étape 4) dont chaque entrée porte un audio en `enclosure`. Télécharge l'audio en HTTP direct (avec User-Agent et timeout). Transcris-le avec `faster-whisper` en local. Écris à la même structure dans le Réservoir avec `ON CONFLICT (url) DO NOTHING`. Ce module capte seulement : ne rejuge rien, la qualification de l'étape 5 s'en charge. Installe `faster-whisper` : `uv add faster-whisper`. Sur Mac avec Apple Silicon, propose-moi aussi l'alternative `mlx-whisper` qui est plus rapide sur M1/M2/M3/M4.
```

Donne-lui un flux de podcast (un de tes podcasts préférés), lance la récolte sur un épisode.

La preuve : ouvre ta page **http://localhost:3333**.

Une ligne `source` = podcast, la transcription dans `contenu`, et son `verdict` qui apparaît tout seul à la passe de qualification suivante. Trois types de source, une seule page qui les montre tous.

## Erreurs possibles

### Flux podcast sans `enclosure` (pas d'audio)

Cherche le lien audio dans les champs alternatifs.

Sinon skip + log dans `JOURNAL.md`.

### Audio non téléchargeable (403, redirection, gros fichier)

Téléchargement HTTP avec header `User-Agent` réaliste.

Gère les redirections (`allow_redirects=True`).

Impose une taille max (ex : 500 MB).

Log et skip si trop lourd.

### Transcription lente ou mauvaise

Choisis un modèle Whisper plus petit : `base` ou `small` au lieu de `large`.

Normalise le son avec `ffmpeg` (mono, 16 kHz).

Chunke les longs épisodes (par tranches de 10 min).

Garde la transcription brute (même imparfaite) plutôt que planter.
