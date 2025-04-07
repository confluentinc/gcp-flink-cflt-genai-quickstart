variable "unique_id" {
  description = "A unique identifier for the deployment"
  type        = string
}

variable "gcp_gemini_api_key" {
  description = "GCP Gemini API Key"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy the infrastructure"
  type        = string
}

variable "gcp_account" {
  description = "The GCP account used to deploy the infrastructure"
  type        = string
}

variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID) with EnvironmentAdmin and AccountAdmin roles provided by Kafka Ops team"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_region" {
  description = "The region of Confluent Cloud Network"
  type        = string
  default     = "us-east1"
}

variable "confluent_cloud_service_provider" {
  description = "The cloud provider of Confluent Cloud Network"
  type        = string
  default     = "GCP"
}

variable "confluent_cloud_environment_name" {
  description = "The prefix of the Confluent Cloud environment to create"
  type        = string
  default     = "CFLT-Health-Quickstart"
}

variable "env_display_id_postfix" {
  description = "A string that will be appended to different resources to make them unique. If not provided, a random string will be generated."
  type        = string
  default     = null
  nullable    = true
}

variable "gcloud_project" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "bigquery_db" {
  description = "BigQuery DB name"
  type        = string
  default     = "patients"
}

variable "path_to_flink_sql_create_table_statements" {
  description = "The path to the SQL statements that will be used to create tables in Flink"
  type        = string
  default     = null
  nullable    = true
}

variable "path_to_flink_sql_create_model_statements" {
  description = "The path to the SQL statements that will be used to create model in Flink"
  type        = string
  default     = null
  nullable    = true
}

variable "path_to_flink_sql_insert_statements" {
  description = "The path to the SQL statements that will be used to insert data in Flink"
  type        = string
  default     = null
  nullable    = true
}
