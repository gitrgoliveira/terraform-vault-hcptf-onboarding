variable "environments" {
  description = "Environments to onboard for the tenant."
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "tenant" {
  description = "Tenant name to onboard."
  type        = string
}
# Injected automatically by HCP Terraform (see https://developer.hashicorp.com/terraform/cloud-docs/workspaces/run/run-environment).
variable "TFC_WORKSPACE_SLUG" {
  description = "Workspace slug injected by HCP Terraform. Used to derive the organization name."
  type        = string
  default     = ""
}

# Supplied via the TF_VAR_vault_address environment variable from the admin
# project variable set; passed through to the module.
variable "vault_address" {
  description = "HCP Vault address, supplied via the TF_VAR_vault_address environment variable from the project variable set."
  type        = string
  default     = ""
}
