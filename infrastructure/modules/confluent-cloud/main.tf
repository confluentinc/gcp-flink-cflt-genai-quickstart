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
# FLINK
# ------------------------------------------------------

resource "confluent_flink_compute_pool" "main" {
  display_name = "genai-quickstart-flink-compute-pool-${var.env_display_id_postfix}"
  cloud        = var.confluent_cloud_service_provider
  region       = var.confluent_cloud_region
  max_cfu      = 30
  environment {
    id = confluent_environment.staging.id
  }
  depends_on = [
    confluent_role_binding.statements-runner-environment-admin,
    confluent_role_binding.app-manager-assigner,
    confluent_role_binding.app-manager-flink-developer,
    confluent_api_key.app-manager-flink-api-key,
  ]
}

data "confluent_flink_region" "main" {
  cloud  = var.confluent_cloud_service_provider
  region = var.confluent_cloud_region
}

resource "confluent_flink_statement" "create-tables" {
  for_each = var.create_table_sql_files
  organization {
    id = data.confluent_organization.main.id
  }
  environment {
    id = confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  principal {
    id = confluent_service_account.statements-runner.id
  }

  properties = {
    "sql.current-catalog"  = confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.standard.display_name
  }
  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-flink-api-key.id
    secret = confluent_api_key.app-manager-flink-api-key.secret
  }
  statement = file(abspath(each.value))
  lifecycle {
    ignore_changes = [rest_endpoint, organization[0].id]
  }
}

# registers flink sql connections with bedrock. should be replaced when
# terraform provider supports managing flink sql connections
resource "null_resource" "create-flink-connection" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/flink-connection-create.sh"
    environment = {
      FLINK_API_KEY       = confluent_api_key.app-manager-flink-api-key.id
      FLINK_API_SECRET    = confluent_api_key.app-manager-flink-api-key.secret
      FLINK_ENV_ID        = confluent_flink_compute_pool.main.environment[0].id
      FLINK_ORG_ID        = data.confluent_organization.main.id
      FLINK_REST_ENDPOINT = data.confluent_flink_region.main.rest_endpoint
      # the rest should be set by deploy.sh
    }
  }

  triggers = {
    # changes to the flink sql cluster will trigger the bedrock connections to be created
    flink_sql_cluster_id = confluent_flink_compute_pool.main.id
    # change if the script changes
    script = filesha256("${path.module}/scripts/flink-connection-create.sh")
  }
}

resource "confluent_flink_statement" "create-models" {
  for_each = var.create_model_sql_files

  organization {
    id = data.confluent_organization.main.id
  }
  environment {
    id = confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  principal {
    id = confluent_service_account.statements-runner.id
  }

  properties = {
    "sql.current-catalog"  = confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.standard.display_name
  }
  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-flink-api-key.id
    secret = confluent_api_key.app-manager-flink-api-key.secret
  }

  statement = templatefile(each.value, {
    gcloud-project = var.gcloud_project
    bigquery-db = var.bigquery_db
  })

  # statement = file(abspath(each.value))

  depends_on = [
    null_resource.create-flink-connection
  ]
  lifecycle {
    ignore_changes = [rest_endpoint, organization[0].id]
  }
}

resource "confluent_flink_statement" "insert-data" {
  for_each = var.insert_data_sql_files
  organization {
    id = data.confluent_organization.main.id
  }
  environment {
    id = confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  principal {
    id = confluent_service_account.statements-runner.id
  }

  properties = {
    "sql.current-catalog"  = confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.standard.display_name
  }
  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-flink-api-key.id
    secret = confluent_api_key.app-manager-flink-api-key.secret
  }

  stopped   = false
  statement = file(abspath(each.value))

  depends_on = [
    confluent_flink_statement.create-tables,
    confluent_flink_statement.create-models
  ]
  lifecycle {
    ignore_changes = [rest_endpoint, organization[0].id]
  }
}

# ------------------------------------------------------
# TOPICS
# ------------------------------------------------------


//topic that captures and stores audio request
resource "confluent_kafka_topic" "audio_request" {
  topic_name         = "audio_request"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
  depends_on = [
    confluent_kafka_acl.app-manager-delete-on-target-topic
  ]
}

