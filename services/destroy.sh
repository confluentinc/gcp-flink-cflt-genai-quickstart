#!/usr/bin/env bash

echo "[+] Destroying services"

get_full_path() {
    local path=$1
    realpath "$path"
}

# Function to check if an environment variable is set
check_env_var() {
    local var_name=$1
    if [ -z "${!var_name}" ]; then
        echo "[-] Environment variable $var_name is not set."
        exit 1
    fi
}

# List of mandatory environment variables
mandatory_vars=("GCP_REGION" "GCP_PROJECT_ID" )

# Check each mandatory environment variable
for var in "${mandatory_vars[@]}"; do
    check_env_var "$var"
done

IMAGE_ARCH=$(uname -m | grep -qE 'arm64|aarch64' && echo 'arm64' || echo 'x86_64')
CURRENT_DIR=$(dirname "$0")
SCRIPT_FOLDER=$(get_full_path "$CURRENT_DIR")
CONFIG_FOLDER="$SCRIPT_FOLDER"/.config

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

SVC_NAME=quickstart-healthcare-ai-"$UNIQUE_ID"

#Cehck is the service exists
if check_service_exists "$SVC_NAME" "$GCP_REGION" "$GCP_PROJECT_ID"; then
  echo "[+] Destroying WebSocket Frontend"
  IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -ti --rm --name quickstart-destroy-frontend gcr.io/google.com/cloudsdktool/google-cloud-cli:stable  gcloud run services delete quickstart-healthcare-ai-"$UNIQUE_ID" --region "$GCP_REGION" --project "$GCP_PROJECT_ID" --quiet
  if [ $? -ne 0 ]; then
      echo "[-] Failed to destroy Frontend"
      exit 1
  fi
  echo "[+] WebSocket Frontend destroyed successfully"
fi

echo "[+] Cleanup files"
rm -rf "$SCRIPT_FOLDER"/websocket/frontend/node_modules
rm -rf "$SCRIPT_FOLDER"/websocket/src/main/resources/static/
rm -rf "$CONFIG_FOLDER"
echo "[+] Done cleaning up"
