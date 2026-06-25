variable "environments" {
  description = "Environments to onboard for the tenant."
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "tenant" {
  description = "Tenant name. Used in project names and the tenant namespace path."
  type        = string
}

variable "tfe_organization" {
  description = "HCP Terraform organization name."
  type        = string
}

variable "vault_address" {
  description = "HCP Vault address, written into each project's variable set."
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
