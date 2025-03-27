#!/usr/bin/env bash

echo "[+] Deploying services"

get_full_path() {
    local path=$1
    realpath "$path"
}

# Function to check if an environment variable is set
check_env_var() {
    local var_name=$1
    if [ -z "${!var_name}" ]; then
        echo "[-] Error: Environment variable $var_name is not set."
        exit 1
    fi
}

# Function to convert a string to lowercase
to_lowercase() {
    local input_string=$1
    echo "$input_string" | tr '[:upper:]' '[:lower:]'
}

#List of mandatory environment variables
mandatory_vars=("GCP_REGION" "GCP_PROJECT_ID" "BOOTSTRAP_SERVER" "KAFKA_API_KEY" "KAFKA_API_SECRET" "SR_API_KEY" "SR_API_SECRET" "SR_URL" "UNIQUE_ID" "CLIENT_ID")

# Check each mandatory environment variable
for var in "${mandatory_vars[@]}"; do
    check_env_var "$var"
done

IMAGE_ARCH=$(uname -m | grep -qE 'arm64|aarch64' && echo 'arm64' || echo 'x86_64')
CURRENT_DIR=$(dirname "$0")
SCRIPT_FOLDER=$(get_full_path "$CURRENT_DIR")
CONFIG_FOLDER="$SCRIPT_FOLDER"/.config

echo "[+] SCRIPT_FOLDER: $SCRIPT_FOLDER"

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

# Lower case the UNIQUE_ID and set service names
LOWER_UNIQUE_ID=$(echo "$UNIQUE_ID" | tr '[:upper:]' '[:lower:]')
AUDIO_TEXT_CONVERTER_SVC_NAME="quickstart-healthcare-ai-audio-text-converter-$LOWER_UNIQUE_ID"
BUILD_QUERY_SVC_NAME="quickstart-healthcare-ai-build-query-$LOWER_UNIQUE_ID"
EXECUTE_QUERY_SVC_NAME="quickstart-healthcare-ai-execute-query-$LOWER_UNIQUE_ID"
SUMMARISE_SVC_NAME="quickstart-healthcare-ai-summarise-$LOWER_UNIQUE_ID"
WEBSOCKET_SVC_NAME="quickstart-healthcare-ai-websocket-$LOWER_UNIQUE_ID"

# Function to build Maven projects
build_maven_project() {
    local service_path=$1
    echo "[+] Starting build for $service_path"
    IMAGE_ARCH=$IMAGE_ARCH docker run -v "$service_path":/root/source/ --rm --name build-$(basename "$service_path") maven:3.8.7-openjdk-18-slim sh -c "cd /root/source/ && mvn -T 1C clean install -Dmaven.test.skip -DskipTests -Dmaven.javadoc.skip=true"
    if [ $? -ne 0 ]; then
        echo "[-] Failed to build $service_path"
        exit 1
    fi
    echo "[+] $service_path built successfully"
}

# Function to build Node.js projects without requiring a TTY
build_node_project() {
    local service_path=$1
    echo "[+] Starting build for $service_path/frontend"
    IMAGE_ARCH=$IMAGE_ARCH docker run -v "$service_path":/root/source/ --rm --name build-frontend node:current-alpine3.20 sh -c "cd /root/source/frontend && npm i && npm run build"
    if [ $? -ne 0 ]; then
        echo "[-] Failed to build $service_path/frontend"
        exit 1
    fi
    echo "[+] $service_path/frontend built successfully"
}

# Function to deploy with gcloud without requiring a TTY
deploy_gcloud() {
    local svc_name=$1
    local service_path=$2
    local extra_vars=$3
    echo "[+] Deploying $svc_name"
    IMAGE_ARCH=$IMAGE_ARCH docker run -v "$CONFIG_FOLDER":/root/.config/ -v "$service_path":/root/source/ --rm --name quickstart-deploy-$svc_name gcr.io/google.com/cloudsdktool/google-cloud-cli:stable gcloud run deploy "$svc_name" --no-cpu-throttling --source "/root/source/" --region "$GCP_REGION" --allow-unauthenticated --cpu 2 --memory 1Gi --project "$GCP_PROJECT_ID" --min-instances 1 --set-env-vars "$extra_vars"
    if [ $? -ne 0 ]; then
        echo "[-] Failed to deploy $svc_name"
        exit 1
    fi
    echo "[+] $svc_name deployed successfully"
}

# Parallel build process for Maven and Node projects
build_maven_project "$SCRIPT_FOLDER/audio-text-converter" &
build_maven_project "$SCRIPT_FOLDER/build-query" &
build_maven_project "$SCRIPT_FOLDER/execute_query" &
build_maven_project "$SCRIPT_FOLDER/summarize" &
build_node_project "$SCRIPT_FOLDER/websocket" &
wait

# Set environment variable string for gcloud deployments
common_env_vars="BOOTSTRAP_SERVER=$BOOTSTRAP_SERVER,KAFKA_API_KEY=$KAFKA_API_KEY,KAFKA_API_SECRET=$KAFKA_API_SECRET,SR_API_KEY=$SR_API_KEY,SR_API_SECRET=$SR_API_SECRET,SR_URL=$SR_URL,CLIENT_ID=$CLIENT_ID,GCP_PROJECT_ID=$GCP_PROJECT_ID"
audio_text_converter_env_vars="$common_env_vars,TOPIC_IN=audio_request,TOPIC_OUT=input_request"
build_query_env_vars="$common_env_vars,TOPIC_IN=input_request,TOPIC_OUT=generated_sql"
execute_query_env_vars="$common_env_vars,TOPIC_IN=generated_sql,TOPIC_OUT=sql_results"
summarise_env_vars="$common_env_vars,TOPIC_IN=sql_results,TOPIC_OUT=summarised_results"

# Parallel deployment process
deploy_gcloud "$AUDIO_TEXT_CONVERTER_SVC_NAME" "$SCRIPT_FOLDER/audio-text-converter" "$audio_text_converter_env_vars" &
deploy_gcloud "$BUILD_QUERY_SVC_NAME" "$SCRIPT_FOLDER/build-query" "$build_query_env_vars" &
deploy_gcloud "$EXECUTE_QUERY_SVC_NAME" "$SCRIPT_FOLDER/execute_query" "$execute_query_env_vars" &
deploy_gcloud "$SUMMARISE_SVC_NAME" "$SCRIPT_FOLDER/summarize" "$summarise_env_vars" &
deploy_gcloud "$WEBSOCKET_SVC_NAME" "$SCRIPT_FOLDER/websocket" "$common_env_vars" &
wait
