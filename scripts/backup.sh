#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

CONFIG_FILE="${BACKUP_CONFIG:-$PROJECT_ROOT/config/backup.conf}"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE" >&2
    exit 1
fi

source "$CONFIG_FILE"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

LOG_FILE="$LOG_DIR/backup.log"

log() {
    printf '[%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$*" \
        | tee -a "$LOG_FILE"
}

fail() {
    log "ERROR: $*"
    exit 1
}

if [[ ! -d "$SOURCE_DIR" ]]; then
    fail "Source directory does not exist: $SOURCE_DIR"
fi

if [[ ! "$RETENTION_DAYS" =~ ^[0-9]+$ ]] ||
   (( RETENTION_DAYS < 1 )); then
    fail "RETENTION_DAYS must be a positive integer"
fi

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

ARCHIVE="$BACKUP_DIR/backup_${TIMESTAMP}.tar.gz"
TMP_ARCHIVE="$BACKUP_DIR/.backup_${TIMESTAMP}.tmp"

cleanup() {
    rm -f -- "${TMP_ARCHIVE:-}"
}

trap cleanup EXIT

log "Starting backup"
log "Source: $SOURCE_DIR"

tar -czf "$TMP_ARCHIVE" -C "$SOURCE_DIR" .

gzip -t "$TMP_ARCHIVE" ||
    fail "Compressed archive integrity check failed"

tar -tzf "$TMP_ARCHIVE" >/dev/null ||
    fail "Unable to list archive contents"

mv -- "$TMP_ARCHIVE" "$ARCHIVE"

sha256sum "$ARCHIVE" > "${ARCHIVE}.sha256"
log "Backup created: $ARCHIVE"
log "SHA-256 checksum saved"

while IFS= read -r -d '' old_archive; do
    rm -f -- "$old_archive" "${old_archive}.sha256"
    log "Removed expired backup: $old_archive"
done < <(
    find "$BACKUP_DIR" \
        -maxdepth 1 \
        -type f \
        -name 'backup_*.tar.gz' \
        -mtime "+$RETENTION_DAYS" \
        -print0
)

log "Backup completed successfully"
