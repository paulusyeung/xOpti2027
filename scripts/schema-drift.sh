#!/usr/bin/env bash
# CI schema-drift gate (task 5.4).
#
# Compares a bootstrapped database with the canonical xopti-schema.sql. App-owned
# objects created by EF migrations (platform.*, identity tables) are ignored.
# Exits non-zero and names every difference, including an unexpected column.
#
#   export XOPTI_DATABASE_URL='postgresql://postgres:...@localhost:5432/xOpti'
#   scripts/schema-drift.sh
set -euo pipefail
cd "$(dirname "$0")/.."

: "${XOPTI_DATABASE_URL:?Set XOPTI_DATABASE_URL to the bootstrapped database}"

if [ -n "${XOPTI_SCHEMA_FILE:-}" ]; then
  export XOptiApi__SchemaFile="$XOPTI_SCHEMA_FILE"
fi

export ConnectionStrings__XOptiDatabase="$XOPTI_DATABASE_URL"

exec dotnet run --project src/xOpti.Api -- --schema-drift
