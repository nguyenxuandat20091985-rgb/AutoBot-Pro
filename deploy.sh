#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${AUTOBOT_REPO:-https://github.com/nguyenxuandat20091985-rgb/AutoBot-Pro.git}"
APP_DIR="${AUTOBOT_DIR:-/opt/autobotpro}"

[[ $EUID -eq 0 ]] || { echo 'Run as root.' >&2; exit 1; }
apt-get update
apt-get install -y ca-certificates curl git certbot docker.io docker-compose-plugin
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
  sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$(openssl rand -hex 24)|" .env || true
  sed -i "s|^ENCRYPTION_SECRET=.*|ENCRYPTION_SECRET=$(openssl rand -hex 32)|" .env || true
  sed -i "s|^MINIO_ROOT_USER=.*|MINIO_ROOT_USER=autobotpro|" .env || true
  sed -i "s|^MINIO_ROOT_PASSWORD=.*|MINIO_ROOT_PASSWORD=$(openssl rand -hex 24)|" .env || true
  echo
  echo 'First deployment requires DNS and domain configuration.'
  read -r -p 'Builder domain (e.g. admin.example.com): ' BUILDER
  read -r -p 'Viewer domain (e.g. bot.example.com): ' VIEWER
  read -r -p 'Certificate email: ' EMAIL
  CERT_NAME="$BUILDER"
  sed -i "s|^NEXTAUTH_URL=.*|NEXTAUTH_URL=https://$BUILDER|" .env
  sed -i "s|^NEXT_PUBLIC_VIEWER_URL=.*|NEXT_PUBLIC_VIEWER_URL=https://$VIEWER|" .env
  sed -i "s|^BUILDER_DOMAIN=.*|BUILDER_DOMAIN=$BUILDER|" .env
  sed -i "s|^VIEWER_DOMAIN=.*|VIEWER_DOMAIN=$VIEWER|" .env
  sed -i "s|^CERT_NAME=.*|CERT_NAME=$CERT_NAME|" .env
  sed -i "s|^CERTBOT_EMAIL=.*|CERTBOT_EMAIL=$EMAIL|" .env
  sed -i "s|^ADMIN_EMAIL=.*|ADMIN_EMAIL=$EMAIL|" .env
  # Keep DATABASE_URL synchronized with the generated PostgreSQL password.
  DBPASS="$(grep '^POSTGRES_PASSWORD=' .env | cut -d= -f2-)"
  sed -i "s|^DATABASE_URL=.*|DATABASE_URL=postgresql://typebot:${DBPASS}@postgres:5432/typebot|" .env
fi

set -a
. ./.env
set +a
: "${BUILDER_DOMAIN:?BUILDER_DOMAIN is required}"
: "${VIEWER_DOMAIN:?VIEWER_DOMAIN is required}"
: "${CERTBOT_EMAIL:?CERTBOT_EMAIL is required}"
: "${CERT_NAME:?CERT_NAME is required}"

mkdir -p letsencrypt
if [[ ! -f "letsencrypt/live/$CERT_NAME/fullchain.pem" ]]; then
  docker compose -f docker-compose.prod.yml down --remove-orphans || true
  certbot certonly --standalone --non-interactive --agree-tos --email "$CERTBOT_EMAIL" --cert-name "$CERT_NAME" -d "$BUILDER_DOMAIN" -d "$VIEWER_DOMAIN"
  # certbot writes under /etc/letsencrypt; copy into the bind-mounted directory.
  rm -rf letsencrypt
  cp -a /etc/letsencrypt ./letsencrypt
fi

docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d

echo 'AutoBot Pro production stack is running.'
