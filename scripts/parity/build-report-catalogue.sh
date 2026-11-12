#!/usr/bin/env bash
# Build the Richmond report catalogue (task 3.3).
set -euo pipefail
cd "$(dirname "$0")/../.."
exec python3 scripts/parity/build_report_catalogue.py "$@"
