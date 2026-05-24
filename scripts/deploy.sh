#!/usr/bin/env bash
# shellcheck disable=SC2029
set -euo pipefail

TARGET_HOST="${TARGET_HOST:?TARGET_HOST is required}"
TARGET_USER="${TARGET_USER:?TARGET_USER is required}"
IMAGE_TAG="${IMAGE_TAG:?IMAGE_TAG is required}"
IMAGE_NAME="${IMAGE_NAME:?IMAGE_NAME is required}"

TARGET_HOST="$(echo "$TARGET_HOST" | tr -d '[:space:]')"
TARGET_USER="$(echo "$TARGET_USER" | tr -d '[:space:]')"

APP_DIR="/opt/mywebapp"

ssh "$TARGET_USER@$TARGET_HOST" \
  "IMAGE_NAME='$IMAGE_NAME' IMAGE_TAG='$IMAGE_TAG' APP_DIR='$APP_DIR' bash -s" <<'EOF'
set -euo pipefail

cd "$APP_DIR"

export IMAGE_NAME
export IMAGE_TAG

cat > .env <<ENVEOF
IMAGE_NAME=$IMAGE_NAME
IMAGE_TAG=$IMAGE_TAG
ENVEOF

docker pull "$IMAGE_NAME:$IMAGE_TAG"

sudo cp deploy/mywebapp-compose.service /etc/systemd/system/mywebapp.service
sudo systemctl daemon-reload
sudo systemctl enable mywebapp.service
sudo systemctl restart mywebapp.service
sudo systemctl status mywebapp.service --no-pager
EOF