#!/bin/bash
set -euo pipefail

set -a
source "$(dirname "$0")/config.env"
set +a

LOG_FILE="${APP_DIR}/deploy/deploy.log"
SERVICE="app.service"
CURRENT_BRANCH=$(git -C "$APP_DIR" rev-parse --abbrev-ref HEAD)

echo "$(date '+%Y-%m-%d %H:%M:%S') — Старт деплоя (ветка: $CURRENT_BRANCH)" >> "$LOG_FILE"

cd "$APP_DIR"

OLD_HASH=$(md5sum app/requirements.txt | awk '{print $1}')
git pull origin "$CURRENT_BRANCH"

NEW_HASH=$(md5sum app/requirements.txt | awk '{print $1}')
if [ "$OLD_HASH" != "$NEW_HASH" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') — requirements.txt изменился, обновляю venv" >> "$LOG_FILE"
    source venv/bin/activate
    pip install -r app/requirements.txt
    deactivate
fi

sudo systemctl restart "$SERVICE"
sleep 2

if curl -sf "localhost:${APP_PORT}/system" > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') — Деплой успешен, сервис отвечает" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') — ОШИБКА: сервис не отвечает после деплоя" >> "$LOG_FILE"
    exit 1
fi
