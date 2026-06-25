variable "environments" {
  description = "Environments to onboard for the tenant."
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "tenant" {
  description = "Tenant name. Used in project names and the tenant namespace path."
  type        = string
}

# Supplied automatically by HCP Terraform when the workspace has Vault dynamic
# provider credentials (the TFC_VAULT_* environment variables) configured.
variable "tfc_vault_dynamic_credentials" {
  description = "Vault dynamic provider credentials, injected by HCP Terraform."
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
