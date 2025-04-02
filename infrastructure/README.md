<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | ~> 2.11.0 |
| <a name="requirement_gcp"></a> [gcp](#requirement\_gcp) | ~> 6.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_confluent_cloud"></a> [confluent\_cloud](#module\_confluent\_cloud) | ./modules/confluent-cloud | n/a |
| <a name="module_gcp"></a> [gcp](#module\_gcp) | ./modules/gcp | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.run_python_script](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.env_display_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_string.unique_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_confluent_cloud_api_key"></a> [confluent\_cloud\_api\_key](#input\_confluent\_cloud\_api\_key) | Confluent Cloud API Key (also referred as Cloud API ID) with EnvironmentAdmin and AccountAdmin roles provided by Kafka Ops team | `string` | n/a | yes |
| <a name="input_confluent_cloud_api_secret"></a> [confluent\_cloud\_api\_secret](#input\_confluent\_cloud\_api\_secret) | Confluent Cloud API Secret | `string` | n/a | yes |
| <a name="input_confluent_cloud_environment_name"></a> [confluent\_cloud\_environment\_name](#input\_confluent\_cloud\_environment\_name) | The prefix of the Confluent Cloud environment to create | `string` | `"CFLT-Health-Quickstart"` | no |
| <a name="input_confluent_cloud_region"></a> [confluent\_cloud\_region](#input\_confluent\_cloud\_region) | The region of Confluent Cloud Network | `string` | `"us-east1"` | no |
| <a name="input_confluent_cloud_service_provider"></a> [confluent\_cloud\_service\_provider](#input\_confluent\_cloud\_service\_provider) | The cloud provider of Confluent Cloud Network | `string` | `"GCP"` | no |
| <a name="input_env_display_id_postfix"></a> [env\_display\_id\_postfix](#input\_env\_display\_id\_postfix) | A string that will be appended to different resources to make them unique. If not provided, a random string will be generated. | `string` | `null` | no |
| <a name="input_gcp_account"></a> [gcp\_account](#input\_gcp\_account) | The GCP account used to deploy the infrastructure | `string` | n/a | yes |
| <a name="input_gcp_gemini_api_key"></a> [gcp\_gemini\_api\_key](#input\_gcp\_gemini\_api\_key) | GCP Gemini API Key | `string` | n/a | yes |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | GCP project ID | `string` | n/a | yes |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | The GCP region to deploy the infrastructure | `string` | n/a | yes |
| <a name="input_path_to_flink_sql_create_model_statements"></a> [path\_to\_flink\_sql\_create\_model\_statements](#input\_path\_to\_flink\_sql\_create\_model\_statements) | The path to the SQL statements that will be used to create model in Flink | `string` | `null` | no |
| <a name="input_path_to_flink_sql_create_table_statements"></a> [path\_to\_flink\_sql\_create\_table\_statements](#input\_path\_to\_flink\_sql\_create\_table\_statements) | The path to the SQL statements that will be used to create tables in Flink | `string` | `null` | no |
| <a name="input_path_to_flink_sql_insert_statements"></a> [path\_to\_flink\_sql\_insert\_statements](#input\_path\_to\_flink\_sql\_insert\_statements) | The path to the SQL statements that will be used to insert data in Flink | `string` | `null` | no |
| <a name="input_unique_id"></a> [unique\_id](#input\_unique\_id) | A unique identifier for the deployment | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_audio_request_topic"></a> [audio\_request\_topic](#output\_audio\_request\_topic) | audio request topic |
| <a name="output_audio_response_topic"></a> [audio\_response\_topic](#output\_audio\_response\_topic) | audio response topic |
| <a name="output_bootstrap_servers"></a> [bootstrap\_servers](#output\_bootstrap\_servers) | Bootstrap servers for Kafka clients to connect to the kafka cluster. Removes the SASL\_SSL:// prefix for ease of use. |
| <a name="output_clients_kafka_api_key"></a> [clients\_kafka\_api\_key](#output\_clients\_kafka\_api\_key) | API Key for Kafka client |
| <a name="output_clients_kafka_api_secret"></a> [clients\_kafka\_api\_secret](#output\_clients\_kafka\_api\_secret) | API Key Secret for Kafka client |
| <a name="output_clients_schema_registry_api_key"></a> [clients\_schema\_registry\_api\_key](#output\_clients\_schema\_registry\_api\_key) | API Key for Schema Registry client |
| <a name="output_clients_schema_registry_api_secret"></a> [clients\_schema\_registry\_api\_secret](#output\_clients\_schema\_registry\_api\_secret) | API Secret for Schema Registry client |
| <a name="output_dataset_id"></a> [dataset\_id](#output\_dataset\_id) | n/a |
| <a name="output_generated_sql_topic"></a> [generated\_sql\_topic](#output\_generated\_sql\_topic) | generated sql topic |
| <a name="output_input_request_topic"></a> [input\_request\_topic](#output\_input\_request\_topic) | input request topic |
| <a name="output_schema_registry_url"></a> [schema\_registry\_url](#output\_schema\_registry\_url) | URL for the Schema Registry |
| <a name="output_sql_results_topic"></a> [sql\_results\_topic](#output\_sql\_results\_topic) | sql results topic |
| <a name="output_summarised_results_topic"></a> [summarised\_results\_topic](#output\_summarised\_results\_topic) | summarised results topic |
<!-- END_TF_DOCS -->