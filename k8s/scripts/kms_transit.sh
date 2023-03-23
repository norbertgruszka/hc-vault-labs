#!/bin/bash

VAULT_ADDR=http://$(kubectl --context kind-vault-lab -n vault get svc/vault-kms-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200

vault login $(kubectl -n vault get secret/vault-kms-root-token -o jsonpath='{.data.token}' | base64 -d)

vault policy write autounseal_admin ./policies/vault-kms/autounseal_admin.hcl

vault secrets enable transit

vault policy write autounseal_vault_0 ./policies/vault-kms/autounseal_vault_0.hcl
vault policy write autounseal_vault_1 ./policies/vault-kms/autounseal_vault_1.hcl
vault policy write autounseal_vault_2 ./policies/vault-kms/autounseal_vault_2.hcl

vault write -f transit/keys/vault_0
vault write -f transit/keys/vault_1
vault write -f transit/keys/vault_2

kubectl create secret generic vault-cluster-0-unseal-token \
     --context kind-vault-lab \
     --namespace vault \
     --from-literal=token=$(vault token create -policy=autounseal_vault_0 -orphan -period=24h -field=token)
kubectl create secret generic vault-cluster-1-unseal-token \
     --context kind-vault-lab \
     --namespace vault \
     --from-literal=token=$(vault token create -policy=autounseal_vault_1 -orphan -period=24h -field=token)
kubectl create secret generic vault-cluster-2-unseal-token \
     --context kind-vault-lab \
     --namespace vault \
     --from-literal=token=$(vault token create -policy=autounseal_vault_2 -orphan -period=24h -field=token)