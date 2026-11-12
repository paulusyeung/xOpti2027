#!/bin/sh
# Scheduled base backup + retention + failure alerting (task 7.5).
#
# Runs in the postgres:17-alpine image, which already contains pg_basebackup.
# WAL archiving is configured on the postgres service by docker/compose.backup.yml.
set -eu

: "${PGHOST:=postgres}"
: "${PGUSER:=postgres}"
: "${BACKUP_DIR:=/backups}"
: "${BACKUP_INTERVAL_SECONDS:=86400}"
: "${BACKUP_RETENTION_DAYS:=14}"
: "${BACKUP_STATUS_FILE:=$BACKUP_DIR/status.json}"
: "${XOPTI_ALERT_WEBHOOK:=}"

mkdir -p "$BACKUP_DIR/base"

write_status() {
  # arguments: status, started_at, finished_at, epoch, directory, size_bytes, message
  tmp="$BACKUP_STATUS_FILE.tmp"
  cat >"$tmp" <<EOF
{
  "status": "$1",
  "started_at": "$2",
  "finished_at": "$3",
  "last_success_epoch": $4,
  "last_success_directory": "$5",
  "size_bytes": $6,
  "message": "$7"
}
EOF
  mv "$tmp" "$BACKUP_STATUS_FILE"
}

alert() {
  message="$1"
  echo "ALERT: $message" >&2
  if [ -n "$XOPTI_ALERT_WEBHOOK" ]; then
    wget -q -O /dev/null --header='Content-Type: application/json' \
      --post-data="{\"service\":\"xopti-backup\",\"message\":\"$message\"}" \
      "$XOPTI_ALERT_WEBHOOK" || echo "ALERT: webhook delivery failed" >&2
  fi
}

run_backup() {
  started="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  stamp="$(date -u +%Y%m%dT%H%M%SZ)"
  target="$BACKUP_DIR/base/$stamp"
  log="$BACKUP_DIR/last-backup.log"

  if pg_basebackup -h "$PGHOST" -U "$PGUSER" -D "$target" -Ft -z -X stream -c fast >"$log" 2>&1; then
    finished="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    epoch="$(date -u +%s)"
    size="$(du -sb "$target" | cut -f1)"
    write_status success "$started" "$finished" "$epoch" "$stamp" "$size" "base backup complete"
    echo "backup $stamp complete ($size bytes)."

    # Retention: remove base backups older than the configured window.
    find "$BACKUP_DIR/base" -mindepth 1 -maxdepth 1 -type d -mtime "+$BACKUP_RETENTION_DAYS" \
      -exec rm -rf {} + 2>/dev/null || true
    return 0
  fi

  finished="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  previous="$BACKUP_DIR/status.json"
  epoch="$(sed -n 's/.*"last_success_epoch": *\([0-9]*\).*/\1/p' "$previous" 2>/dev/null || echo 0)"
  message="$(tail -n 3 "$log" 2>/dev/null | tr '\n' ' ' | tr '"' "'")"
  write_status failed "$started" "$finished" "${epoch:-0}" "" 0 "$message"
  alert "base backup failed: $message"
  return 1
}

if ! run_backup; then
  [ "${BACKUP_ONCE:-0}" = "1" ] && exit 1
fi

if [ "${BACKUP_ONCE:-0}" = "1" ]; then
  exit 0
fi

while :; do
  sleep "$BACKUP_INTERVAL_SECONDS"
  run_backup || true
done
