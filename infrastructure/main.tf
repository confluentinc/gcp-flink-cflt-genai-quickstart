resource "random_string" "unique_id" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

module "gcp" {
  source         = "./modules/gcp"
  gcp_region     = var.gcp_region
  gcp_project_id = var.gcp_project_id
  unique_id      = var.unique_id
}

module "confluent_cloud" {
  source                           = "./modules/confluent-cloud"
  env_display_id_postfix           = local.env_display_id_postfix
  confluent_cloud_region           = var.confluent_cloud_region
  confluent_cloud_service_provider = var.confluent_cloud_service_provider

  # needed for Google BigQuery V2 sink connector
  gcp_project_id                   = var.gcp_project_id
  gcp_region                       = var.gcp_region

  confluent_cloud_environment = {
    name = var.confluent_cloud_environment_name
  }

  depends_on = [
     module.gcp
  ]
}
