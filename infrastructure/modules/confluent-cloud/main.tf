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
# SERVICE ACCOUNT
# ------------------------------------------------------

resource "confluent_service_account" "app-manager" {
  display_name = "cflt-health-app-manager"
  description  = "Service Account for Kafka Cluster"
}


# ------------------------------------------------------
# ROLE BINDINGS
# ------------------------------------------------------

resource "confluent_role_binding" "cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.standard.rbac_crn
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

//topic that captures and stores audio
resource "confluent_kafka_topic" "chat_input_audio_request" {
  topic_name         = "chat_input_audio_request"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

//topic that stores generated sql to be executed
resource "confluent_kafka_topic" "generated_sql_query" {
  topic_name         = "generated_sql_query"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

//topic that stores sql executed by flink
resource "confluent_kafka_topic" "flink_executed_sql" {
  topic_name         = "flink_executed_sql"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

//topic that stores the returned records from sql query
resource "confluent_kafka_topic" "generated_query_results" {
  topic_name         = "generated_query_results"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

//topic that stores the summary of the response returned
resource "confluent_kafka_topic" "summary_response" {
  topic_name         = "summary_response"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

//topic that stores the audio response as text
resource "confluent_kafka_topic" "chat_output_audio_response" {
  topic_name         = "chat_output_audio_response"
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  rest_endpoint      = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}


# ------------------------------------------------------
# ACLs
# ------------------------------------------------------


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
