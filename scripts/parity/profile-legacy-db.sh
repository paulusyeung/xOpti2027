#!/usr/bin/env bash
# Profile a legacy Access database reproducibly (task 1.2).
# Usage: scripts/parity/profile-legacy-db.sh [path/to/SynergyV.mdb]
# With no argument, uses $SYNERGY_MDB from eOptical6DAO/.env when present,
# otherwise the schema-only snapshot checked into eOptical6DAO/.
set -euo pipefail
cd "$(dirname "$0")/../.."

if [ -f eOptical6DAO/.env ]; then
  set -a
  # shellcheck disable=SC1091
  . eOptical6DAO/.env
  set +a
fi

if [ "$#" -gt 0 ]; then
  exec python3 scripts/parity/profile_legacy_db.py "$1"
fi
if [ -n "${SYNERGY_MDB:-}" ]; then
  exec python3 scripts/parity/profile_legacy_db.py "$SYNERGY_MDB" \
    --label '`$SYNERGY_MDB` (production dev copy, see `docs/parity/source.md`)'
fi
exec python3 scripts/parity/profile_legacy_db.py eOptical6DAO/SynergyV.mdb
