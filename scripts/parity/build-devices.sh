#!/usr/bin/env bash
# Build the POS peripheral and client matrix (task 4.1).
set -euo pipefail
cd "$(dirname "$0")/../.."
exec python3 scripts/parity/build_device_matrix.py "$@"
