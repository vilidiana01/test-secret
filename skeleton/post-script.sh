#!/bin/bash

# Define variables
NAMESPACE=$2 # Change this to the target namespace
SECRET_NAME=$1
KUBE_API_SERVER="https://kubernetes.default.svc"  # In-cluster API server
SERVICE_ACCOUNT_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CA_CERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

# Data for the secret (Base64 encoded)
SECRET_DATA_KEY="username"
DATA_VALUE=$3

# Extract filename
FILENAME=$(echo "$DATA_VALUE" | sed -n 's/.*name=\([^;]*\);.*/\1/p')

# Extract base64 content
BASE64_CONTENT=$(echo "$DATA_VALUE" | sed -n 's/.*base64,\(.*\)/\1/p')

# JSON payload
SECRET_JSON=$(cat <<EOF
{
  "apiVersion": "v1",
  "kind": "Secret",
  "metadata": {
    "name": "${SECRET_NAME}",
    "namespace": "${NAMESPACE}"
  },
  "data": {
    "${FILENAME}": "${BASE64_CONTENT}"
  }
}
EOF
)

# Create the secret using curl
curl -X POST "${KUBE_API_SERVER}/api/v1/namespaces/${NAMESPACE}/secrets" \
    --cacert ${CA_CERT} \
    -H "Authorization: Bearer ${SERVICE_ACCOUNT_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${SECRET_JSON}"