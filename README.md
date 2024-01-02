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

## Generate TLS Certificates for Vault

Create directory for certificates

```bash
mkdir certs
cd certs
```

### Root certificate

Create Root CA Private Key.

```bash
openssl genrsa -out ca-key.pem 2048
```

Next, generate Root CA certificate.

```bash
openssl req -new -x509 -nodes -days 365 \
   -key ca-key.pem \
   -out ca-cert.pem
```

You can fill out whatever you want, for example:

```text
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:CH
State or Province Name (full name) []:BE
Locality Name (eg, city) []:Bern
Organization Name (eg, company) []:LameCorp
Organizational Unit Name (eg, section) []:Engineering
Common Name (eg, fully qualified host name) []:ca.lamecorp.com
Email Address []:support@vault.lamecorp.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
```

### Vault certificates

Example commands to generate single certificate manually.

```bash
openssl genrsa -out vault-kms.key
openssl req -new -key vault-kms.key -out vault-kms.csr -config vault-kms.conf
openssl x509 -req -days 365 -in vault-kms.csr -signkey vault-kms.key -out vault-kms.crt -CA ca-cert.pem -CAkey ca-key.pem -extensions req_ext -extfile vault-kms.conf
```

To generate certs for all Vault instances, run `certs/generate.sh` script.

Verify certificate with:

```bash
openssl x509 -in vault-kms.crt -noout -text
```

## Deploy Vault Client

TODO

## Deploy Ops Vault

This instance of Vault is responsible for providing KMS keys, which are later used for auto-unsealing main Vault cluster.

Create new namespace

```bash
kubectl create namespace vault-ops
```

Add TLS Certificate

```bash
kubectl create secret tls vault-tls --namespace vault-ops --key ./certs/vault-ops.key --cert ./certs/vault-ops.crt
```

Deploy Vault instance

```bash
kubectl apply -f ./manifests/vault-ops.yml
```

Initi Vault - TODO