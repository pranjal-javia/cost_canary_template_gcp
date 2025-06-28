# main.tf - Organization-level setup for Cost Canary
# This approach provides comprehensive access across the entire GCP organization

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configure the Google Provider
provider "google" {
  project = var.gcp_project_id
}

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

variable "gcp_project_id" {
  type        = string
  description = "The GCP Project ID where the Cost Canary service account will be created."
}

variable "organization_id" {
  type        = string
  description = "The GCP Organization ID (format: organizations/123456789)"
}

variable "billing_account_id" {
  type        = string
  description = "The Billing Account ID for cost data access"
}

variable "cost_canary_service_account" {
  type        = string
  description = "Cost Canary's service account email for impersonation"
  default     = "cost-canary-primary-service-ac@cost-canary.iam.gserviceaccount.com"
}

# -----------------------------------------------------------------------------
# DATA SOURCES
# -----------------------------------------------------------------------------

# Get organization details
data "google_organization" "org" {
  organization = var.organization_id
}

# Get current project details
data "google_project" "current" {
  project_id = var.gcp_project_id
}

# -----------------------------------------------------------------------------
# RESOURCES
# -----------------------------------------------------------------------------

# 1. Create the Cost Canary service account in the customer's project
resource "google_service_account" "cost_canary_sa" {
  account_id   = "cost-canary-role"
  display_name = "Cost Canary Service Account"
  description  = "Service Account that Cost Canary will impersonate for cost data access across the organization"
  project      = var.gcp_project_id
}

# 2. Grant organization-level permissions for resource visibility
resource "google_organization_iam_member" "org_viewer" {
  org_id = data.google_organization.org.org_id
  role   = "roles/resourcemanager.organizationViewer"
  member = google_service_account.cost_canary_sa.member
}

resource "google_organization_iam_member" "folder_viewer" {
  org_id = data.google_organization.org.org_id
  role   = "roles/resourcemanager.folderViewer"
  member = google_service_account.cost_canary_sa.member
}

# 3. Grant billing account permissions for cost data access
resource "google_billing_account_iam_member" "billing_viewer" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.viewer"
  member             = google_service_account.cost_canary_sa.member
}

resource "google_billing_account_iam_member" "billing_costs_manager" {
  billing_account_id = var.billing_account_id
  role               = "roles/billing.costsManager"
  member             = google_service_account.cost_canary_sa.member
}

# 4. Grant BigQuery permissions for detailed cost analysis
# This is applied at the project level where billing export is configured
resource "google_project_iam_member" "bigquery_user" {
  project = var.gcp_project_id
  role    = "roles/bigquery.user"
  member  = google_service_account.cost_canary_sa.member
}

resource "google_project_iam_member" "bigquery_data_viewer" {
  project = var.gcp_project_id
  role    = "roles/bigquery.dataViewer"
  member  = google_service_account.cost_canary_sa.member
}

# 5. Allow Cost Canary's service account to impersonate this service account
resource "google_service_account_iam_member" "allow_impersonation" {
  service_account_id = google_service_account.cost_canary_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.cost_canary_service_account}"
}

# 6. Additional permissions for comprehensive cost monitoring
resource "google_organization_iam_member" "monitoring_viewer" {
  org_id = data.google_organization.org.org_id
  role   = "roles/monitoring.viewer"
  member = google_service_account.cost_canary_sa.member
}

# -----------------------------------------------------------------------------
# OUTPUTS
# -----------------------------------------------------------------------------

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

output "setup_summary" {
  value = <<-EOT
    ✅ Cost Canary Setup Complete!
    
    📧 Service Account: ${google_service_account.cost_canary_sa.email}
    🏢 Organization: ${data.google_organization.org.display_name} (${data.google_organization.org.org_id})
    💳 Billing Account: ${var.billing_account_id}
    📊 Project: ${data.google_project.current.name} (${var.gcp_project_id})
    
    🔐 Permissions Granted:
    ▪️ Organization Viewer (across entire org)
    ▪️ Folder Viewer (for folder structure)
    ▪️ Billing Viewer (for cost data)
    ▪️ Billing Costs Manager (for detailed cost analysis)
    ▪️ BigQuery User & Data Viewer (for billing export queries)
    ▪️ Monitoring Viewer (for usage metrics)
    ▪️ Service Account Token Creator (for Cost Canary impersonation)
    
    🎯 Cost Canary can now securely access cost data across your entire organization!
  EOT
  description = "Summary of the setup and permissions granted"
}

output "next_steps" {
  value = <<-EOT
    🚀 Next Steps:
    
    1. Return to the Cost Canary onboarding page
    2. Click "VERIFY" to test the connection
    3. Configure your cost monitoring preferences
    
    ⚠️  Important Notes:
    - Ensure your billing export to BigQuery is configured for detailed cost analysis
    - The service account has organization-wide read access for comprehensive monitoring
    - All permissions follow the principle of least privilege for security
  EOT
  description = "Instructions for completing the setup"
}