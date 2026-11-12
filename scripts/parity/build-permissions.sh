#!/usr/bin/env bash
# Extract the legacy permission matrix (task 3.1).
set -euo pipefail
cd "$(dirname "$0")/../.."
if [ -f eOptical6DAO/.env ]; then
  set -a
  # shellcheck disable=SC1091
  . eOptical6DAO/.env
  set +a
fi
exec python3 scripts/parity/build_permissions.py "${1:-${SYNERGY_MDB:-eOptical6DAO/SynergyV.mdb}}"
