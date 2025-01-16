#!/usr/bin/env bash

set -eo pipefail

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

# Set platform to linux/arm64 if m1 mac is detected. Otherwise set to linux/amd64
IMAGE_ARCH=$(uname -m | grep -qE 'arm64|aarch64' && echo 'arm64' || echo 'x86_64')

# Check if docker is installed
if ! [ -x "$(command -v docker)" ]; then
    echo 'Error: docker is not installed.' >&2
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
  echo 'Error: Docker is not running.' >&2
  exit 1
fi

# Check if terraform is initialized
if [ ! -d "./infrastructure/.terraform" ]; then
    touch .env
    echo "[+] Initializing terraform"
    IMAGE_ARCH=$IMAGE_ARCH docker compose run --rm terraform init || { echo "[-] Failed to initialize terraform"; exit 1; }
fi

# Support for already existing .env file
DEFAULT_ENV_FILE=$1
# Check if an environment file is provided and source it
if [[ -n "$DEFAULT_ENV_FILE" && "$DEFAULT_ENV_FILE" != "-h" && "$DEFAULT_ENV_FILE" != "--help" ]]; then
    if [[ -f "$DEFAULT_ENV_FILE" ]]; then
        echo "[+] Sourcing environment file '$DEFAULT_ENV_FILE'"
        source "$DEFAULT_ENV_FILE"
    else
        echo "Error: Environment file '$DEFAULT_ENV_FILE' not found."
        exit 1
    fi
fi
# Prompt for Confluent Cloud and MongoDB credentials
[ -z "$CONFLUENT_CLOUD_API_KEY" ] && prompt_for_input CONFLUENT_CLOUD_API_KEY "Enter your Confluent Cloud API Key" false
[ -z "$CONFLUENT_CLOUD_API_SECRET" ] && prompt_for_input CONFLUENT_CLOUD_API_SECRET "Enter your Confluent Cloud API Secret" true

# Create .env file from variables set in this file
echo "[+] Setting up .env file for docker-compose"
cat << EOF > .env
IMAGE_ARCH=$IMAGE_ARCH
CONFLUENT_CLOUD_API_KEY=$CONFLUENT_CLOUD_API_KEY
CONFLUENT_CLOUD_API_SECRET=$CONFLUENT_CLOUD_API_SECRET
EOF

echo "[+] Setting up infrastructure/variables.tfvars"
cat << EOF > infrastructure/variables.tfvars
confluent_cloud_api_key = "$CONFLUENT_CLOUD_API_KEY"
confluent_cloud_api_secret = "$CONFLUENT_CLOUD_API_SECRET"
EOF

echo "[+] Applying terraform"
#IMAGE_ARCH=$IMAGE_ARCH docker compose run --rm terraform apply --auto-approve -var-file=variables.tfvars
IMAGE_ARCH=$IMAGE_ARCH docker compose run --rm terraform plan -var-file=variables.tfvars
if [ $? -ne 0 ]; then
    echo "[-] Failed to apply terraform"
    exit 1
fi

echo "[+] Terraform apply complete"
echo "[+] Done"