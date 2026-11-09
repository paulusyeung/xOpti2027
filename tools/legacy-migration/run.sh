#!/usr/bin/env bash
set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

set -a
. "$ROOT/eOptical6DAO/.env"
set +a

OUT="$ROOT/tools/legacy-migration/reports"
mkdir -p "$OUT"

python3 "$ROOT/tools/legacy-migration/compare.py" schema > "$OUT/schema-diff.md"
python3 "$ROOT/tools/legacy-migration/compare.py" counts > "$OUT/row-counts.md"
python3 "$ROOT/tools/legacy-migration/compare.py" keys > "$OUT/key-differences.md"

echo "Reports written to $OUT"
