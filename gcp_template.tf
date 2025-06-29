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