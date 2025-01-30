!/bin/bash

# deploy the observe agent helm chart. You will need to update the ENDPOINT and TOKEN below!
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