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

wait:
	bash wait-gitlab.sh

runner-up:
	TOKEN=$(bash get-token.sh | grep REGISTRATION_TOKEN | cut -d '=' -f 2) && \
    helm repo add gitlab https://charts.gitlab.io && \
    helm repo update && \
    kubectl create namespace gitlab-runner || true && \
    helm upgrade --install gitlab-runner gitlab/gitlab-runner \
      --namespace gitlab-runner \
      --set gitlabUrl=http://host.docker.internal:8080/ \
      --set runnerRegistrationToken=$TOKEN \
      --set rbac.create=true \
      --set serviceAccount.create=true \
      --set serviceAccount.name=gitlab-runner

runner-down:
	helm uninstall gitlab-runner -n gitlab-runner || true
	kubectl delete namespace gitlab-runner || true
