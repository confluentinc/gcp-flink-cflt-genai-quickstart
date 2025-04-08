output "gcp_service_account_key" {
  value     = google_service_account_key.service_account_key.private_key
  sensitive = true
}

output "gcp_service_account_key_file" {
  value = "${path.root}/service-account-key.json"
}

output "dataset_id" {
  value = google_bigquery_dataset.dataset.dataset_id
}

output "bucket_name" {
  description = "The name of the GCS bucket"
  value       = google_storage_bucket.data_bucket.name
  depends_on  = [time_sleep.wait_for_iam]
}

output "service_account_key" {
  description = "The private key for the service account"
  value       = google_service_account_key.service_account_key.private_key
  sensitive   = true
  depends_on  = [time_sleep.wait_for_iam]
}
