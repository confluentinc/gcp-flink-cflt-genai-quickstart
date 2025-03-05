output "clients_schema_registry_api_key" {
  value       = module.confluent_cloud.clients_schema_registry_api_key.id
  description = "API Key for Schema Registry client"
  sensitive   = true
}

output "clients_schema_registry_api_secret" {
  value       = module.confluent_cloud.clients_schema_registry_api_key.secret
  description = "API Secret for Schema Registry client"
  sensitive   = true
}

output "clients_kafka_api_key" {
  value       = module.confluent_cloud.clients_kafka_api_key.id
  description = "API Key for Kafka client"
  sensitive   = true
}

output "clients_kafka_api_secret" {
  value       = module.confluent_cloud.clients_kafka_api_key.secret
  description = "API Key Secret for Kafka client"
  sensitive   = true
}

output "schema_registry_url" {
  value       = module.confluent_cloud.schema_registry_url
  description = "URL for the Schema Registry"
}

output "bootstrap_servers" {
  value       = module.confluent_cloud.bootstrap_servers
  description = "Bootstrap servers for Kafka clients to connect to the kafka cluster. Removes the SASL_SSL:// prefix for ease of use."
}
