#!/bin/bash

CONTAINER_NAME=gitlab
MAX_ATTEMPTS=60
SLEEP_INTERVAL=5

echo "[INFO] Waiting for GitLab container '$CONTAINER_NAME' to become healthy..."

for i in $(seq 1 $MAX_ATTEMPTS); do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null)

  if [[ "$STATUS" == "healthy" ]]; then
    echo -e "\n[INFO] GitLab is healthy."
    exit 0
  fi

  echo -n "."
  sleep $SLEEP_INTERVAL
done

echo -e "\n[ERROR] Timeout waiting for GitLab container to become healthy."
exit 1

