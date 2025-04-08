#!/usr/bin/env bash

set -eo pipefail

# Function to generate a random string of a given length
generate_random_string() {
    local length=$1
    LC_CTYPE=C tr -dc A-Za-z0-9 </dev/urandom | head -c "$length"
    echo
}

# Function to get the full path of a file or directory
get_full_path() {
    local path=$1
    realpath "$path"
}

# Function to display help message
show_help() {
    echo "Usage: $0 [options] [env_file]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message and exit"
    echo ""
    echo "Arguments:"
    echo "  env_file      Optional path to an environment file to load"
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

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

prompt_for_input_with_default() {
    local var_name=$1
    local prompt_message=$2
    local default_value=$3

    read -r -p "$prompt_message (default $default_value): " input_value

    if [ -z "$input_value" ]; then
        eval "$var_name='$default_value'"
    else
        eval "$var_name='$input_value'"
    fi
}

# Function to prompt for a yes/no response. returns 1 for yes, 0 for no
prompt_for_yes_no() {
    local prompt_message=$1
    local response

    while true; do
        read -r -p "$prompt_message [y/n]: " response
        case $response in
            [yY][eE][sS]|[yY])
                return 1
            ;;
            [nN][oO]|[nN])
                return 0
            ;;
            *)
            ;;
        esac
    done
}

#Reusing the unique_id if it exists
if [ -f .unique_id ]; then
  unique_id=$(cat .unique_id)
else
  unique_id="qsid$$"
  echo $unique_id > .unique_id
fi

export CLIENT_ID="pie_labs|flink-cflt-gcp-genai-quickstart|$unique_id"
echo "[+] Deploying quickstart with unique ID: $unique_id with CLIENT_ID: $CLIENT_ID"

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

# Prompt for GCP Information
[ -z "$GCP_ACCOUNT" ] && prompt_for_input GCP_ACCOUNT "Enter your GCP Account to use:" false
[ -z "$GCP_GEMINI_API_KEY" ] && prompt_for_input GCP_GEMINI_API_KEY "Enter your GCP_GEMINI_API_KEY:" false
[ -z "$GCP_PROJECT_ID" ] && prompt_for_input GCP_PROJECT_ID "Enter your GCP_PROJECT_ID:" false
[ -z "$GCP_REGION" ] && read -r -p "Enter the GCP region (default: us-east1): " GCP_REGION && GCP_REGION=${GCP_REGION:-us-east1}

# Prompt for Confluent Cloud and MongoDB credentials
[ -z "$CONFLUENT_CLOUD_API_KEY" ] && prompt_for_input CONFLUENT_CLOUD_API_KEY "Enter your Confluent Cloud API Key" false
[ -z "$CONFLUENT_CLOUD_API_SECRET" ] && prompt_for_input CONFLUENT_CLOUD_API_SECRET "Enter your Confluent Cloud API Secret" true
[ -z "$CONFLUENT_CLOUD_REGION" ] && prompt_for_input_with_default CONFLUENT_CLOUD_REGION "Enter Confluent Cloud Region" "us-east1"

# Create .env file from variables set in this file
echo "[+] Setting up .env file for docker-compose"
cat << EOF > .env
export IMAGE_ARCH="$IMAGE_ARCH"
export UNIQUE_ID="$unique_id"
export CLIENT_ID="$CLIENT_ID"

export GCP_REGION="$GCP_REGION"
export GCP_PROJECT_ID="$GCP_PROJECT_ID"
export GCP_GEMINI_API_KEY="$GCP_GEMINI_API_KEY"
export GCP_ACCOUNT="$GCP_ACCOUNT"

export CONFLUENT_CLOUD_API_KEY="$CONFLUENT_CLOUD_API_KEY"
export CONFLUENT_CLOUD_API_SECRET="$CONFLUENT_CLOUD_API_SECRET"
export CONFLUENT_CLOUD_REGION="$CONFLUENT_CLOUD_REGION"

EOF

echo "[+] Setting up infrastructure/variables.tfvars"
# populate tfvars file with GCP credentials
cat << EOF > infrastructure/variables.tfvars
gcp_region = "$GCP_REGION"
gcp_project_id = "$GCP_PROJECT_ID"
gcp_gemini_api_key = "$GCP_GEMINI_API_KEY"
gcp_account = "$GCP_ACCOUNT"
confluent_cloud_region = "$GCP_REGION"
confluent_cloud_api_key = "$CONFLUENT_CLOUD_API_KEY"
confluent_cloud_api_secret = "$CONFLUENT_CLOUD_API_SECRET"
unique_id = "$unique_id"
path_to_flink_sql_create_table_statements = "statements/create-tables"
path_to_flink_sql_create_model_statements = "statements/create-models"
path_to_flink_sql_insert_statements = "statements/insert"
EOF

# Check if .config directory exists or is empty
if [ ! -d ./.config ] || [ -z "$(find ./.config/ -mindepth 1)" ]; then
  if [ ! -d ./.config ]; then
    echo ".config directory does not exist. Authenticating gcloud."
  else
    echo ".config directory is empty. Authenticating gcloud."
  fi
  IMAGE_ARCH=$IMAGE_ARCH docker run -v "$(pwd)/.config:/root/.config/" -ti --rm --name gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli:stable gcloud auth application-default login
  if [ $? -ne 0 ]; then
    echo "[-] Failed to authenticate gcloud"
    exit 1
  fi
  echo "[+] gcloud authentication complete"
else
  echo ".config directory exists and is not empty. Skipping authentication."
fi

echo "[+] Applying terraform"
IMAGE_ARCH=$IMAGE_ARCH docker compose run --remove-orphans --rm terraform apply --auto-approve -var-file=variables.tfvars
if [ $? -ne 0 ]; then
    echo "[-] Failed to apply terraform"
    exit 1
fi
echo "[+] Terraform apply complete"

source .env

echo "[+] Deploying backend"

export BOOTSTRAP_SERVER=$(IMAGE_ARCH=$IMAGE_ARCH docker compose run --remove-orphans --rm terraform output -raw bootstrap_servers)
export KAFKA_API_KEY=$(IMAGE_ARCH=$IMAGE_ARCH docker compose run --remove-orphans --rm terraform output -raw clients_kafka_api_key)
export KAFKA_API_SECRET=$(IMAGE_ARCH=$IMAGE_ARCH docker compose run --remove-orphans --rm terraform output -raw clients_kafka_api_secret)
export SR_API_KEY=$(IMAGE_ARCH=$IMAGE_ARCH docker compose run --remove-orphans --rm terraform output -raw clients_schema_registry_api_key)
export SR_API_SECRET=$(IMAGE_ARCH=$IMAGE_ARCH docker compose run --remove-orphans --rm terraform output -raw clients_schema_registry_api_secret)
export SR_URL=$(IMAGE_ARCH=$IMAGE_ARCH docker compose run --remove-orphans --rm terraform output -raw schema_registry_url)

export AUDIO_REQUEST_TOPIC=$(IMAGE_ARCH=$IMAGE_ARCH docker compose run --remove-orphans --rm terraform output -raw audio_request_topic)
export AUDIO_RESPONSE_TOPIC=$(IMAGE_ARCH=$IMAGE_ARCH docker compose run --remove-orphans --rm terraform output -raw audio_response_topic)
./services/deploy.sh

echo "[+] Done"
