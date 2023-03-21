#!/bin/bash
kubectl --context kind-vault-lab delete -f ./manifests/vault-cluster-0.yml
kubectl --context kind-vault-lab --namespace vault delete secret vault-vault-0-root-token