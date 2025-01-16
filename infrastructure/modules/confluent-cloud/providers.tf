terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 2.11.0"
    }
  }
}
provider "confluent" {
  cloud_api_key    = "$CONFLUENT_CLOUD_API_KEY"
  cloud_api_secret = "$CONFLUENT_CLOUD_API_SECRET"
}