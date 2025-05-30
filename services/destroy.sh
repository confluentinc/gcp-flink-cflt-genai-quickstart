#!/usr/bin/env bash

echo "[+] Destroying services"

get_full_path() {
    local path=$1
    realpath "$path"
}

# Function to convert a string to lowercase
to_lowercase() {
    local input_string=$1
    echo "$input_string" | tr '[:upper:]' '[:lower:]'
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
mandatory_vars=("GCP_REGION" "GCP_PROJECT_ID")

# Check each mandatory environment variable
for var in "${mandatory_vars[@]}"; do
    check_env_var "$var"
done

IMAGE_ARCH=$(uname -m | grep -qE 'arm64|aarch64' && echo 'arm64' || echo 'x86_64')
CURRENT_DIR=$(dirname "$0")
SCRIPT_FOLDER=$(get_full_path "$CURRENT_DIR")
CONFIG_FOLDER="$SCRIPT_FOLDER"/.config

echo "[+] SCRIPT_FOLDER: $SCRIPT_FOLDER"

# -------------------------------
# AUTHENTICATE GCLOUD
# -------------------------------
if [ ! -d "$CONFIG_FOLDER" ]; then
  echo "[+] Authenticating gcloud for CLI"
  IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -ti --rm --name gcloud-config \
      gcr.io/google.com/cloudsdktool/google-cloud-cli:stable gcloud auth login
  if [ $? -ne 0 ]; then
      echo "[-] Failed to authenticate gcloud"
      exit 1
  fi
  echo "[+] gcloud authentication complete"
fi

LOWER_UNIQUE_ID=$(to_lowercase "$UNIQUE_ID")

# -------------------------------
# DESTROY CLOUD RUN SERVICES
# -------------------------------
SERVICES=(
    "quickstart-healthcare-ai-websocket"
    "quickstart-healthcare-ai-audio-text-converter"
    "quickstart-healthcare-ai-summarise"
    "quickstart-healthcare-ai-build-query"
    "quickstart-healthcare-ai-execute-query"
)

for SVC_NAME_PREFIX in "${SERVICES[@]}"; do
    SVC_NAME="${SVC_NAME_PREFIX}-${LOWER_UNIQUE_ID}"

    if IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -ti --rm \
        gcr.io/google.com/cloudsdktool/google-cloud-cli:stable \
        gcloud run services describe "$SVC_NAME" --region "$GCP_REGION" --project "$GCP_PROJECT_ID" > /dev/null 2>&1; then

        echo "[+] Destroying service: $SVC_NAME"
        IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -ti --rm \
            gcr.io/google.com/cloudsdktool/google-cloud-cli:stable \
            gcloud run services delete "$SVC_NAME" --region "$GCP_REGION" --project "$GCP_PROJECT_ID" --quiet

        if [ $? -ne 0 ]; then
            echo "[-] Failed to destroy $SVC_NAME"
            exit 1
        fi
        echo "[+] $SVC_NAME destroyed successfully"
    else
        echo "[+] Service $SVC_NAME does not exist. Skipping."
    fi
done

# -------------------------------
# CLEANUP FILES
# -------------------------------
echo "[+] Cleanup files"
rm -rf "$SCRIPT_FOLDER"/websocket/frontend/node_modules
rm -rf "$SCRIPT_FOLDER"/websocket/src/main/resources/static/
rm -rf infrastructure/venv
rm -rf "$CONFIG_FOLDER"
echo "[+] Done cleaning up"
