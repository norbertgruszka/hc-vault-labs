#!/bin/bash

./scripts/kms_delete.sh
./scripts/vault-0_delete.sh
./scripts/vault-1_delete.sh
./scripts/vault-2_delete.sh
kind delete cluster --name vault-lab