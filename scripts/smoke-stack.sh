#!/usr/bin/env bash
# Compose smoke stack from an empty database (task 6.3).
#
# Builds the web + API images, starts PostgreSQL empty, bootstraps it through the
# production command, seeds disposable smoke branches/accounts, then runs the
# Playwright smoke spec through the nginx -> API path: health, sign-in, branch
# listing, and CSRF enforcement.
#
#   scripts/smoke-stack.sh
#
# Environment:
#   XOPTI_SMOKE_PROJECT  compose project name (default xopti-smoke)
#   XOPTI_SMOKE_URL      base URL (default http://127.0.0.1:18085)
#   XOPTI_KEEP_SMOKE=1   leave the stack running for debugging
set -euo pipefail
cd "$(dirname "$0")/.."

PROJECT="${XOPTI_SMOKE_PROJECT:-xopti-smoke}"
BASE_URL="${XOPTI_SMOKE_URL:-http://127.0.0.1:18085}"
COMPOSE=(docker compose -p "$PROJECT" -f docker/compose.yml -f docker/compose.smoke.yml)

cleanup() {
  if [ "${XOPTI_KEEP_SMOKE:-0}" = "1" ]; then
    echo "Keeping smoke stack '$PROJECT' at $BASE_URL" >&2
    return
  fi
  "${COMPOSE[@]}" down -v --remove-orphans >/dev/null 2>&1 || true
}
trap cleanup EXIT

step() {
  printf '\n== %s\n' "$*"
}

step "build and start the stack from an empty database"
"${COMPOSE[@]}" up -d --build

step "wait for PostgreSQL health"
for _ in $(seq 1 60); do
  status="$(docker inspect --format '{{.State.Health.Status}}' "$("${COMPOSE[@]}" ps -q postgres)" 2>/dev/null || echo starting)"
  [ "$status" = "healthy" ] && break
  sleep 2
done
if [ "${status:-}" != "healthy" ]; then
  echo "PostgreSQL did not become healthy" >&2
  "${COMPOSE[@]}" logs postgres >&2 || true
  exit 1
fi

step "bootstrap the empty database (production command)"
"${COMPOSE[@]}" run --rm api --bootstrap

step "seed disposable smoke branches and accounts"
"${COMPOSE[@]}" run --rm -e XOPTI_ALLOW_SMOKE_SEED=1 api --seed-smoke

step "wait for readiness through nginx"
for _ in $(seq 1 60); do
  if curl -fsS "$BASE_URL/api/health/ready" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done
curl -fsS "$BASE_URL/api/health/ready" >/dev/null
curl -fsS "$BASE_URL/api/health/live" >/dev/null

step "Playwright smoke: sign-in, branches, CSRF, health"
(
  cd web/xOpti.Web
  if ! npx playwright --version >/dev/null 2>&1; then
    npm ci --no-audit --no-fund
  fi
  XOPTI_E2E_BASE_URL="$BASE_URL" npx playwright test tests/e2e/smoke.spec.ts \
    --project=chromium --reporter=list
)

echo "Smoke stack passed."
