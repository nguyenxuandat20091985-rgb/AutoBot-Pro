#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${AUTOBOT_REPO:-https://github.com/nguyenxuandat20091985-rgb/AutoBot-Pro.git}"
APP_DIR="${AUTOBOT_DIR:-/opt/autobotpro}"

[[ $EUID -eq 0 ]] || { echo 'Run as root.' >&2; exit 1; }
apt-get update
apt-get install -y ca-certificates curl git docker.io docker-compose-plugin
systemctl enable --now docker
mkdir -p "$APP_DIR"
if [[ -d "$APP_DIR/.git" ]]; then
  git -C "$APP_DIR" fetch --depth 1 origin main
  git -C "$APP_DIR" reset --hard origin/main
else
  git clone --depth 1 --branch main "$REPO" "$APP_DIR"
fi
cd "$APP_DIR"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo 'Created /opt/autobotpro/.env. Edit it with your domains, secrets and passwords, then run:'
  echo '  cd /opt/autobotpro && docker compose -f docker-compose.prod.yml up -d'
  exit 0
fi

docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d

echo 'AutoBot Pro containers started.'
