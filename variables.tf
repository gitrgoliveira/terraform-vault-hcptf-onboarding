variable "environments" {
  description = "Environments to onboard for the tenant."
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "tenant" {
  description = "Tenant name. Used in project names and the tenant namespace path."
  type        = string
}

# Injected automatically by HCP Terraform (see https://developer.hashicorp.com/terraform/cloud-docs/workspaces/run/run-environment).
# The slug has the form "<organization>/<workspace>".
variable "TFC_WORKSPACE_SLUG" {
  description = "Workspace slug injected by HCP Terraform. Used to derive the organization name."
  type        = string
  default     = ""
}

# Populated by the TF_VAR_vault_address environment variable that the admin
# project variable set supplies. Terraform cannot read plain env vars (only
# TF_VAR_-prefixed ones), so the admin module exposes the Vault address this way.
# Written into the per-tenant variable sets the module creates. Not entered by hand.
variable "vault_address" {
  description = "HCP Vault address, supplied via the TF_VAR_vault_address environment variable from the project variable set. Written into the downstream tenant variable sets."
  type        = string
  default     = ""
}

variable "vault_auth_path" {
  description = "JWT auth mount path inside each tenant namespace."
  type        = string
  default     = "tf_jwt"
}

variable "vault_role_name" {
  description = "JWT role name created in each tenant namespace."
  type        = string
  default     = "hcp-tf"
}
