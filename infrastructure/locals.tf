resource "random_id" "env_display_id" {
  byte_length = 4
}

locals {
  create_table_sql_files = var.path_to_flink_sql_create_table_statements == null ? [] : fileset("", "${var.path_to_flink_sql_create_table_statements}/*.sql")
  create_model_sql_files = var.path_to_flink_sql_create_model_statements == null ? [] : fileset("", "${var.path_to_flink_sql_create_model_statements}/*.sql")
  insert_data_sql_files  = var.path_to_flink_sql_insert_statements == null ? [] : fileset("", "${var.path_to_flink_sql_insert_statements}/*.sql")

  # If the suffix is not provided, generate a random one
  env_display_id_postfix = coalesce(var.env_display_id_postfix, random_id.env_display_id.hex)
}