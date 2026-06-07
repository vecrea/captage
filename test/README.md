# test/ — tester le parcours lui-même

Chaque étape de Captage a une **preuve** (docker compose ps, `curl :3333`, un
`SELECT`, le verdict qui se remplit, la page Notion créée…). Ces preuves sont
l'oracle de test du parcours. Ce dossier les automatise, en 3 paliers.

## Palier 1 · `conformance.sh` (livré)

Un script qui inspecte un Captage **déjà construit et lancé** et vérifie chaque
preuve. Il ne construit rien · il **constate**. Marche sur Mac comme sur Linux.

```bash
# système lancé d'abord :
docker compose up -d
uv run uvicorn app:app --host 127.0.0.1 --port 3333 &

# puis :
bash test/conformance.sh
```

Sortie : `✓ PASS` / `✗ FAIL` / `⚠` par étape, code de sortie 0 si aucun FAIL.
Les `⚠` sont des checks manuels ou optionnels (ils ne bloquent pas). Postgres est
interrogé **dans le conteneur** `reservoir` (`docker exec`), donc aucun client
`psql` à installer sur l'hôte.

C'est la **spec exécutable** du parcours : si un changement du guide casse une
preuve, le script le voit.

## Palier 2 · run agent dans un Linux éphémère (livré)

C'est ici que vit le « Linux virtuel ». On ne le fait **pas** sur ta machine : on
démarre un **Linux jetable** où un agent joue le lecteur **+** Claude Code, déroule
les étapes 1→9 (il exécute chaque « Prompt à Claude »), puis lance
`conformance.sh`. Trois façons de l'obtenir, du plus simple au plus propre :

- **Docker-in-Docker** · un conteneur privilégié (`docker run --privileged …`) qui
  contient lui-même Docker. Portable, lançable de n'importe où, isolé de ta machine.
- **Sandbox agent** · E2B / Daytona / GitHub Codespaces · pensés pour « un agent
  exécute du code en isolation ».
- **GitHub Actions** · un runner Linux éphémère à chaque push sur le guide (CI).

Le harness traduit les commandes Mac (`brew`) en Linux (`apt` / installeur natif) —
et cette traduction **révèle déjà** les endroits où le guide est trop Mac-centré.

On teste que « suivre le guide **produit** un système qui marche », pas qu'il
produit un code identique : les assertions portent sur le **comportement**, pas
sur les lignes.

**C'est implémenté** dans :
- `.github/workflows/conformance.yml` · le workflow GitHub Actions, déclenché **à
  la main** (`workflow_dispatch`) pour ne pas facturer à chaque commit.
- `test/agent-build.sh` · le driver : prépare le Linux (uv, ollama + petit modèle,
  claude code), lance l'agent qui construit les étapes 3→9, puis `conformance.sh`.

Pour le lancer :
1. Ajoute le secret repo **`ANTHROPIC_API_KEY`** (Settings → Secrets → Actions).
   ⚠️ la CI utilise une **clé API facturée au token**, contrairement au parcours
   élève qui tourne sur l'abonnement Pro/Max.
2. Onglet **Actions → « conformance (palier 2) » → Run workflow**.
3. Le rapport `conformance-report.txt` sort en artefact.

Notes honnêtes · l'agent peut écrire un code un peu différent à chaque run (voulu,
on teste le comportement) · Ollama tourne sur CPU en CI, d'où un **petit modèle**
par défaut (`gemma3:1b`) · les étapes 1-2 (repo cloné, bootstrap) ressortent rouges
en CI, c'est attendu (on valide le cœur 3→9).

## Palier 3 · pleine fidélité (à venir)

Comme le palier 2, mais GPU (vraie vitesse Gemma), feeds réels (avec retries), et
une intégration **Notion de test** (DB jetable, nettoyée après). Au plus près d'un
vrai élève.

## Fixtures (paliers 2-3)

Pour le déterminisme, on épingle : un flux RSS local, une page HTML, un clip audio
court. Ça évite que « le site a changé » fasse échouer un test.
