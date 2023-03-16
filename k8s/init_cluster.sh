#!/bin/bash

# Create a new cluster
kind create cluster --config ./kind-config.yml --name vault-lab

# Install Metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
echo "Waiting for metallb to start..."
kubectl wait --namespace metallb-system \
    --for=condition=ready pod \
    --selector=app=metallb \
    --timeout=90s

# Metallb IPAddressPool IP range should come from the same IP range as docker network 
# You can check it by running 
# >  docker network inspect -f '{{.IPAM.Config}}' kind
kubectl --context kind-vault-lab apply -f ./manifests/metallb.yml

# Install Nginx Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo "Waiting for Nginx Ingress Controller to start..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Create Namespaces
kubectl --context kind-vault-lab apply -f ./manifests/namespace.yml

# Create KMS Vault
kubectl --context kind-vault-lab apply -f ./manifests/vault-kms.yml
echo "Waiting for KMS Vault to start..."
kubectl wait --namespace vault \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=vault-kms \
  --timeout=90s

./scripts/init_kms.sh

# Create vault-cluster-0 Vault
kubectl --context kind-vault-lab apply -f ./manifests/vault-cluster-0.yml
# Create vault-cluster-1 Vault
kubectl --context kind-vault-lab apply -f ./manifests/vault-cluster-1.yml
# Create vault-cluster-2 Vault
kubectl --context kind-vault-lab apply -f ./manifests/vault-cluster-2.yml