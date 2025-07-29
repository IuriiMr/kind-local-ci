.PHONY: all cluster namespaces secrets gitlab harbor delete

all: cluster namespaces secrets gitlab harbor

cluster:
	kind create cluster --config kind-config.yaml

namespaces:
	kubectl create namespace gitlab || true
	kubectl create namespace harbor || true

secrets: namespaces
	kubectl apply -f kind-secrets.yaml --namespace gitlab

gitlab: cluster secrets
	helm upgrade --install gitlab gitlab/gitlab --namespace gitlab -f gitlab-values.yaml

harbor: cluster
	helm upgrade --install harbor harbor/harbor --namespace harbor -f harbor-values.yaml

delete:
	# Delete the Kind cluster (removes all related containers and network)
	-kind delete cluster --name $$(kind get clusters | grep -E 'devcluster|kind|harbor|gitlab' || echo kind)
	# Clean up any remaining Docker containers/networks/volumes created by Kind, if any
	-docker ps -a --filter "name=kind" -q | xargs -r docker rm -f
	-docker network ls --filter "name=kind" -q | xargs -r docker network rm
	-docker volume ls --filter "name=kind" -q | xargs -r docker volume rm



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
