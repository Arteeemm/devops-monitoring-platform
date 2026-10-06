#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

sudo apt update
sudo apt install nginx -y

sudo cp deploy/nginx/app.conf /etc/nginx/sites-available/app
sudo ln -sf /etc/nginx/sites-available/app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl restart nginx
