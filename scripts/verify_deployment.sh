#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:?TARGET_HOST is required}"
TARGET_HOST="$(echo "$TARGET_HOST" | tr -d '[:space:]')"

BASE_URL="http://$TARGET_HOST"

echo "Verifying deployment at $BASE_URL"

for attempt in $(seq 1 30); do
  echo "Attempt $attempt/30: checking root endpoint..."

  if curl -fsS "$BASE_URL/" > /tmp/mywebapp_root.html; then
    echo "Root endpoint is available."
    break
  fi

  if [ "$attempt" -eq 30 ]; then
    echo "Root endpoint did not become available."
    exit 1
  fi

  sleep 3
done

for attempt in $(seq 1 30); do
  echo "Attempt $attempt/30: checking items endpoint..."

  if curl -fsS "$BASE_URL/items" > /tmp/mywebapp_items.json; then
    echo "Items endpoint is available."
    break
  fi

  if [ "$attempt" -eq 30 ]; then
    echo "Items endpoint did not become available."
    exit 1
  fi

  sleep 3
done

echo "Deployment verification passed."