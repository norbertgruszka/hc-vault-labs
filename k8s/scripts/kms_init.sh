#!/bin/bash

# Create KMS Vault
kubectl --context kind-vault-lab apply -f ./manifests/vault-kms.yml
echo "Waiting for KMS Vault to start..."
kubectl wait --namespace vault \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=vault-kms \
  --timeout=90s

while [ "$(vault status -format=json | jq -r .initialized)" != "true" ]; do sleep 5; done
echo "Vault is initialized"

VAULT_ADDR=http://$(kubectl --context kind-vault-lab -n vault get svc/vault-kms-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200

vault_init=$(vault operator init -format=json)

echo $vault_init | jq .

echo "Unseal vault using 3 keys provided by 'vault operator init' command."
vault operator unseal $(echo $vault_init | jq -r .unseal_keys_hex[0])
vault operator unseal $(echo $vault_init | jq -r .unseal_keys_hex[1])
vault operator unseal $(echo $vault_init | jq -r .unseal_keys_hex[2])

vault status

echo "Store root tokens"
kubectl create secret generic vault-kms-root-token \
     --context kind-vault-lab \
     --namespace vault \
     --from-literal=token=$(echo $vault_init | jq -r .root_token)