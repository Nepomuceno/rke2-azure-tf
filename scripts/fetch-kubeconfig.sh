#!/bin/bash

[[ $_ != $0 ]] && { echo "You must source this script not execute directly"; exit 1; } 

DIRECTORY=$(dirname $0)
KV_NAME=$(terraform output -raw kv_name)
FILE=$(realpath ${DIRECTORY}/../rke2.kubeconfig)

echo "Fetching kubeconfig from KeyVault $KV_NAME"
az keyvault secret show --name kubeconfig --vault-name $KV_NAME | jq -r '.value' > $FILE

if [[ $# == 0 ]]; then
  echo "Setting KUBECONFIG to $FILE"
  export KUBECONFIG=$FILE
fi