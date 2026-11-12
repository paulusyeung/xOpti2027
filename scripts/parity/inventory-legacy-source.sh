#!/usr/bin/env bash
# Inventory root-level legacy .frm/.bas/.cls files (task 1.3).
set -euo pipefail
cd "$(dirname "$0")/../.."
exec python3 scripts/parity/inventory_legacy_source.py "$@"
