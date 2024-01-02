# hc-vault-labs

## Setup Kind cluster

Run `kind` command and create `hcp-vault-lab` cluster.

```bash
kind create cluster --config ./kind.yml
```

Install Cilium CNI.

```bash
helm upgrade --install cilium cilium/cilium --version 1.14.4 --namespace kube-system -f ./cilium.yml --kube-context kind-hcp-vault-lab
```

Wait for Cilium to be fully operational.

```bash
cilium status --wait
```

Create L2 IP pool and policy.

```bash
kubectl --context kind-hcp-vault-lab apply -f ./manifests/cilium-l2.yml
```

Done!
