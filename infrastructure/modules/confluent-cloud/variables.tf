variable "confluent_cloud_environment" {
  description = "The environment configuration for Confluent Cloud"
  type = object({
    name = string
  })
}
variable "confluent_cloud_region" {
  description = "The region of Confluent Cloud Network"
  type        = string
}

variable "confluent_cloud_service_provider" {
  description = "The cloud provider of Confluent Cloud Network"
  type        = string
}

# Required for Google BigQuery V2 Connector
variable "gcp_region" {
  description = "The GCP region to deploy the infrastructure"
  type        = string
}

# Required for Google BigQuery V2 Connector
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "env_display_id_postfix" {
  description = "A random string we will be appending to resources like environment, api keys, etc. to make them unique"
  type        = string
}
