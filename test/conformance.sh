#!/usr/bin/env bash
# test/conformance.sh — vérifie qu'un Captage CONSTRUIT et LANCÉ respecte les
# "preuves" des 9 étapes. Il ne construit rien · il constate l'état observable
# (Docker, Postgres, la page :3333). C'est l'oracle de test du parcours.
#
# Usage (depuis la racine du repo, système lancé) :
#   docker compose up -d
#   uv run uvicorn app:app --host 127.0.0.1 --port 3333 &
#   bash test/conformance.sh
#
# Sortie : PASS / FAIL / ⚠ par étape. Code 0 si aucun FAIL.
# Les ⚠ = checks manuels ou optionnels (ne bloquent pas).
#
# Paliers (voir test/README.md) :
#   1 (ce script) · les preuves en assertions, environnement-agnostique
#   2 · un agent déroule 1→9 dans un Linux éphémère puis lance ce script
#   3 · pleine fidélité (GPU, externes réels, Notion de test)

set -uo pipefail
PORT="${PORT:-3333}"
PASS=0; FAIL=0; SKIP=0

g(){ printf "\033[32m%s\033[0m" "$1"; }
r(){ printf "\033[31m%s\033[0m" "$1"; }
y(){ printf "\033[33m%s\033[0m" "$1"; }
ok(){   PASS=$((PASS+1)); echo "  $(g '✓') $1"; }
ko(){   FAIL=$((FAIL+1)); echo "  $(r '✗') $1"; [ -n "${2:-}" ] && echo "      ↳ $2"; return 0; }
skip(){ SKIP=$((SKIP+1)); echo "  $(y '⚠') $1${2:+ · $2}"; }
step(){ echo; echo "── $1"; }

# Postgres via le conteneur reservoir (pas besoin d'un client psql sur l'hôte)
RES_CTN="$(docker ps --filter 'name=reservoir' --format '{{.Names}}' 2>/dev/null | head -1)"
have_pg(){ [ -n "$RES_CTN" ]; }
pg(){ docker exec "$RES_CTN" psql -U postgres -d captage -tAc "$1" 2>/dev/null; }
count_gt0(){ local n; n="$(pg "$1")"; [ "${n:-0}" -gt 0 ] 2>/dev/null; }

echo "Captage · conformance des 9 étapes (palier 1)"
echo "Attendu : système lancé (docker compose up + page :$PORT)"

# ── Étape 1 · Atelier & repo
step "Étape 1 · Atelier & repo"
command -v git >/dev/null && ok "git installé" || ko "git absent"
if [ -f README.md ] && [ -f CLAUDE.md ]; then ok "fichiers repo présents (README, CLAUDE.md)"; else ko "structure repo incomplète"; fi
if ls 0[1-9]-*.md >/dev/null 2>&1; then ok "les 9 étapes .md sont là"; else ko "fichiers d'étapes manquants"; fi

# ── Étape 2 · Claude Code & bootstrap
step "Étape 2 · Claude Code & bootstrap"
if command -v claude >/dev/null; then ok "claude installé ($(claude --version 2>/dev/null | head -1))"; else skip "claude absent" "non bloquant pour la conformance du système"; fi
if [ -f JOURNAL.md ]; then ok "JOURNAL.md créé"; else ko "JOURNAL.md absent" "bootstrap pas encore fait (étape 2)"; fi
if [ -f .env ]; then ok ".env créé"; else ko ".env absent" "bootstrap pas encore fait (étape 2)"; fi
if [ "$(git rev-list --count HEAD 2>/dev/null || echo 0)" -ge 2 ]; then ok "≥ 2 commits"; else skip "moins de 2 commits"; fi

# ── Étape 3 · Base de données & Page web
step "Étape 3 · Base de données & Page web"
if docker ps >/dev/null 2>&1; then ok "daemon Docker accessible"; else ko "Docker daemon injoignable" "lance Docker Desktop"; fi
if [ -n "$RES_CTN" ]; then ok "conteneur reservoir tourne ($RES_CTN)"; else ko "conteneur reservoir absent" "docker compose up -d"; fi
if have_pg; then
  if [ "$(pg "SELECT to_regclass('public.items') IS NOT NULL")" = "t" ]; then ok "table items existe"; else ko "table items absente"; fi
else
  skip "Postgres injoignable" "checks SQL sautés"
fi
if curl -fsS "http://localhost:$PORT/" >/dev/null 2>&1; then ok "la page :$PORT répond (HTTP 200)"; else ko "la page :$PORT ne répond pas" "uv run uvicorn app:app --port $PORT"; fi

