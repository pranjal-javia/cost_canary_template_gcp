# main.tf - To be run by your customer in their GCP project.

# Configure the Google Provider
provider "google" {
  project = var.gcp_project_id
}

# -----------------------------------------------------------------------------
# VARIABLES
# These are the inputs your customer will need to provide.
# -----------------------------------------------------------------------------

variable "gcp_project_id" {
  type        = string
  description = "The GCP Project ID where the resources will be created."
}

# -----------------------------------------------------------------------------
# RESOURCE CREATION
# This section is the equivalent of the Resources block in your CloudFormation.
# -----------------------------------------------------------------------------

# 1. Create a dedicated Service Account in the customer's project.
# This is the equivalent of your 'CostCanaryRole'.
resource "google_service_account" "cost_canary_sa" {
  account_id   = "cost-canary-role"
  display_name = "Cost Canary Service Account"
  description  = "Service Account that Cost Canary will impersonate to retrieve cost data."
}

# 2. Create a Custom IAM Role with the necessary permissions.
# This is the equivalent of your 'CostCanaryPolicy'.
resource "google_project_iam_custom_role" "cost_canary_permissions" {
  role_id     = "costCanaryReader"
  title       = "Cost Canary Reader"
  description = "Grants permissions needed for Cost Canary to analyze cost and usage data."
  permissions = [
    # Permissions equivalent to Cost Explorer Read-Only
    "billing.accounts.get",
    "billing.budgets.get",
    "billing.costs.get",

    # Permissions equivalent to Organizations Read-Only
    "resourcemanager.organizations.get",
    "resourcemanager.projects.get",
    "resourcemanager.projects.list"
  ]
}

# 3. Grant the permissions to the Service Account.
# This step attaches the policy to the role, binding the permissions
# from Step 2 to the service account from Step 1.
resource "google_project_iam_member" "grant_cost_permissions" {
  project = var.gcp_project_id
  role    = google_project_iam_custom_role.cost_canary_permissions.id
  member  = google_service_account.cost_canary_sa.member
}

# 4. Allow YOUR service to impersonate the customer's new Service Account.
# This is the most critical step. It's the equivalent of the 'AssumeRolePolicyDocument'
# in your CloudFormation template. It establishes the trust relationship.
resource "google_service_account_iam_member" "allow_impersonation" {
  service_account_id = google_service_account.cost_canary_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:cost-canary-primary-service-ac@cost-canary.iam.gserviceaccount.com"
}

# -----------------------------------------------------------------------------
# OUTPUTS
# Display the email of the created service account for confirmation.
# -----------------------------------------------------------------------------

output "cost_canary_service_account_email" {
  value       = google_service_account.cost_canary_sa.email
  description = "The email of the service account created for Cost Canary."
}
