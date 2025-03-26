resource "random_string" "unique_id" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

module "gcp" {
  source         = "./modules/gcp"
  gcp_region     = var.gcp_region
  gcp_project_id = var.gcp_project_id
  unique_id      = var.unique_id
  dataset_id     = var.dataset_id
}

module "confluent_cloud" {
  source                           = "./modules/confluent-cloud"
  env_display_id_postfix           = local.env_display_id_postfix
  confluent_cloud_region           = var.confluent_cloud_region
  confluent_cloud_service_provider = var.confluent_cloud_service_provider
  confluent_cloud_environment = {
    name = var.confluent_cloud_environment_name
  }
  gcloud_project = var.gcloud_project
  bigquery_db = var.bigquery_db

  create_model_sql_files = local.create_model_sql_files
  insert_data_sql_files  = local.insert_data_sql_files
  create_table_sql_files = local.create_table_sql_files

  gcp_gemini_api_key = var.gcp_gemini_api_key

  depends_on = [
     module.gcp
  ]
}

resource "null_resource" "run_python_script" {
  depends_on = [module.gcp]  # Ensure GCP module is created first

  provisioner "local-exec" {
    command = <<EOT
      echo "[+] Running Python script: bq_loader.py with DATASET_ID=${var.dataset_id}" && \
      python3 -m venv venv && \
      source venv/bin/activate && \
      pip install -r requirements.txt && \
      DATASET_ID=${var.dataset_id} python3 ${path.module}/bq_loader.py
    EOT
  }

  triggers = {
    always_run = timestamp()  # Forces execution on each `apply`
  }
}

