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
}

module "confluent_cloud" {
  source                           = "./modules/confluent-cloud"
  env_display_id_postfix           = local.env_display_id_postfix
  confluent_cloud_region           = var.confluent_cloud_region
  confluent_cloud_service_provider = var.confluent_cloud_service_provider
  confluent_cloud_environment = {
    name = var.confluent_cloud_environment_name
  }

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
