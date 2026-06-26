# ── Providers ─────────────────────────────────────────────────────────────────
# No-code ready module: it configures its own providers because HCP Terraform
# generates no caller. Credentials come from a project-scoped variable set in the
# target project: the TFC_VAULT_* dynamic-credentials variables for the vault
# provider, and a TFE_TOKEN team token for the tfe provider.

provider "tfe" {
  organization = local.tfe_organization
}

provider "vault" {
  # HCP Terraform injects VAULT_ADDR, VAULT_NAMESPACE, and a short-lived Vault
  # token into the run environment from the workspace's TFC_VAULT_* dynamic
  # provider credentials, so the provider authenticates with no explicit
  # arguments. skip_child_token is required because HCP Terraform owns the
  # token lifecycle.
  skip_child_token = true
}
