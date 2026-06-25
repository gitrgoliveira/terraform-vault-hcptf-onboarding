# ── Providers ─────────────────────────────────────────────────────────────────
# No-code ready module: it configures its own providers because HCP Terraform
# generates no caller. Credentials come from a project-scoped variable set in the
# target project: the TFC_VAULT_* dynamic-credentials variables for the vault
# provider, and a TFE_TOKEN team token for the tfe provider.

provider "tfe" {
  organization = var.tfe_organization
}

provider "vault" {
  # skip_child_token must be true; HCP Terraform manages the token lifecycle.
  skip_child_token = true
  address          = var.tfc_vault_dynamic_credentials.default.address
  namespace        = var.tfc_vault_dynamic_credentials.default.namespace

  auth_login_token_file {
    filename = var.tfc_vault_dynamic_credentials.default.token_filename
  }
}
