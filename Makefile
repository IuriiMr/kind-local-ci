KIND_CLUSTER_NAME=harbor
HARBOR_RELEASE_NAME=harbor
HARBOR_NAMESPACE=harbor



.PHONY: all setup clean gitlab-up gitlab-down runner-up runner-down fetch-token

all: setup

setup:
	kind create cluster --config kind-config.yaml || true
	helm repo add harbor https://helm.goharbor.io
	helm repo update
	helm upgrade --install $(HARBOR_RELEASE_NAME) harbor/harbor \
		--namespace $(HARBOR_NAMESPACE) --create-namespace \
		-f harbor-values.yaml

clean:
	kind delete cluster --name $(KIND_CLUSTER_NAME)

gitlab-up:
	docker compose up -d

gitlab-down:
	docker compose down

init-runner: wait register-runner

wait:
	@echo "[INFO] Waiting for GitLab container 'gitlab' to become healthy..."
	@max=60; \
	interval=5; \
	for i in $$(seq 1 $$max); do \
		status=$$(docker inspect --format='{{.State.Health.Status}}' gitlab 2>/dev/null); \
		if [ "$$status" = "healthy" ]; then \
			echo "[INFO] GitLab is healthy."; \
			exit 0; \
		fi; \
		echo -n "."; \
		sleep $$interval; \
	done; \
	echo ""; \
	echo "[ERROR] Timeout waiting for GitLab container to become healthy."; \
	exit 1


register-runner:
	@echo "🔐 Fetching GitLab registration token..."
	$(eval TOKEN := $(shell docker exec -it gitlab gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token" | tr -d '\r'))

	@echo "🔧 Registering runner in container..."
	docker exec -it runner gitlab-runner register \
		--non-interactive \
		--url "http://gitlab/" \
		--registration-token "$(TOKEN)" \
		--executor "docker" \
		--docker-host "tcp://dind:2375" \
		--docker-image "docker:latest" \
		--description "dind-runner" \
		--docker-privileged \
		--docker-volumes "/cache" \
		--docker-network-mode "host" \
		--docker-extra-hosts "host.docker.internal:host-gateway"


	@echo "✅ Runner registered successfully."

unregister-runner:
	docker exec -it runner gitlab-runner unregister --all-runners


GITLAB_NET=gitlab_net

init-network: connect-control-plane set-harbor-url

connect-control-plane:
	@docker network connect $(GITLAB_NET) harbor-control-plane 2>/dev/null || echo "Already connected"

get-control-plane-ip:
	@IP=$$(docker inspect -f '{{range $$k, $$v := .NetworkSettings.Networks}}{{if eq $$k "harbor-kind-local_gitlab_net"}}{{$$v.IPAddress}}{{end}}{{end}}' harbor-control-plane); \
	echo "Control plane IP on harbor-kind-local_gitlab_net: $$IP"

set-harbor-url:
	@IP=$$(docker inspect -f '{{range $$k, $$v := .NetworkSettings.Networks}}{{if eq $$k "harbor-kind-local_gitlab_net"}}{{$$v.IPAddress}}{{end}}{{end}}' harbor-control-plane); \
	echo "HARBOR_URL=http://$$IP:30003" > .env; \
	echo "✅ HARBOR_URL=http://$$IP:30003 written to .env"
