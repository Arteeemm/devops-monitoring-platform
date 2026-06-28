#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

set -a
source config.env
set +a

envsubst < app.service.template > /tmp/app.service
sudo cp /tmp/app.service /etc/systemd/system/app.service
sudo systemctl daemon-reload
sudo systemctl restart app.service
