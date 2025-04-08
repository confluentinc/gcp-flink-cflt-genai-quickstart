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
  confluent_cloud_environment = {
    name = var.confluent_cloud_environment_name
  }
  gcp_project_id = var.gcp_project_id
  bigquery_db = module.gcp.dataset_id

  create_model_sql_files = local.create_model_sql_files
  insert_data_sql_files  = local.insert_data_sql_files
  create_table_sql_files = local.create_table_sql_files

  gcp_gemini_api_key = var.gcp_gemini_api_key
  
  # GCS Source connector configuration
  gcs_bucket_name = module.gcp.bucket_name
  gcp_service_account_key = base64decode(module.gcp.service_account_key)

  depends_on = [
     module.gcp
  ]
}


