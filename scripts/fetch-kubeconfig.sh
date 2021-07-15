#!/bin/bash

if [[ "$0" = "$BASH_SOURCE" ]]; then
  echo "Please source this script. Do not execute."
  exit 1
fi

DIRECTORY=$(dirname $0)

KV_NAME=${1:-$(terraform output -raw kv_name)}
FILE=$(realpath ${DIRECTORY}/../rke2.kubeconfig)

echo "Fetching kubeconfig from KeyVault $KV_NAME"
az keyvault secret show --name kubeconfig --vault-name $KV_NAME | jq -r '.value' > $FILE

if [ $? -eq 0 ]; then
  echo "Download successful. Setting KUBECONFIG to $FILE"
  export KUBECONFIG=$FILE
fi