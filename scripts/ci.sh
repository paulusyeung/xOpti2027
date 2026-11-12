#!/usr/bin/env bash
# Full repository quality gate (task 6.2).
#
# Runs restore, build, every test project, the API contract check, the web
# typecheck/unit/build/bundle checks, and the reconciliation fixture. Any step
# that fails aborts the script with a non-zero exit status.
#
#   scripts/ci.sh
#
# Optional CI-only additions:
#   XOPTI_DATABASE_URL=... scripts/ci.sh   # also bootstraps and runs schema drift
#
# Requires: .NET SDK 10, Node 22+, Docker (integration and migration tests use
# Testcontainers).
set -euo pipefail
cd "$(dirname "$0")/.."

CONFIGURATION="${CONFIGURATION:-Release}"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1

step() {
  printf '\n============================================================\n== %s\n============================================================\n' "$*"
}

step "restore"
dotnet restore xOpti.sln

step "build ($CONFIGURATION)"
dotnet build xOpti.sln -c "$CONFIGURATION" --no-restore

step "API contract check"
scripts/contract-check.sh

step "parity baseline references"
python3 scripts/check-baseline-references.py

step "secret scan"
scripts/scan-secrets.sh

step "backend tests (all projects in xOpti.sln)"
dotnet test xOpti.sln -c "$CONFIGURATION" --no-build

step "migration reconciliation fixture"
dotnet test tests/xOpti.Migrations.Tests/xOpti.Migrations.Tests.csproj \
  -c "$CONFIGURATION" --no-build \
  --filter "FullyQualifiedName~ReconciliationFixture"

if [ -n "${XOPTI_DATABASE_URL:-}" ]; then
  step "fresh-database bootstrap (idempotent)"
  scripts/bootstrap-db.sh
  scripts/bootstrap-db.sh

  step "schema drift"
  scripts/schema-drift.sh
fi

step "web dependencies"
(
  cd web/xOpti.Web
  npm ci --no-audit --no-fund
)

step "web typecheck"
(
  cd web/xOpti.Web
  npm run typecheck
)

step "web unit tests"
(
  cd web/xOpti.Web
  npm test
)

step "web production build"
(
  cd web/xOpti.Web
  npm run build
)

step "web bundle checks"
(
  cd web/xOpti.Web
  npm run check:bundle
)

if [ "${XOPTI_SKIP_SMOKE:-0}" != "1" ]; then
  step "compose smoke stack from an empty database"
  scripts/smoke-stack.sh
fi

printf '\nCI gate passed.\n'
