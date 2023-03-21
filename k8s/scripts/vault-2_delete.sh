#!/bin/bash
kubectl --context kind-vault-lab delete -f ./manifests/vault-cluster-2.yml
# kubectl --context kind-vault-lab --namespace vault delete secret vault-vault-2-root-token