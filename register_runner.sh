#!/bin/bash

set -e

GITLAB_CONTAINER_NAME="harbor-kind-local-gitlab-1"
RUNNER_NAME="local-runner"
GITLAB_URL="http://gitlab"
RUNNER_IMAGE="gitlab/gitlab-runner:latest"

echo "[INFO] Getting runner registration token..."
TOKEN=$(docker exec "$GITLAB_CONTAINER_NAME" gitlab-rails runner \
  "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token" | tr -d '[:space:]')

if [[ -z "$TOKEN" ]]; then
  echo "[ERROR] Failed to retrieve GitLab runner token."
  exit 1
fi

echo "[INFO] Token acquired: $TOKEN"



#docker exec -it harbor-kind-local-gitlab-runner-1 gitlab-runner unregister --all-runners

docker exec -it harbor-kind-local-gitlab-runner-1 gitlab-runner register \
  --non-interactive \
  --url "http://gitlab/" \
  --registration-token "$TOKEN" \
  --executor "docker" \
  --docker-image "docker:latest" \
  --description "runner-with-host-mapping" \
  --docker-extra-hosts "gitlab:host-gateway"


#echo "[INFO] Registering the GitLab runner..."
#docker run --rm -t -v gitlab_runner_config:/etc/gitlab-runner \
#  "$RUNNER_IMAGE" register \
#  --non-interactive \
#  --url "$GITLAB_URL" \
#  --registration-token "$TOKEN" \
#  --executor "docker" \
#  --docker-image "docker:latest" \
#  --description "$RUNNER_NAME" \
#  --tag-list "docker" \
#  --run-untagged="true" \
#  --locked="false"
#
#echo "[INFO] Runner '$RUNNER_NAME' registered successfully."
