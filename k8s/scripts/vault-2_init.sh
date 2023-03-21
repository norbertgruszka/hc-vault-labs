#!/bin/bash

kubectl --context kind-vault-lab apply -f ./manifests/vault-cluster-2.yml
kubectl wait --namespace vault \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=vault-cluster-2 \
  --timeout=90s

# sleep 30
# VAULT_ADDR=http://$(kubectl --context kind-vault-lab -n vault get svc/vault-cluster-2-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200