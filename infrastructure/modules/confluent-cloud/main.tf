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
      FLINK_REGION        = var.confluent_cloud_region
      GOOGLE_API_KEY      = var.gcp_gemini_api_key
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
    gcp-project-id = var.gcp_project_id
    bigquery-db = var.bigquery_db
  })

  depends_on = [
    null_resource.create-flink-connection
  ]
  lifecycle {
    ignore_changes = [rest_endpoint, organization[0].id]
  }
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
# DATA TOPICS
# ------------------------------------------------------

resource "confluent_kafka_topic" "medical_records" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name         = "medical_records"
  partitions_count   = 6
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  config = {
    "cleanup.policy"      = "delete"
    "retention.ms"        = "604800000"  # 7 days
    "min.insync.replicas" = "2"
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
    create_before_destroy = false
  }
}

resource "confluent_kafka_topic" "medications" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name         = "medications"
  partitions_count   = 6
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  config = {
    "cleanup.policy"      = "delete"
    "retention.ms"        = "604800000"  # 7 days
    "min.insync.replicas" = "2"
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
    create_before_destroy = false
  }
}

resource "confluent_kafka_topic" "patients" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name         = "patients"
  partitions_count   = 6
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  config = {
    "cleanup.policy"      = "delete"
    "retention.ms"        = "604800000"  # 7 days
    "min.insync.replicas" = "2"
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
    create_before_destroy = false
  }
}

resource "confluent_kafka_topic" "summaries" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name         = "summaries"
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "symptoms" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name         = "symptoms"
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "visits" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name         = "visits"
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "appointments" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name         = "appointments"
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "doctors" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name         = "doctors"
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

# Create dead letter queue topics for each data type
resource "confluent_kafka_topic" "dlq" {
  for_each = toset([
    "medical_records",
    "medications",
    "patients"
  ])

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name         = "dlq_${each.key}"
  partitions_count   = 1  # DLQ topics typically need fewer partitions
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  config = {
    "cleanup.policy"      = "compact"  # Keep the latest record for each key
    "retention.ms"        = "1209600000"  # 14 days for DLQ
    "min.insync.replicas" = "2"
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }

  depends_on = [
    confluent_kafka_acl.app-manager-delete-on-target-topic,
    confluent_role_binding.cluster-admin
  ]

  lifecycle {
    prevent_destroy = false
    create_before_destroy = false
  }
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

# Add DELETE permission for the GCS Source connector service account
resource "confluent_kafka_acl" "gcs_source_delete_topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.gcs_source.id}"
  host          = "*"
  operation     = "DELETE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

# Add DESCRIBE permission for the GCS Source connector service account
resource "confluent_kafka_acl" "gcs_source_describe_cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.gcs_source.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.gcs_source_kafka_api_key.id
    secret = confluent_api_key.gcs_source_kafka_api_key.secret
  }
}

# Add READ permission for topics
resource "confluent_kafka_acl" "gcs_source_read_topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "gcs-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.gcs_source.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.gcs_source_kafka_api_key.id
    secret = confluent_api_key.gcs_source_kafka_api_key.secret
  }
}

# Add WRITE permission for topics
resource "confluent_kafka_acl" "gcs_source_write_topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "gcs-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.gcs_source.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.gcs_source_kafka_api_key.id
    secret = confluent_api_key.gcs_source_kafka_api_key.secret
  }
}

# Add CREATE permission for topics
resource "confluent_kafka_acl" "gcs_source_create_topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  resource_type = "TOPIC"
  resource_name = "gcs-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.gcs_source.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.gcs_source_kafka_api_key.id
    secret = confluent_api_key.gcs_source_kafka_api_key.secret
  }
}

# ------------------------------------------------------
# SERVICE ACCOUNT
# ------------------------------------------------------

resource "confluent_service_account" "app-manager" {
  display_name = "cflt-health-app-manager-${var.env_display_id_postfix}"
  description  = "Service Account for Kafka Cluster"
}

