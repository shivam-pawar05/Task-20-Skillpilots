#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$PROJECT_DIR/config/backup.conf}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing config: $CONFIG_FILE" >&2
  echo "Copy config/backup.conf.example to config/backup.conf." >&2
  exit 1
fi

# Only source a configuration file maintained by a trusted administrator.
# shellcheck disable=SC1090
source "$CONFIG_FILE"

: "${DB_NAME:?Set DB_NAME in backup.conf}"
: "${DB_USER:?Set DB_USER in backup.conf}"
: "${DB_HOST:=localhost}"
: "${DB_PORT:=5432}"
: "${BACKUP_DIR:=$PROJECT_DIR/backups}"
: "${LOG_DIR:=$PROJECT_DIR/logs}"
: "${RETENTION_DAYS:=14}"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"
STAMP="$(date '+%Y%m%d_%H%M%S')"
DEST="$BACKUP_DIR/${DB_NAME}_${STAMP}.dump"
TEMP="${DEST}.tmp"
LOG="$LOG_DIR/backup.log"

log() {
  printf '[%s] %s\n' "$(date '+%F %T')" "$*" | tee -a "$LOG"
}
trap 'rm -f "$TEMP"' EXIT

export PGHOST="$DB_HOST" PGPORT="$DB_PORT" PGUSER="$DB_USER"
log "Starting backup for $DB_NAME"

if ! pg_dump --format=custom --no-owner --no-acl \
    --file="$TEMP" "$DB_NAME" >>"$LOG" 2>&1; then
  log "ERROR: pg_dump failed"
  exit 1
fi

if [[ ! -s "$TEMP" ]]; then
  log "ERROR: backup file is empty"
  exit 1
fi

mv "$TEMP" "$DEST"
log "Backup created: $DEST"

if [[ "$RETENTION_DAYS" =~ ^[0-9]+$ ]] && (( RETENTION_DAYS > 0 )); then
  find "$BACKUP_DIR" -maxdepth 1 -type f \
    -name "${DB_NAME}_*.dump" -mtime "+$RETENTION_DAYS" -delete
  log "Removed matching backups older than $RETENTION_DAYS days"
fi

log "Backup job completed successfully"
