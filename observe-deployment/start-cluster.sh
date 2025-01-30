!/bin/bash

#minikube config set cpus and memory
minikube start --memory 7836 --cpus 8 --force-systemd #--mount=~/.state/k8s:/tmp/hostpath-provisioner --kubernetes-version v1.18.1

# deploy the observe agent helm chart
helm install observe-agent observe/agent \
  --version 0.32.0 \
  --create-namespace \
  --namespace observe \
  --values observe-values.yaml \
  --set observe.token.value="ds1aw3GHcQCqRHzlqm7p:8YMTMwLjfYL4PJzHHyAJafKteNV7VFo0" \
  --set observe.collectionEndpoint.value="https://100112502756.collect.observeinc.com/" \
  --set cluster.name="minikube-tracing" \
  --set node.containers.logs.enabled="true" \
  --set application.prometheusScrape.enabled="true"