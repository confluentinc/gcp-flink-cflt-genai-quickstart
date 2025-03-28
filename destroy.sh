#!/usr/bin/env bash

set -eo pipefail

# Set platform to linux/arm64 if m1 mac is detected. Otherwise set to linux/amd64
IMAGE_ARCH=$(uname -m | grep -qE 'arm64|aarch64' && echo 'arm64' || echo 'x86_64')

get_full_path() {
    local path=$1
    realpath "$path"
}

# Check if docker is installed
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  exit 1
fi

if ! docker info > /dev/null 2>&1; then
  echo 'Error: Docker is not running.' >&2
  exit 1
fi

# Load .env exit if it does not exist
if [ ! -f .env ]; then
  echo "[-] .env file does not exist"
  exit 1
fi
source .env

# Check if .config folder exists
if [ ! -d ./.config ]; then
  echo "[+] Authenticating gcloud"
  IMAGE_ARCH=$IMAGE_ARCH docker run -v ./.config:/root/.config/ -ti --rm --name gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli:stable gcloud auth application-default login
  if [ $? -ne 0 ]; then
      echo "[-] Failed to authenticate gcloud"
      exit 1
  fi
  echo "[+] gcloud authentication complete"
fi

# destroy backend
./services/destroy.sh

# destroy infrastructure
# Check if terraform is initialized
if [ ! -d "./infrastructure/.terraform" ]; then
  echo "[+] Terraform is not initialized"
  IMAGE_ARCH=$IMAGE_ARCH docker compose run --rm terraform init || { echo "[-] Failed to initialize terraform"; exit 1; }
fi

echo "[+] Destroying infrastructure"
IMAGE_ARCH=$IMAGE_ARCH docker compose run --rm terraform destroy -auto-approve -var-file=variables.tfvars || { echo "[-] Failed to destroy infrastructure"; exit 1; }

echo "[+] Infrastructure destroyed successfully"

# delete .env and infrastructure/variables.tf
echo "[+] Cleaning up .env, infrastructure/variables.tf and other files"
rm -f .env
rm -f infrastructure/variables.tfvars
rm -rf .config
rm -f infrastructure/gcp-embed-connection-result.json
rm -f infrastructure/gcp-gemini-connection-result.json
rm -f .unique_id
echo "[+] Clean up completed"
