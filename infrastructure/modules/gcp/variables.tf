variable "gcp_region" {
  description = "The GCP region to deploy the infrastructure"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "unique_id" {
  description = "Unique ID for the deployment"
  type        = string
}

variable "dataset_id" {
  description = "The BigQuery dataset ID"
  type        = string
}
