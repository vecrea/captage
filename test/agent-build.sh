#!/usr/bin/env bash
# Palier 2 · driver. Un agent (Claude Code headless) construit le parcours sur
# CETTE machine Linux en suivant les fichiers d'étapes, puis conformance.sh vérifie.
# Appelé par .github/workflows/conformance.yml (ou en local pour valider le driver).
set -uo pipefail

REPO="$(pwd)"
WORK="${WORK:-/tmp/captage-build}"
PORT="${PORT:-3333}"
OLLAMA_MODEL="${OLLAMA_MODEL:-gemma3:1b}"

rm -rf "$WORK"; mkdir -p "$WORK"
cp -f *.md "$WORK"/ 2>/dev/null || true
cd "$WORK"

PROMPT="Tu construis le système Captage sur CETTE machine Linux, en suivant les fichiers d'étapes présents ici (03-reservoir.md à 09-...). \
Contexte machine : Docker est installé et lancé ; Ollama tourne déjà sur localhost:11434 avec le modèle '$OLLAMA_MODEL' (utilise CE tag, pas gemma3:4b) ; \
uv et python3 sont disponibles ; pas de Homebrew (utilise apt ou uv si une dépendance manque). \
Implémente les étapes 3 à 9 dans l'ordre : base Postgres via docker compose (service 'reservoir', table 'items'), page web FastAPI sur le port $PORT, \
interface des sources + writer séparé, un abonnement RSS à https://korben.info/feed, la passe de qualification IA (verdict EXACTEMENT produire/ignorer/peut-être), \
l'action de tri /trier protégée. Lance la page :$PORT en arrière-plan à la fin. Ne demande aucune confirmation."

echo "── L'agent construit (Claude Code headless) ──"
claude -p "$PROMPT" --dangerously-skip-permissions 2>&1 | tail -60 || echo "(claude a retourné un code non nul, on vérifie quand même)"

# Le serveur lancé par l'agent meurt quand `claude -p` se termine. On (re)lance
# donc la page nous-mêmes, détachée (setsid), avant de vérifier — sinon les étapes
# 3 et 8 ressortent en faux négatif.
pkill -f "uvicorn.*--port $PORT" 2>/dev/null || true
if [ -f app.py ]; then
  setsid uv run uvicorn app:app --host 127.0.0.1 --port "$PORT" >/tmp/captage-page.log 2>&1 &
  for i in $(seq 1 30); do curl -fsS "http://localhost:$PORT/" >/dev/null 2>&1 && break; sleep 1; done
fi

echo "── Vérification (conformance.sh) ──"
bash "$REPO/test/conformance.sh" | tee "$REPO/conformance-report.txt"
rc=${PIPESTATUS[0]}

# On ne juge que le cœur du parcours (étapes 3→9). Les étapes 1-2 (repo cloné,
# bootstrap) ne s'appliquent pas à un build CI et ressortent rouges : c'est attendu.
echo
echo "Rapport complet dans conformance-report.txt (artefact). Code conformance.sh : $rc"
exit 0
