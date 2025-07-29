
## Install gitlab

kind create cluster --image kindest/node:v1.32.2 --config kind-config.yaml
kubectl create namespace gitlab
helm repo update
helm upgrade --install gitlab gitlab/gitlab --namespace gitlab --create-namespace -f gitlab-values.yaml


## Check routing de merde

kubectl -n gitlab get svc gitlab-webservice-default
kubectl -n gitlab get svc gitlab-gitlab-shell


kind create cluster --config examples/kind/kind-no-ssl.yaml
helm upgrade --install gitlab gitlab/gitlab \
--set global.hosts.domain=192.168.4.112.nip.io \
-f examples/kind/values-base.yaml \
-f examples/kind/values-no-ssl.yaml


kind create cluster --config kind-config.yaml
helm upgrade --install gitlab gitlab/gitlab \
--namespace gitlab --create-namespace \
-f gitlab-values.yaml

[//]: # (--set global.hosts.domain=192.168.4.112.nip.io \)


kind create cluster --config kind-config.yaml \
&& kubectl create namespace gitlab \
&& kubectl apply -f kind-secrets.yaml \
--namespace gitlab \
&& helm upgrade --install gitlab gitlab/gitlab \
--namespace gitlab \
-f gitlab-values.yaml
