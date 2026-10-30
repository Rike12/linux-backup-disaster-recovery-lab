#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

log() {
    printf '[%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <backup_archive> <restore_directory>"
    exit 1
fi

ARCHIVE="$1"
RESTORE_DIR="$2"

if [[ ! -f "$ARCHIVE" ]]; then
    log "ERROR: Backup archive not found"
    exit 1
fi

if [[ ! -f "${ARCHIVE}.sha256" ]]; then
    log "ERROR: Checksum file not found"
    exit 1
fi

if ! sha256sum -c "${ARCHIVE}.sha256"; then
    log "ERROR: Checksum verification failed"
    exit 1
fi

log "Checksum verification successful"

if ! gzip -t "$ARCHIVE"; then
    log "ERROR: Backup archive is corrupted"
    exit 1
fi

if ! tar -tzf "$ARCHIVE" >/dev/null; then
    log "ERROR: Unable to read backup archive"
    exit 1
fi

log "Archive validation successful"

if [[ -e "$RESTORE_DIR" ]]; then
    log "ERROR: Restore destination already exists"
    exit 1
fi

mkdir -p "$(dirname -- "$RESTORE_DIR")"

TEMP_DIR="$(mktemp -d "$(dirname -- "$RESTORE_DIR")/.restore.XXXXXX")"

cleanup() {
    rm -rf -- "${TEMP_DIR:-}"
}

trap cleanup EXIT

tar -xzf "$ARCHIVE" \
    -C "$TEMP_DIR" \
    --no-same-owner \
    --no-same-permissions

mv -- "$TEMP_DIR" "$RESTORE_DIR"

log "Recovery completed successfully"
log "Restored files to: $RESTORE_DIR"
