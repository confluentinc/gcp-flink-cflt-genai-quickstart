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

variable "env_display_id_postfix" {
  description = "A random string we will be appending to resources like environment, api keys, etc. to make them unique"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "bigquery_db" {
  description = "BigQuery DB Name"
  type        = string
}

variable "create_table_sql_files" {
  description = "The set of SQL files that contain the create table statements"
  type        = set(string)
  default     = []
}

variable "create_model_sql_files" {
  description = "The set of SQL files that contain the create model statements"
  type        = set(string)
  default     = []
}

variable "insert_data_sql_files" {
  description = "The set of SQL files that contain the insert data statements"
  type        = set(string)
  default     = []
}

variable "gcp_gemini_api_key" {
  description = "GCP Gemini API Key"
  type        = string
}

variable "gcp_service_account_key" {
  description = "The GCP service account key JSON for GCS access"
  type        = string
}

variable "gcs_bucket_name" {
  description = "The name of the GCS bucket containing the JSON files"
  type        = string
}