//topic that stores input request as text
resource "confluent_kafka_topic" "input_request" {
  topic_name         = "input_request"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
  depends_on = [
    confluent_api_key.app-manager-kafka-api-key
  ]
}

//topic that stores generated sql wrt the input
resource "confluent_kafka_topic" "generated_sql" {
  topic_name         = "generated_sql"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
  depends_on = [
    confluent_api_key.app-manager-kafka-api-key
  ]
}

//topic that stores sql results executed by KStreams app
resource "confluent_kafka_topic" "sql_results" {
  topic_name         = "sql_results"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
  depends_on = [
    confluent_api_key.app-manager-kafka-api-key
  ]
}

//topic that stores the summary of the response returned
resource "confluent_kafka_topic" "summarised_results" {
  topic_name         = "summarised_results"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
  depends_on = [
    confluent_api_key.app-manager-kafka-api-key
  ]
}

//topic that stores the audio response as text
resource "confluent_kafka_topic" "audio_response" {
  topic_name         = "audio_response"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
  depends_on = [
    confluent_api_key.app-manager-kafka-api-key
  ]
}

# ------------------------------------------------------
# API KEYs
# ------------------------------------------------------

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.standard.id
    api_version = confluent_kafka_cluster.standard.api_version
    kind        = confluent_kafka_cluster.standard.kind

    environment {
      id = confluent_environment.staging.id
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_api_key" "clients-schema-registry-api-key" {
  display_name = "clients-sr-api-key-${var.env_display_id_postfix}"
  description  = "Schema Registry API Key"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }
  managed_resource {
    id          = data.confluent_schema_registry_cluster.essentials.id
    api_version = data.confluent_schema_registry_cluster.essentials.api_version
    kind        = data.confluent_schema_registry_cluster.essentials.kind
    environment {
      id = confluent_environment.staging.id
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_api_key" "app-manager-flink-api-key" {
  display_name = "app-manager-flink-api-key"
  description  = "Flink API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }
  managed_resource {
    id          = data.confluent_flink_region.main.id
    api_version = data.confluent_flink_region.main.api_version
    kind        = data.confluent_flink_region.main.kind
    environment {
      id = confluent_environment.staging.id
    }
  }
}

# ------------------------------------------------------
# ACLs
# ------------------------------------------------------
resource "confluent_kafka_acl" "app-client-describe-on-cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-manager.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-manager-read-on-target-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-manager.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
  depends_on = [
    confluent_role_binding.cluster-admin
  ]
}

resource "confluent_kafka_acl" "app-client-write-to-data-topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-manager.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}
resource "confluent_kafka_acl" "app-manager-delete-on-target-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-manager.id}"
  host          = "*"
  operation     = "DELETE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
  depends_on = [
    confluent_role_binding.cluster-admin
  ]
}

# ------------------------------------------------------
# SERVICE ACCOUNT
# ------------------------------------------------------

resource "confluent_service_account" "app-manager" {
  display_name = "cflt-health-app-manager-${var.env_display_id_postfix}"
  description  = "Service Account for Kafka Cluster"
}

# ------------------------------------------------------
# ROLE BINDINGS
# ------------------------------------------------------

resource "confluent_role_binding" "cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.standard.rbac_crn

  depends_on = [
    confluent_kafka_cluster.standard
  ]
}

resource "confluent_role_binding" "client-schema-registry-developer-write" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  crn_pattern = "${data.confluent_schema_registry_cluster.essentials.resource_name}/subject=*"
  role_name   = "DeveloperWrite"
}

resource "confluent_role_binding" "statements-runner-environment-admin" {
  principal   = "User:${confluent_service_account.statements-runner.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = confluent_environment.staging.resource_name
}

resource "confluent_role_binding" "app-manager-flink-developer" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "FlinkDeveloper"
  crn_pattern = confluent_environment.staging.resource_name
}

resource "confluent_role_binding" "app-manager-flink-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "FlinkAdmin"
  crn_pattern = confluent_environment.staging.resource_name
}


# ------------------------------------------------------
# SCHEMA REGISTRY
# ------------------------------------------------------
data "confluent_schema_registry_cluster" "essentials" {
  environment {
    id = confluent_environment.staging.id
  }
  depends_on = [
    confluent_kafka_cluster.standard
  ]
}
