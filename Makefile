KIND_CLUSTER_NAME=harbor
HARBOR_RELEASE_NAME=harbor
HARBOR_NAMESPACE=harbor

.PHONY: all setup clean

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