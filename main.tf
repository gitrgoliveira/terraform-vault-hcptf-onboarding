# ── Environment projects ──────────────────────────────────────────────────────

resource "tfe_project" "env" {
  for_each = toset(var.environments)

  name         = "${var.tenant}-Vault-${each.key}"
  organization = local.tfe_organization
  description  = "HCP Vault access for tenant ${var.tenant}, ${each.key} environment."
  tags         = var.project_tags
}

# ── Tenant namespaces (admin/<env>/<tenant>) ──────────────────────────────────
# namespace is relative to the provider's admin namespace, so each.key (the env)
# nests the tenant namespace under the matching environment namespace.

resource "vault_namespace" "tenant" {
  for_each = toset(var.environments)

  namespace = each.key
  path      = var.tenant
}

# ── Tenant namespace JWT trust ────────────────────────────────────────────────
# Isolation is enforced at the role via bound_claims pinned to the matching
# <tenant>-Vault-<env> project. The distinct namespace is a second boundary.

resource "vault_jwt_auth_backend" "env" {
  for_each = toset(var.environments)

  namespace          = vault_namespace.tenant[each.key].path_fq
  path               = var.vault_auth_path
  description        = "JWT auth for HCP Terraform workload identity (${var.tenant}/${each.key})."
  oidc_discovery_url = "https://app.terraform.io"
  bound_issuer       = "https://app.terraform.io"
}

resource "vault_policy" "env" {
  for_each = toset(var.environments)

  namespace = vault_namespace.tenant[each.key].path_fq
  name      = "hcp-terraform-workspace"
  policy    = local.tenant_policy
}

resource "vault_jwt_auth_backend_role" "env" {
  for_each = toset(var.environments)

  namespace  = vault_namespace.tenant[each.key].path_fq
  backend    = vault_jwt_auth_backend.env[each.key].path
  role_name  = var.vault_role_name
  role_type  = "jwt"
  user_claim = "terraform_workspace_id"

  bound_audiences = ["vault.workload.identity"]
  bound_claims = {
    # Only tokens from this organization and this environment's project are accepted.
    terraform_organization_name = local.tfe_organization
    terraform_project_id        = tfe_project.env[each.key].id
  }

  token_policies = [vault_policy.env[each.key].name]
}

# ── Per-project Vault dynamic credentials variable sets ───────────────────────
# Any workspace later created in a <tenant>-Vault-<env> project inherits these
# variables and authenticates to its tenant namespace automatically.

resource "tfe_variable_set" "env" {
  for_each = toset(var.environments)

  name         = "${var.tenant}-Vault-${each.key}"
  description  = "Vault dynamic provider credentials for ${var.tenant} ${each.key} workspaces."
  organization = local.tfe_organization
}

resource "tfe_variable" "env" {
  for_each = local.env_var_definitions

  key             = each.value.key
  value           = each.value.value
  category        = "env"
  variable_set_id = tfe_variable_set.env[each.value.env].id
  description     = "Vault dynamic provider credentials for ${each.value.env}."
}

resource "tfe_project_variable_set" "env" {
  for_each = toset(var.environments)

  project_id      = tfe_project.env[each.key].id
  variable_set_id = tfe_variable_set.env[each.key].id
}
