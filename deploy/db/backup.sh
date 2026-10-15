#!/usr/bin/env bash
# Backs up a PostgreSQL database with rotation.
# Runs as OS user postgres: peer authentication, no password stored anywhere.
# Usage: sudo -u postgres ./backup.sh     (DB, BACKUP_DIR, KEEP can be overridden)
set -euo pipefail

DB="${DB:-inventory}"
DIR="${BACKUP_DIR:-/var/backups/postgresql}"
KEEP="${KEEP:-7}"
FILE="$DIR/${DB}_$(date +%Y-%m-%d_%H-%M-%S).dump"

# Write to .tmp first: an interrupted dump never looks like a valid backup
pg_dump --format=custom --dbname="$DB" --file="$FILE.tmp"
mv "$FILE.tmp" "$FILE"
echo "backup ok: $FILE ($(du -h "$FILE" | cut -f1))"

# Keep only the newest $KEEP dumps
ls -1t "$DIR"/"${DB}"_*.dump | tail -n +$((KEEP + 1)) | xargs -r rm -v --
