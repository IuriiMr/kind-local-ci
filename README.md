
## Install gitlab

kind create cluster --image kindest/node:v1.28.0 --config kind-config.yaml
kubectl create namespace gitlab
helm repo update
helm upgrade --install gitlab gitlab/gitlab --namespace gitlab --create-namespace -f gitlab-values.yaml


## Check routing de merde

kubectl -n gitlab get svc gitlab-webservice-default
kubectl -n gitlab get svc gitlab-gitlab-shell
