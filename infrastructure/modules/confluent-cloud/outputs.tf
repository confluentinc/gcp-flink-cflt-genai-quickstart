output "clients_schema_registry_api_key" {
  value       = confluent_api_key.clients-schema-registry-api-key
  description = "API Key for Schema Registry client"
  sensitive   = true
}

output "clients_kafka_api_key" {
  value       = confluent_api_key.app-manager-kafka-api-key
  description = "API Key for Kafka client"
  sensitive   = true
}

output "schema_registry_url" {
  value       = data.confluent_schema_registry_cluster.essentials.rest_endpoint
  description = "URL for the Schema Registry"
}

output "bootstrap_servers" {
  value       = replace(confluent_kafka_cluster.standard.bootstrap_endpoint, "SASL_SSL://", "")
  description = "Bootstrap servers for Kafka clients to connect to the kafka cluster. Removes the SASL_SSL:// prefix for ease of use."
}

output "audio_request_topic" {
  value = confluent_kafka_topic.audio_request.id
  description = "audio request topic"
}

output "audio_response_topic" {
  value = confluent_kafka_topic.audio_response.id
  description = "audio response topic"
}

output "input_request_topic" {
  value = confluent_kafka_topic.input_request.id
  description = "input request topic"
}

output "generated_sql_topic" {
  value = confluent_kafka_topic.generated_sql.id
  description = "generated sql topic"
}

output "sql_results_topic" {
  value = confluent_kafka_topic.sql_results.id
  description = "sql results topic"
}

output "summarised_results_topic" {
  value = confluent_kafka_topic.summarised_results.id
  description = "summarised topic"
}

output "organization_id" {
  value       = data.confluent_organization.main.id
  description = "Confluent Cloud Organization ID"
}
