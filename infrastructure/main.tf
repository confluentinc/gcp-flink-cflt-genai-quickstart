module "confluent_cloud" {
  source                           = "./modules/confluent-cloud"
  env_display_id_postfix           = local.env_display_id_postfix
  confluent_cloud_region           = var.confluent_cloud_region
  confluent_cloud_service_provider = var.confluent_cloud_service_provider
  confluent_cloud_environment = {
    name = var.confluent_cloud_environment_name
  }
}

