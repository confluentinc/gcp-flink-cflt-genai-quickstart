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
  dataset_id  = "doctors_practice_quickstart_${var.unique_id}"
  project     = var.gcp_project_id
  friendly_name = "Doctors Practice"
  description   = "Dataset for storing medical data"
  location      = var.gcp_region

  # Forces deletion of all dataset contents before Terraform destroys the dataset
  delete_contents_on_destroy = true

  labels = {
    goog-terraform-provisioned = "true"
  }
}

resource "google_storage_bucket" "data_bucket" {
  name          = "doctors-practice-data-${var.unique_id}"
  location      = var.gcp_region
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    goog-terraform-provisioned = "true"
  }
}

# Grant the service account access to the bucket
resource "google_storage_bucket_iam_member" "bucket_access" {
  bucket = google_storage_bucket.data_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

# Grant additional bucket-level permissions
resource "google_storage_bucket_iam_member" "bucket_metadata_access" {
  bucket = google_storage_bucket.data_bucket.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

# Grant project-level storage permissions
resource "google_project_iam_member" "storage_viewer" {
  project = var.gcp_project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

# Grant project-level storage admin role for full access
resource "google_project_iam_member" "storage_admin" {
  project = var.gcp_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

# Upload all JSON files from the data directory
resource "google_storage_bucket_object" "json_files" {
  for_each = fileset("${path.root}/data", "*.json")
  
  name   = each.value
  bucket = google_storage_bucket.data_bucket.name
  source = "${path.root}/data/${each.value}"

  depends_on = [
    google_storage_bucket.data_bucket,
    google_storage_bucket_iam_member.bucket_access,
    google_storage_bucket_iam_member.bucket_metadata_access,
    google_project_iam_member.storage_viewer,
    google_project_iam_member.storage_admin
  ]
}

# Add a time delay to allow for IAM propagation
resource "time_sleep" "wait_for_iam" {
  depends_on = [
    google_storage_bucket_iam_member.bucket_access,
    google_storage_bucket_iam_member.bucket_metadata_access,
    google_project_iam_member.storage_viewer,
    google_project_iam_member.storage_admin,
    google_storage_bucket_object.json_files
  ]

  create_duration = "30s"
}
