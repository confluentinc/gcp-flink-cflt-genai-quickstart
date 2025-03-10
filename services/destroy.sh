#!/usr/bin/env bash

set -eo pipefail  # Exit on error and propagate failures

echo "[+] Destroying services"

# Get the full path of a given directory
get_full_path() {
    local path=$1
    realpath "$path"
}

# Convert a string to lowercase
to_lowercase() {
    local input_string=$1
    echo "$input_string" | tr '[:upper:]' '[:lower:]'
}

# Check if an environment variable is set
check_env_var() {
    local var_name=$1
    if [ -z "${!var_name}" ]; then
        echo "[-] Environment variable $var_name is not set."
        exit 1
    fi
}

# Ensure required environment variables are set
mandatory_vars=("GCP_REGION" "GCP_PROJECT_ID" "DATASET_ID")
for var in "${mandatory_vars[@]}"; do
    check_env_var "$var"
done

IMAGE_ARCH=$(uname -m | grep -qE 'arm64|aarch64' && echo 'arm64' || echo 'x86_64')
CURRENT_DIR=$(dirname "$0")
SCRIPT_FOLDER=$(get_full_path "$CURRENT_DIR")
CONFIG_FOLDER="$SCRIPT_FOLDER/.config"

echo "[+] SCRIPT_FOLDER: $SCRIPT_FOLDER"

# Authenticate gcloud if required
if [ ! -d "$CONFIG_FOLDER" ]; then
    echo "[+] Authenticating gcloud CLI"
    IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -ti --rm gcr.io/google.com/cloudsdktool/google-cloud-cli:stable gcloud auth login
    if [ $? -ne 0 ]; then
        echo "[-] Failed to authenticate gcloud"
        exit 1
    fi
    echo "[+] gcloud authentication complete"
fi

# Delete GCP Cloud Run Service
LOWER_UNIQUE_ID=$(to_lowercase "$UNIQUE_ID")
SVC_NAME="quickstart-healthcare-ai-websocket-$LOWER_UNIQUE_ID"

check_service_exists() {
    local service_name=$1
    local region=$2
    local project_id=$3
    IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -ti --rm gcr.io/google.com/cloudsdktool/google-cloud-cli:stable gcloud run services describe "$service_name" --region "$region" --project "$project_id" > /dev/null 2>&1
}

if check_service_exists "$SVC_NAME" "$GCP_REGION" "$GCP_PROJECT_ID"; then
    echo "[+] Destroying WebSocket service"
    IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -ti --rm gcr.io/google.com/cloudsdktool/google-cloud-cli:stable gcloud run services delete "$SVC_NAME" --region "$GCP_REGION" --project "$GCP_PROJECT_ID" --quiet
    if [ $? -ne 0 ]; then
        echo "[-] Failed to destroy backend"
        exit 1
    fi
    echo "[+] WebSocket service destroyed successfully"
fi

# Delete BigQuery Dataset
if [ -n "$DATASET_ID" ]; then
    echo "[+] Attempting to delete BigQuery dataset: csid-281116:doctors_practice_teardown"
    IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -ti --rm gcr.io/google.com/cloudsdktool/google-cloud-cli:stable bq rm -r -f -d csid-281116:doctors_practice_teardown

    if [ $? -ne 0 ]; then
        echo "[-] Failed to delete BigQuery dataset csid-281116:doctors_practice_teardown"
        exit 1
    fi
    echo "[+] BigQuery dataset csid-281116:doctors_practice_teardown deleted successfully"
fi

# Cleanup local files
echo "[+] Cleaning up files"
rm -rf "$SCRIPT_FOLDER/websocket/frontend/node_modules"
rm -rf "$SCRIPT_FOLDER/websocket/src/main/resources/static/"
rm -rf "$CONFIG_FOLDER"
echo "[+] Cleanup complete"