// Service account to perform a task within Confluent Cloud, such as executing a Flink statement
resource "confluent_service_account" "statements-runner" {
  display_name = "statements-runner-sa-${var.env_display_id_postfix}"
  description  = "Service account for running Flink Statements in the Kafka cluster"
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

resource "confluent_role_binding" "app-manager-assigner" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "Assigner"
  crn_pattern = "${data.confluent_organization.main.resource_name}/service-account=${confluent_service_account.statements-runner.id}"
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

# ------------------------------------------------------
# GCS SOURCE CONNECTOR
# ------------------------------------------------------

# Service account for GCS Source connector
resource "confluent_service_account" "gcs_source" {
  display_name = "gcs-source-${var.env_display_id_postfix}"
  description  = "Service account for GCS Source connector"
}

# Grant the service account the ConnectorAdmin role
resource "confluent_role_binding" "gcs_source_kafka_cluster_admin" {
  principal   = "User:${confluent_service_account.gcs_source.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.standard.rbac_crn
}

# Create an API key for the service account
resource "confluent_api_key" "gcs_source_kafka_api_key" {
  display_name = "gcs-source-${var.env_display_id_postfix}-key"
  description  = "Kafka API Key that is owned by 'gcs-source' service account"
  owner {
    id          = confluent_service_account.gcs_source.id
    api_version = confluent_service_account.gcs_source.api_version
    kind        = confluent_service_account.gcs_source.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.standard.id
    api_version = confluent_kafka_cluster.standard.api_version
    kind        = confluent_kafka_cluster.standard.kind
    environment {
      id = confluent_environment.staging.id
    }
  }

  depends_on = [
    confluent_role_binding.gcs_source_kafka_cluster_admin
  ]
}

# Upload data files to GCS
locals {
  data_files = fileset("${path.module}/data", "**/*")
  avro_files = [for f in local.data_files : f if endswith(f, ".avro")]
  avro_topics = [for f in local.avro_files : "gcs_${replace(basename(f), ".avro", "")}"]
}

# Create topics for each AVRO file
resource "confluent_kafka_topic" "gcs_topics" {
  for_each = toset(local.avro_topics)

  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name         = each.value
  partitions_count   = 6
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  config = {
    "cleanup.policy"      = "delete"
    "retention.ms"        = "604800000"  # 7 days
    "min.insync.replicas" = "2"
  }
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
    create_before_destroy = false
  }
}

resource "google_storage_bucket_object" "data" {
  for_each = local.data_files

  name         = "data/${each.value}"
  source       = "${path.module}/data/${each.value}"
  content_type = "application/octet-stream"
  bucket       = var.gcs_bucket_name
}

# Create GCS Source connector
resource "confluent_connector" "gcs_source" {
  environment {
    id = confluent_environment.staging.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  config_sensitive = {
    "gcs.credentials.json" = var.gcp_service_account_key
  }

  config_nonsensitive = {
    "connector.class"          = "GcsSource"
    "name"                     = "confluent-gcs-source"
    "topic.regex.list"         = join(",", [for topic in local.avro_topics : "${topic}:.*\\.avro"])
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.gcs_source.id
    "input.data.format"        = "AVRO"
    "output.data.format"       = "JSON_SR"
    "tasks.max"                = "1"
    "gcs.bucket.name"          = var.gcs_bucket_name
    "topics.dir"               = "data"
    "behavior.on.error"        = "IGNORE"
    "schema.registry.url"      = data.confluent_schema_registry_cluster.essentials.rest_endpoint
    "schema.registry.basic.auth.credentials.source" = "USER_INFO"
    "schema.registry.basic.auth.user.info"          = "${confluent_api_key.clients-schema-registry-api-key.id}:${confluent_api_key.clients-schema-registry-api-key.secret}"
  }

  depends_on = [
    confluent_kafka_acl.gcs_source_read_topics,
    confluent_kafka_acl.gcs_source_write_topics,
    confluent_kafka_acl.gcs_source_create_topics,
    confluent_kafka_acl.gcs_source_describe_cluster,
    google_storage_bucket_object.data,
    confluent_kafka_topic.gcs_topics
  ]
}
