provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

locals {
  userid = lower(var.unique_id)
}

resource "google_service_account" "service_account" {
  account_id   = "cfltquickstart${local.userid}"
  display_name = "Service Account For Confluent GenAI Health Quickstart"
}

resource "google_project_iam_member" "vertex_ai" {
  project = var.gcp_project_id
  role    = "roles/aiplatform.admin"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "bigquery" {
  project = var.gcp_project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "ml" {
  project = var.gcp_project_id
  role    = "roles/ml.admin"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_service_account_key" "service_account_key" {
  service_account_id = google_service_account.service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
  depends_on = [
    google_service_account.service_account,
    google_project_iam_member.bigquery,
    google_project_iam_member.vertex_ai,
    google_project_iam_member.ml
  ]
}

resource "local_file" "service_account_key_file" {
  content = base64decode(google_service_account_key.service_account_key.private_key)
  filename = "${path.root}/service-account-key.json"
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id  = var.dataset_id
  project     = var.gcp_project_id
  friendly_name = "Doctors Practice"
  description   = "Dataset for storing medical data"
  location      = var.gcp_region
}