#!/bin/bash

kubectl --context kind-vault-lab apply -f ./manifests/vault-cluster-0.yml
kubectl wait --namespace vault \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=vault-cluster-0 \
  --timeout=90s

sleep 15

VAULT_ADDR=http://$(kubectl --context kind-vault-lab -n vault get svc/vault-cluster-0-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200
vault_init=$(vault operator init -format=json)
# vault operator unseal $(echo $vault_init | jq -r .unseal_keys_hex[0])
# vault operator unseal $(echo $vault_init | jq -r .unseal_keys_hex[1])
# vault operator unseal $(echo $vault_init | jq -r .unseal_keys_hex[2])
kubectl create secret generic vault-vault-0-root-token \
     --context kind-vault-lab \
     --namespace vault \
     --from-literal=token=$(echo $vault_init | jq -r .root_token)