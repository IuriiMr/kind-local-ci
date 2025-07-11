#!/bin/bash

CONTAINER_NAME=gitlab

echo "[INFO] Waiting for GitLab to become healthy..."
until [ "$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null)" == "healthy" ]; do
  echo -n "."
  sleep 5
done
echo -e "[INFO] GitLab is healthy."
