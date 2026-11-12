#!/usr/bin/env bash
# Report backup age and fail when it exceeds the alert threshold (task 7.5).
#
#   scripts/backup-status.sh            # human-readable, exit 1 when stale/failed
#   scripts/backup-status.sh --json     # raw status document
#
# Reads /backups/status.json from the backup container in the composed stack.
set -euo pipefail
cd "$(dirname "$0")/.."

PROJECT="${XOPTI_BACKUP_PROJECT:-xopti-backup}"
COMPOSE=(docker compose -p "$PROJECT" -f docker/compose.yml -f docker/compose.backup.yml)
MAX_AGE="${XOPTI_BACKUP_MAX_AGE_SECONDS:-129600}" # 36 hours: one daily run plus slack

container="$("${COMPOSE[@]}" ps -q backup 2>/dev/null || true)"
if [ -z "$container" ]; then
  echo "backup container is not running for project '$PROJECT'" >&2
  exit 2
fi

status="$(docker exec "$container" cat /backups/status.json 2>/dev/null || true)"
if [ -z "$status" ]; then
  echo "backup status is missing (no backup has run yet)" >&2
  exit 2
fi

if [ "${1:-}" = "--json" ]; then
  echo "$status"
  exit 0
fi

last_epoch="$(sed -n 's/.*"last_success_epoch": *\([0-9]*\).*/\1/p' <<<"$status")"
state="$(sed -n 's/.*"status": *"\([^"]*\)".*/\1/p' <<<"$status")"
directory="$(sed -n 's/.*"last_success_directory": *"\([^"]*\)".*/\1/p' <<<"$status")"
message="$(sed -n 's/.*"message": *"\([^"]*\)".*/\1/p' <<<"$status")"

now="$(date -u +%s)"
age=$(( now - ${last_epoch:-0} ))
hours=$(( age / 3600 ))

echo "backup state: $state"
echo "last successful backup: ${directory:-none} (${hours}h ago)"
echo "alert threshold: $(( MAX_AGE / 3600 ))h"

if [ "$state" != "success" ]; then
  echo "BACKUP FAILURE: $message" >&2
  exit 1
fi
if [ "$age" -gt "$MAX_AGE" ]; then
  echo "BACKUP STALE: last success is ${hours}h old" >&2
  exit 1
fi

echo "backup age is within the alert threshold."
