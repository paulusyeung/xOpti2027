#!/usr/bin/env bash
# Verify the TLS edge (task 7.1):
#   - plain HTTP redirects to HTTPS with 308
#   - readiness is reachable over HTTPS
#   - an unsafe request without a CSRF token is rejected with 403
#   - the session cookie is marked Secure, HttpOnly, SameSite=Strict
#
#   scripts/tls-check.sh
set -euo pipefail
cd "$(dirname "$0")/.."

PROJECT="${XOPTI_TLS_PROJECT:-xopti-tls}"
HTTP_PORT="${XOPTI_TLS_HTTP_PORT:-8088}"
HTTPS_PORT="${XOPTI_TLS_HTTPS_PORT:-8443}"
HTTP="http://localhost:$HTTP_PORT"
HTTPS="https://localhost:$HTTPS_PORT"
COMPOSE=(docker compose -p "$PROJECT" -f docker/compose.yml -f docker/compose.tls.yml)

cleanup() {
  "${COMPOSE[@]}" down -v --remove-orphans >/dev/null 2>&1 || true
}
trap cleanup EXIT

step() {
  printf '\n== %s\n' "$*"
}

fail() {
  echo "FAIL: $*" >&2
  "${COMPOSE[@]}" logs caddy >&2 || true
  exit 1
}

step "start the TLS stack"
XOPTI_HTTP_PORT="${XOPTI_HTTP_PORT:-18086}" "${COMPOSE[@]}" up -d --build

step "wait for PostgreSQL health"
for _ in $(seq 1 60); do
  status="$(docker inspect --format '{{.State.Health.Status}}' "$("${COMPOSE[@]}" ps -q postgres)" 2>/dev/null || echo starting)"
  [ "$status" = "healthy" ] && break
  sleep 2
done
[ "${status:-}" = "healthy" ] || fail "PostgreSQL did not become healthy"

step "bootstrap and seed the disposable database"
"${COMPOSE[@]}" run --rm api --bootstrap >/dev/null
"${COMPOSE[@]}" run --rm -e XOPTI_ALLOW_SMOKE_SEED=1 api --seed-smoke >/dev/null

step "wait for HTTPS readiness"
for _ in $(seq 1 60); do
  if curl -kfsS "$HTTPS/api/health/ready" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done
curl -kfsS "$HTTPS/api/health/live" >/dev/null || fail "liveness over HTTPS failed"

step "plain HTTP redirects to HTTPS"
headers="$(curl -sSI "$HTTP/")"
grep -Eq '^HTTP/[0-9.]+ 308' <<<"$headers" || fail "expected 308 from $HTTP, got: $headers"
grep -Eqi "location: https://" <<<"$headers" || fail "missing HTTPS Location header: $headers"

step "missing CSRF token is rejected"
status="$(curl -ks -o /dev/null -w '%{http_code}' -X POST "$HTTPS/api/v1/auth/sign-out")"
[ "$status" = "403" ] || fail "expected 403 without CSRF token, got $status"

step "session cookie is Secure, HttpOnly, and SameSite=Strict"
jar="$(mktemp)"
token="$(curl -kfsS -c "$jar" "$HTTPS/api/v1/auth/csrf-token" | python3 -c 'import json,sys; print(json.load(sys.stdin)["token"])')"
response="$(curl -ks -c "$jar" -b "$jar" -D - -o /dev/null \
  -H "X-CSRF-TOKEN: $token" -H "Content-Type: application/json" \
  -d '{"username":"manager","password":"Test#Passw0rd1!"}' \
  "$HTTPS/api/v1/auth/sign-in")"
grep -Eiq '^set-cookie: xopti\.session=.*;.*secure' <<<"$response" || fail "session cookie is not Secure: $response"
grep -Eiq '^set-cookie: xopti\.session=.*HttpOnly' <<<"$response" || fail "session cookie is not HttpOnly"
grep -Eiq '^set-cookie: xopti\.session=.*SameSite=Strict' <<<"$response" || fail "session cookie is not SameSite=Strict"
rm -f "$jar"

echo "TLS edge check passed."
