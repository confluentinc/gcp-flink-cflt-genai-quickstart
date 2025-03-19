#!/usr/bin/env bash
# this script is used to create a connection in the confluent cloud cluster by interacting with the rest api that the confluent cli uses.
# At the time of writing this script, the terraform provider does not support creating/managing flink connections in the confluent cloud cluster.
# It should be replaced or removed once its provided by the terraform provider.

set -oe pipefail

# Required environment variables
REQUIRED_ENV_VARS=(
  "FLINK_API_KEY" "FLINK_API_SECRET" "FLINK_ENV_ID" "FLINK_ORG_ID" "FLINK_REGION" "GOOGLE_API_KEY"
)

# "GOOGLE_REGION"

# Check if required environment variables are set
for env_var in "${REQUIRED_ENV_VARS[@]}"; do
  if [ -z "${!env_var}" ]; then
    echo "Error: $env_var is not set"
    exit 1
  fi
done

# Encode API key and secret for basic authentication
BASIC_AUTH=$(echo -n "$FLINK_API_KEY:$FLINK_API_SECRET" | base64 -w 0)
AUTH_DATA=$(jq -n -r --arg google_api_key "$GOOGLE_API_KEY" '{API_KEY: $google_api_key}' | jq '.|tostring')
FLINK_REST_ENDPOINT="https://flink.$FLINK_REGION.gcp.confluent.cloud"

# Create connection in Confluent Cloud cluster
echo
curl --request POST \
  --url "$FLINK_REST_ENDPOINT/sql/v1/organizations/$FLINK_ORG_ID/environments/$FLINK_ENV_ID/connections" \
  --header "Authorization: Basic $BASIC_AUTH" \
  --header "content-type: application/json" \
  --data '{
    "name": "gemini15pro2",
    "spec": {
      "connection_type": "GOOGLEAI",
      "endpoint": "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-002:generateContent",
      "auth_data": {
        "kind": "PlaintextProvider",
      "data": '"$AUTH_DATA"'
      }
    }
  }' | jq . > gemini-connection-result.json
