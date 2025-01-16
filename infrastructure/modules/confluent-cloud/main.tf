data "confluent_organization" "main" {}

# ------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------

resource "confluent_environment" "staging" {
  display_name = "${var.confluent_cloud_environment.name}-${var.env_display_id_postfix}"
  stream_governance {
    package = "ESSENTIALS"
  }

  lifecycle {
    # flip this to true to prevent the environment from being destroyed
    prevent_destroy = false
  }
}

# ------------------------------------------------------
# KAFKA
# ------------------------------------------------------

resource "confluent_kafka_cluster" "standard" {
  display_name = "CFLT-Health-Quickstart-${var.env_display_id_postfix}"
  availability = "SINGLE_ZONE"
  cloud        = var.confluent_cloud_service_provider
  region       = var.confluent_cloud_region
  standard {}
  environment {
    id = confluent_environment.staging.id
  }
}

# ------------------------------------------------------
# Schema Registry
# ------------------------------------------------------
data "confluent_schema_registry_cluster" "essentials" {
  environment {
    id = confluent_environment.staging.id
  }
  depends_on = [
    confluent_kafka_cluster.standard,
  ]
}
