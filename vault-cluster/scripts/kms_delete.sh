#!/bin/bash
kubectl --context kind-vault-lab delete -f ./manifests/vault-kms.yml
kubectl --context kind-vault-lab --namespace vault delete secret vault-kms-root-token
kubectl --context kind-vault-lab --namespace vault delete secret vault-cluster-0-unseal-token
kubectl --context kind-vault-lab --namespace vault delete secret vault-cluster-1-unseal-token
kubectl --context kind-vault-lab --namespace vault delete secret vault-cluster-2-unseal-token
