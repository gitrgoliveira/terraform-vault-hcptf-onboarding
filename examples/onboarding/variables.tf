variable "environments" {
  description = "Environments to onboard for the tenant."
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "tenant" {
  description = "Tenant name to onboard."
  type        = string
}

# Supplied automatically by HCP Terraform when Vault dynamic provider credentials
# are configured on the workspace (the TFC_VAULT_* environment variables).
variable "tfc_vault_dynamic_credentials" {
  description = "Vault dynamic credentials configuration injected by HCP Terraform."
  type = object({
    default = object({
      token_filename = string
      address        = string
      namespace      = string
      ca_cert_file   = string
    })
    aliases = map(object({
      token_filename = string
      address        = string
      namespace      = string
      ca_cert_file   = string
    }))
  })
}

# Injected automatically by HCP Terraform (see https://developer.hashicorp.com/terraform/cloud-docs/workspaces/run/run-environment).
variable "TFC_WORKSPACE_SLUG" {
  description = "Workspace slug injected by HCP Terraform. Used to derive the organization name."
  type        = string
  default     = ""
}
