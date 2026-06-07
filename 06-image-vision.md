# Étape 6 · Module Image (Vision)

## Intention

Le module RSS captait du texte déjà écrit.

Le module Image capte ce qu'un humain voit : un screenshot, un PDF aplati, un vieux scan officiel sans couche texte.

Même Réservoir, même structure. Seul le traducteur change.

La clé : c'est **le même modèle qu'à l'étape 5** qui fait le travail.

Gemma est multimodal. Il a jugé du texte, il sait aussi lire une image.

C'est exactement pour ça qu'on a exigé « multimodal » dans les critères. Ici on récolte le dividende.

## Le geste qui compte

On encode l'image en base64 et on la passe à Ollama dans le champ `images` :

```python
import base64, requests, os

b64 = base64.b64encode(open("page.png","rb").read()).decode()

requests.post("http://localhost:11434/api/generate", json={
  "model": os.environ["OLLAMA_MODEL"],   # le même qu'à l'étape 5
  "prompt": "Extrais le texte / décris cette image.",
  "images": [b64],
  "stream": False
})
```

Lis-le comme une illustration. Le vrai module lira le modèle depuis `.env`, pas en dur.

## Actions · Vérifications · Constatations

### 1. Une image est captée · texte extrait dans `contenu`, jugée par la même passe

Prompt à Claude :

```
Implémente `SourceImage(chemin)`, suit l'interface `Source` (étape 4) et la même structure. Pour un PDF, rasterise chaque page avec `pdf2image` et traite-les une par une. Envoie chaque image à Ollama en vision (champ `images` en base64), avec le modèle lu depuis `.env` (`OLLAMA_MODEL`, le même qu'à l'étape 5), un prompt d'extraction strict. Écris le résultat dans le Réservoir à la même structure avec `ON CONFLICT (url) DO NOTHING`. Installe `pdf2image` (`uv add pdf2image`) et la dépendance système `poppler` si nécessaire (`brew install poppler` sur Mac).
```

Donne-lui un screenshot ou un PDF, lance la récolte.

La preuve : ouvre ta page **http://localhost:3333**.

Une nouvelle ligne, `source` = image, avec le texte extrait dans `contenu`, dans la même liste que le reste.

Et comme la passe de qualification (étape 5) tourne sur tout item `etat='capté'`, elle jugera cette ligne sans une seule modification.

C'est tout l'intérêt de la structure commune.

## Erreurs possibles

### Ça force à modifier le Réservoir ou la structure

Alors la structure (étape 4) est mal pensée.

Le module change, la structure ne bouge pas.

Reviens à l'étape 4 et reprends.

### PDF illisible, pas de texte extrait

Rasterise en images, page par page.

Augmente la résolution (DPI = 200 ou 300).

Renvoie chaque page séparément à Gemma.

### Images trop lourdes, requête en timeout

Redimensionne ou compresse (largeur max raisonnable, 1200-1600px).

Limite le nombre de pages traitées d'un coup.

Log les échecs dans `JOURNAL.md`.

### Résultats hallucinés, trop interprétatifs

Prompt d'extraction strict :

```
Décris ce que tu vois. Cite exactement. Si incertain, réponds "UNKNOWN".
```

Ajoute un champ `confidence` si besoin.
