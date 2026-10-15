#!/usr/bin/env bash
# Proves the latest backup is usable: restores it into a temporary database
# and compares row counts of every table with the live database.
# Usage: sudo -u postgres ./restore-check.sh
set -euo pipefail

DB="${DB:-inventory}"
DIR="${BACKUP_DIR:-/var/backups/postgresql}"
TMP="${DB}_restore_check"

LATEST=$(ls -1t "$DIR"/"${DB}"_*.dump | head -n 1)
echo "checking: $LATEST"

dropdb --if-exists "$TMP"
createdb "$TMP"
pg_restore --dbname="$TMP" "$LATEST"

status=0
for t in $(psql -tAc "SELECT tablename FROM pg_tables WHERE schemaname = 'public'" -d "$DB"); do
    src=$(psql -tAc "SELECT count(*) FROM $t" -d "$DB")
    dst=$(psql -tAc "SELECT count(*) FROM $t" -d "$TMP")
    printf '%-12s live=%-5s restored=%s\n' "$t" "$src" "$dst"
    [ "$src" = "$dst" ] || status=1
done

dropdb "$TMP"
[ $status -eq 0 ] && echo "restore check OK" || { echo "restore check FAILED"; exit 1; }
