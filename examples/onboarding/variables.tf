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

variable "tfe_organization" {
  description = "HCP Terraform organization name."
  type        = string
}
