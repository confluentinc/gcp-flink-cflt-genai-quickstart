variable "confluent_cloud_environment" {
  description = "The environment configuration for Confluent Cloud"
  type = object({
    name = string
  })
}
variable "confluent_cloud_region" {
  description = "The region of Confluent Cloud Network"
  type        = string
}

variable "confluent_cloud_service_provider" {
  description = "The cloud provider of Confluent Cloud Network"
  type        = string
}

variable "env_display_id_postfix" {
  description = "A random string we will be appending to resources like environment, api keys, etc. to make them unique"
  type        = string
}
/*
variable "confluent_kafka_api_key" {
  description = "Confluent Kafka API Key to access topics"
  type        = string
}

variable "confluent_kafka_api_secret" {
  description = "Confluent Kafka API Secret to access topics"
  type        = string
}*/
