# Display the token service URL
output "service_url" {
  value = google_cloud_run_service.looker_gcp_auth_service.status[0].url
}

output "looker_gcp_auth_service_account_email" {
  value = google_service_account.looker_gcp_auth_service_account.email
}