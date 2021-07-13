#!/bin/bash

set -e

FILE_NAME="rke2.priv_key"
KV_NAME=$(terraform output -raw kv_name)
SERVER_URL=$(terraform output -json rke2_cluster | jq -r '.server_url')

az keyvault secret show --name node-key --vault-name $KV_NAME | jq -r '.value' > $FILE_NAME
chmod 600 $FILE_NAME

echo "Connect the the server(s) with the following command:"
echo "  ssh rke2@${SERVER_URL} -p 5000 -i $FILE_NAME"
echo "For each server in the cluster increase the port, e.g. 5001, 5002"
