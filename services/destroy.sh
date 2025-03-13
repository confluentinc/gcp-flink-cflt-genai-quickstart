#!/usr/bin/env bash

set -euo pipefail  # Exit on error and propagate failures

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
    if [ -z "${!var_name-}" ]; then  # Use ${!var_name-} to handle unset variables safely
        echo "[-] ERROR: Environment variable $var_name is not set. Please export it before running the script."
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

# Function to prompt for input until a non-empty value is provided
prompt_for_input() {
    local var_name=$1
    local prompt_message=$2
    local is_secret=$3

    while true; do
        if [ "$is_secret" = true ]; then
            read -r -s -p "$prompt_message: " input_value
            echo ""
        else
            read -r -p "$prompt_message: " input_value
        fi

        if [ -z "$input_value" ]; then
            echo "[-] $var_name cannot be empty"
        else
            eval "$var_name='$input_value'"
            break
        fi
    done
}

# Function to check if a GCP Cloud Run service exists
check_service_exists() {
    local service_name=$1
    local region=$2
    local project_id=$3

    if IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -ti --rm --name gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli:stable gcloud run services describe "$service_name" --region "$region" --project "$project_id" > /dev/null 2>&1; then
        echo "Service $service_name exists."
        return 0
    else
        echo "Service $service_name does not exist."
        return 1
    fi
}

# Check if the the .config folder does not exists
if [ ! -d "$CONFIG_FOLDER" ]; then
  echo "[+] Authenticating gcloud for cli"
  IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -ti --rm --name gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli:stable gcloud auth login
  if [ $? -ne 0 ]; then
      echo "[-] Failed to authenticate gcloud"
      exit 1
  fi
  echo "[+] gcloud authentication complete"
fi

# Delete GCP Cloud Run Service
LOWER_UNIQUE_ID=$(to_lowercase "$UNIQUE_ID")
SVC_NAME="quickstart-healthcare-ai-websocket-$LOWER_UNIQUE_ID"


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
    echo "[+] Attempting to delete BigQuery dataset: $GCP_PROJECT_ID6:$DATASET_ID"
    IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -ti --rm gcr.io/google.com/cloudsdktool/google-cloud-cli:stable bq rm -r -f -d $GCP_PROJECT_ID:$DATASET_ID

    if [ $? -ne 0 ]; then
        echo "[-] Failed to delete BigQuery dataset $GCP_PROJECT_ID:$DATASET_ID"
        exit 1
    fi
    echo "[+] BigQuery dataset $GCP_PROJECT_ID:$DATASET_ID deleted successfully"
fi

# Cleanup local files
echo "[+] Cleaning up files"
rm -rf "$SCRIPT_FOLDER/websocket/frontend/node_modules"
rm -rf "$SCRIPT_FOLDER/websocket/src/main/resources/static/"
rm -rf "$CONFIG_FOLDER"
echo "[+] Cleanup complete"
