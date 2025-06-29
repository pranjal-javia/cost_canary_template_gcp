# outputs.tf
output "cost_canary_service_account_email" {
  value       = google_service_account.cost_canary_sa.email
  description = "The email of the service account created for Cost Canary"
}

output "organization_id" {
  value       = data.google_organization.org.org_id
  description = "The organization ID where permissions were granted"
}

output "billing_account_id" {
  value       = var.billing_account_id
  description = "The billing account ID with granted permissions"
}

output "infrastructure_manager_deployment_url" {
  value = "https://console.cloud.google.com/config/deployments/${google_service_account.cost_canary_sa.project}/locations/us-central1"
  description = "Link to view this deployment in Infrastructure Manager"
}

output "setup_summary" {
  value = {
    service_account = google_service_account.cost_canary_sa.email
    organization = data.google_organization.org.name
    project = data.google_project.current.name
    deployment_method = "Infrastructure Manager"
    status = "✅ Successfully deployed via Infrastructure Manager"
  }
  description = "Deployment summary"
}