#!/bin/bash

kubectl --context kind-vault-lab apply -f ./manifests/vault-cluster-1.yml
kubectl wait --namespace vault \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=vault-cluster-1 \
  --timeout=90s

sleep 10
VAULT_ADDR=http://$(kubectl --context kind-vault-lab -n vault get svc/vault-cluster-1-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200
vault operator raft join "http://vault-cluster-0-service.vault.svc.cluster.local:8200"
# vault operator init