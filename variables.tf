variable "environments" {
  description = "Environments to onboard for the tenant."
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "tenant" {
  description = "Tenant name. Used in project names and the tenant namespace path."
  type        = string
}

# Auto-populated by HCP Terraform when the workspace has Vault dynamic provider
# credentials configured. The module does NOT use this to authenticate (the
# injected VAULT_ADDR / VAULT_NAMESPACE / VAULT_TOKEN env vars handle that). It
# only reads .default.address, to propagate the Vault URL into the per-tenant
# variable sets it creates.
variable "tfc_vault_dynamic_credentials" {
  description = "Vault dynamic provider credentials injected by HCP Terraform. Only the address is read, to populate the downstream tenant variable sets."
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
# The slug has the form "<organization>/<workspace>".
variable "TFC_WORKSPACE_SLUG" {
  description = "Workspace slug injected by HCP Terraform. Used to derive the organization name."
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
