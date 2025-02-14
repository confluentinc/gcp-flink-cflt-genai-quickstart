# resource "null_resource" "install_web" {
#   provisioner "local-exec" {
#     command = "cd ${path.module}/websocket && ./deploy.sh"
#     environment = {
#       BROKER_URL       = var.bootstrap_servers
#       KAFKA_API_KEY    = var.kafka_api_key.id
#       KAFKA_API_SECRET = var.kafka_api_key.secret
#       GCP_REGION       = var.gcp.region
#       GCP_PROJECT      = var.gcp.project_id
#     }
#   }
# }
