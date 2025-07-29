
## Install gitlab

kind create cluster --config kind-config.yaml \
&& kubectl create namespace gitlab \
&& kubectl create namespace harbor \
&& kubectl apply -f kind-secrets.yaml --namespace gitlab \
&& helm upgrade --install gitlab gitlab/gitlab \
--namespace gitlab -f gitlab-values.yaml \
&& helm upgrade --install harbor harbor/harbor \
--namespace harbor -f harbor-values.yaml

