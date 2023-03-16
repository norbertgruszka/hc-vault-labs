#!/bin/bash

VAULT_ADDR=http://$(kubectl --context kind-vault-lab -n vault get svc/vault-kms-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200

vault status

vault_init=$(vault operator init -format=json)

echo ""
echo "Unseal vault using 3 keys provided by 'vault operator init' command."
vault operator unseal $(echo $vault_init | jq -r .unseal_keys_hex[0])
vault operator unseal $(echo $vault_init | jq -r .unseal_keys_hex[1])
vault operator unseal $(echo $vault_init | jq -r .unseal_keys_hex[2])

echo ""
echo "Now 'vault status' should show status as initialized and unsealed."
vault status

echo ""
echo "Login using vault root token."
vault login $(echo $vault_init | jq -r .root_token)

echo ""
echo "Create policies"

vault policy write autounseal_admin ./policies/vault-kms/autounseal_admin.hcl
vault policy write policies_admin ./policies/vault-kms/policies_admin.hcl

echo ""
echo "Create tokens"
kubectl create secret generic vault-kms-root-token \
     --context kind-vault-lab \
     --namespace vault \
     --from-literal=token=$(echo $vault_init | jq -r .root_token)

kubectl create secret generic vault-kms-autounseal-admin-token \
     --context kind-vault-lab \
     --namespace vault \
     --from-literal=token=$(vault token create -policy=autounseal_admin -orphan -ttl=24h -explicit-max-ttl=24h -field=token)

kubectl create secret generic vault-kms-policies-admin-token \
     --context kind-vault-lab \
     --namespace vault \
     --from-literal=token=$(vault token create -policy=policies_admin -orphan -ttl=24h -explicit-max-ttl=24h -field=token)

echo ""
echo "Enable secret enginees"
vault secrets enable transit

echo ""
echo "Add transit configurations for other clusters"
vault policy write autounseal_vault_0 ./policies/vault-kms/autounseal_vault_0.hcl
vault write -f transit/keys/vault_0
cat <<EOF | kubectl --context kind-vault-lab create -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-cluster-0-transit-config
  namespace: vault
data:
  transit.hcl: |
    seal "transit" {
       address            = "http://vault-kms-service.vault.svc.cluster.local:8200"
       token              = "$(vault token create -policy=autounseal_vault_0 -orphan -period=24h -field=token)"
       disable_renewal    = "false"
       key_name           = "vault_0"
       mount_path         = "transit/"
       tls_skip_verify    = "true"
    }
EOF

vault policy write autounseal_vault_1 ./policies/vault-kms/autounseal_vault_1.hcl
vault write -f transit/keys/vault_1
cat <<EOF | kubectl --context kind-vault-lab create -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-cluster-1-transit-config
  namespace: vault
data:
  transit.hcl: |
    seal "transit" {
       address            = "http://vault-kms-service.vault.svc.cluster.local:8200"
       token              = "$(vault token create -policy=autounseal_vault_1 -orphan -period=24h -field=token)"
       disable_renewal    = "false"
       key_name           = "vault_1"
       mount_path         = "transit/"
       tls_skip_verify    = "true"
    }
EOF

vault policy write autounseal_vault_2 ./policies/vault-kms/autounseal_vault_2.hcl
vault write -f transit/keys/vault_2
cat <<EOF | kubectl --context kind-vault-lab create -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-cluster-2-transit-config
  namespace: vault
data:
  transit.hcl: |
    seal "transit" {
       address            = "http://vault-kms-service.vault.svc.cluster.local:8200"
       token              = "$(vault token create -policy=autounseal_vault_2 -orphan -period=24h -field=token)"
       disable_renewal    = "false"
       key_name           = "vault_2"
       mount_path         = "transit/"
       tls_skip_verify    = "true"
    }
EOF