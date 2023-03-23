#!/bin/bash

kubectl --context kind-vault-lab apply -f ./manifests/vault-cluster-0.yml
kubectl wait --namespace vault \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=vault-cluster-0 \
  --timeout=90s

sleep 10

VAULT_ADDR=http://$(kubectl --context kind-vault-lab -n vault get svc/vault-cluster-0-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200
vault_init=$(vault operator init -format=json)

kubectl create secret generic vault-vault-0-root-token \
     --context kind-vault-lab \
     --namespace vault \
     --from-literal=token=$(echo $vault_init | jq -r .root_token)

vault login $(echo $vault_init | jq -r .root_token)
vault status

kubectl --context kind-vault-lab apply -f ./manifests/vault-cluster-1.yml
kubectl wait --namespace vault \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=vault-cluster-1 \
  --timeout=90s

kubectl --context kind-vault-lab apply -f ./manifests/vault-cluster-2.yml
kubectl wait --namespace vault \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=vault-cluster-2 \
  --timeout=90s

sleep 10
vault operator raft list-peers

# echo "switch to vault-1"

# VAULT_ADDR=http://$(kubectl --context kind-vault-lab -n vault get svc/vault-cluster-1-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200
# vault login $(kubectl -n vault get secrets vault-vault-0-root-token -o jsonpath='{.data.token}' | base64 -d)
# vault operator raft list-peers