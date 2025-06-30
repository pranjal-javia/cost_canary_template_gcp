# variables.tf
variable "gcp_project_id" {
  type        = string
  description = "The GCP Project ID where the Cost Canary service account will be created."
  
  validation {
    condition     = length(var.gcp_project_id) > 0
    error_message = "Project ID cannot be empty."
  }
}

variable "organization_id" {
  type        = string
  description = "The GCP Organization ID (format: organizations/123456789)"
  
#  validation {
#    condition     = can(regex("^organizations/[0-9]+$", var.organization_id))
#    error_message = "Organization ID must be in format: organizations/123456789"
#  }
}

variable "billing_account_id" {
  type        = string
  description = "The Billing Account ID for cost data access"
  
  validation {
    condition     = can(regex("^[A-Z0-9]{6}-[A-Z0-9]{6}-[A-Z0-9]{6}$", var.billing_account_id))
    error_message = "Billing Account ID must be in format: XXXXXX-YYYYYY-ZZZZZZ"
  }
}

variable "cost_canary_service_account" {
  type        = string
  description = "Cost Canary's service account email for impersonation"
  default     = "cost-canary-primary-service-ac@cost-canary.iam.gserviceaccount.com"
}