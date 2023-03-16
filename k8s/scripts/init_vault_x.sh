#!/bin/bash

VAULT_ADDR=http://$(kubectl --context kind-vault-lab -n vault get svc/vault-cluster-0-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200
vault operator init

VAULT_ADDR=http://$(kubectl --context kind-vault-lab -n vault get svc/vault-cluster-1-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200
vault operator init

VAULT_ADDR=http://$(kubectl --context kind-vault-lab -n vault get svc/vault-cluster-2-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'):8200
vault operator init