#!/usr/bin/env bash
# Bootstrap a fresh PostgreSQL 17 database (task 5.1).
#
# Applies xopti-schema.sql, app-owned EF migrations, and reference seed data in
# one idempotent operation, then records platform.schema_baseline. Re-running
# against the same checksum is a no-op; a different checksum fails before any
# DDL and changes nothing.
#
#   export XOPTI_DATABASE_URL='postgresql://postgres:...@localhost:5432/xOpti'
#   scripts/bootstrap-db.sh
#
# Optional:
#   XOPTI_SCHEMA_FILE  path to xopti-schema.sql (defaults to the repository copy)
set -euo pipefail
cd "$(dirname "$0")/.."

: "${XOPTI_DATABASE_URL:?Set XOPTI_DATABASE_URL to the target database}"

if [ -n "${XOPTI_SCHEMA_FILE:-}" ]; then
  export XOptiApi__SchemaFile="$XOPTI_SCHEMA_FILE"
fi

# Keep the password out of the process list; the API reads this configuration key.
export ConnectionStrings__XOptiDatabase="$XOPTI_DATABASE_URL"

exec dotnet run --project src/xOpti.Api -- --bootstrap
