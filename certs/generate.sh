#!/bin/bash

set -x

CA_KEY=ca-key.pem
CA_CERT=ca-cert.pem
VAULT_SERVERS=( vault-kms )

cd ./certs
for server in "${VAULT_SERVERS[@]}"
do
    rm ${server}.key ${server}.csr ${server}.crt
    openssl genrsa -out ${server}.key
    openssl req -new -key ${server}.key -out ${server}.csr -config ${server}.conf
    openssl x509 -req -days 365 -in ${server}.csr -signkey ${CA_KEY} -out ${server}.crt -extensions req_ext -extfile ${server}.conf
done
