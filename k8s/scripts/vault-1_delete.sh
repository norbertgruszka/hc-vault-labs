#!/bin/bash
kubectl --context kind-vault-lab delete -f ./manifests/vault-cluster-1.yml
# kubectl --context kind-vault-lab --namespace vault delete secret vault-vault-1-root-token