# ── Étape 4 · Interface & Module 1 Texte (RSS)
step "Étape 4 · Interface & Module 1 Texte (RSS)"
if have_pg; then
  if [ "$(pg "SELECT to_regclass('public.abonnements') IS NOT NULL")" = "t" ]; then ok "table abonnements existe"; else ko "table abonnements absente"; fi
  if count_gt0 "SELECT count(*) FROM items WHERE source ILIKE 'rss%'"; then ok "des items RSS sont tombés (s'abonner)"; else skip "aucun item RSS" "lance abonner(<flux>) au moins une fois"; fi
  if count_gt0 "SELECT count(*) FROM items WHERE source ILIKE 'page%' OR source ILIKE 'web%'"; then ok "au moins une page captée (capter)"; else skip "aucune page captée" "lance capter(<url>)"; fi
fi
if [ -d sources ] || [ -f reservoir.py ]; then ok "découpage sources/ ⊥ reservoir.py amorcé"; else skip "structure sources/reservoir non détectée" "vérif manuelle de l'archi"; fi

# ── Étape 5 · IA Locale & Filtre automatique
step "Étape 5 · IA Locale & Filtre automatique"
if curl -fsS http://localhost:11434/ >/dev/null 2>&1; then ok "Ollama répond (:11434)"; else skip "Ollama injoignable" "ollama serve"; fi
if have_pg; then
  if count_gt0 "SELECT count(*) FROM items WHERE verdict IS NOT NULL"; then ok "des items ont un verdict (qualification passée)"; else skip "aucun verdict" "lance la passe de qualification"; fi
  if [ "$(pg "SELECT count(*) FROM items WHERE verdict IS NOT NULL AND verdict NOT IN ('produire','ignorer','peut-être')")" = "0" ]; then ok "verdicts dans le vocabulaire attendu"; else ko "verdicts hors {produire, ignorer, peut-être}"; fi
fi

# ── Étape 6 · Module 2 Image
step "Étape 6 · Module 2 Image"
if have_pg; then
  if count_gt0 "SELECT count(*) FROM items WHERE source ILIKE 'image%' AND coalesce(contenu,'')<>''"; then ok "une image captée avec texte extrait"; else skip "aucun item image" "capte une image / un PDF"; fi
fi

# ── Étape 7 · Module 3 Son
step "Étape 7 · Module 3 Son"
if have_pg; then
  if count_gt0 "SELECT count(*) FROM items WHERE source ILIKE 'podcast%' AND coalesce(contenu,'')<>''"; then ok "un podcast capté avec transcription"; else skip "aucun item podcast" "capte un épisode"; fi
fi

# ── Étape 8 · Interface de tri manuel
step "Étape 8 · Interface de tri manuel"
code="$(curl -s -o /dev/null -w '%{http_code}' -X POST "http://localhost:$PORT/trier" 2>/dev/null)"
case "$code" in
  401|403)     ok "POST /trier protégé par auth ($code)";;
  200|400|422) skip "POST /trier répond ($code) mais pas d'auth visible" "protège l'action (TRI_PASSWORD)";;
  404)         ko "route /trier absente" "ajoute l'action de tri (étape 8)";;
  000)         ko "POST /trier injoignable" "page :$PORT lancée ?";;
  *)           skip "POST /trier code $code";;
esac
if have_pg; then
  if count_gt0 "SELECT count(*) FROM items WHERE etat IN ('gardé','jeté')"; then ok "des items triés (gardé/jeté)"; else skip "aucun item trié" "clique Garder/Jeter sur :$PORT"; fi
fi

# ── Étape 9 · Ajout au CKM & Touches finales
step "Étape 9 · Ajout au CKM & Touches finales"
if [ -f docker-compose.yml ]; then ok "docker-compose.yml présent"; else ko "docker-compose.yml absent"; fi
if have_pg; then
  if count_gt0 "SELECT count(*) FROM items WHERE etat='promu'"; then ok "au moins un item promu vers la Vérité"; else skip "aucun item promu" "clique Garder (étape 9) pour pousser dans Notion"; fi
fi
if grep -qi "NOTION_DB_ID" .env 2>/dev/null; then ok "NOTION_DB_ID configuré (.env)"; else skip "NOTION_DB_ID absent du .env" "setup Notion (étape 9)"; fi
if crontab -l 2>/dev/null | grep -qiE "relever|abonnement|captage"; then ok "cron de relevé détecté"; else skip "pas de cron de relevé détecté" "planifie relever_abonnements (étape 9)"; fi

# ── Bilan
echo
echo "── Bilan : $(g "$PASS PASS") · $(r "$FAIL FAIL") · $(y "$SKIP ⚠")"
if [ "$FAIL" -eq 0 ]; then echo "$(g 'Conformance OK')"; exit 0; else echo "$(r 'Des preuves manquent')"; exit 1; fi
