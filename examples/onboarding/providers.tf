provider "tfe" {
  organization = var.tfe_organization
}

# Configured for Vault dynamic provider credentials. HCP Terraform manages the
# token lifecycle and injects the values via the tfc_vault_dynamic_credentials
# variable, so no address, token, or namespace are hardcoded here.
provider "vault" {
  skip_child_token = true
  address          = var.tfc_vault_dynamic_credentials.default.address
  namespace        = var.tfc_vault_dynamic_credentials.default.namespace

  auth_login_token_file {
    filename = var.tfc_vault_dynamic_credentials.default.token_filename
  }
}
