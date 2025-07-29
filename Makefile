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
	-kind delete cluster --name $$(kind get clusters | grep -E 'devcluster|kind|harbor|gitlab' || echo kind)
	-docker ps -a --filter "name=kind" -q | xargs -r docker rm -f
	-docker network ls --filter "name=kind" -q | xargs -r docker network rm
	-docker volume ls --filter "name=kind" -q | xargs -r docker volume rm
