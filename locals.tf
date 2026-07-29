locals {
  # Organization name derived from the HCP Terraform workspace slug ("<org>/<workspace>").
  # This is injected automatically by HCP Terraform so no explicit input variable is needed.
  tfe_organization = split("/", var.TFC_WORKSPACE_SLUG)[0]

  # Flattened "<env>/<key>" -> definition map for the per-project Vault dynamic
  # provider credentials environment variables. Map keys are static (derived from
  # var.environments), so this is valid as a for_each source.
  env_var_definitions = {
    for item in flatten([
      for env in var.environments : [
        for kv in [
          { key = "TFC_VAULT_PROVIDER_AUTH", value = "true" },
          { key = "TFC_VAULT_ADDR", value = var.vault_address },
          { key = "TFC_VAULT_NAMESPACE", value = trimsuffix(vault_namespace.tenant[env].id, "/") },
          { key = "TFC_VAULT_RUN_ROLE", value = var.vault_role_name },
          { key = "TFC_VAULT_AUTH_PATH", value = var.vault_auth_path },
          { key = "TF_VAR_vault_address", value = var.vault_address },
          { key = "TF_VAR_vault_namespace", value = trimsuffix(vault_namespace.tenant[env].id, "/") },
          ] : {
          env   = env
          key   = kv.key
          value = kv.value
        }
      ]
    ]) : "${item.env}/${item.key}" => item
  }

  # Least-privilege tenant policy, scoped to the paths the L1-L3 onboarding
  # modules manage: JWT trust mounts, kv/db secret-mount lifecycle, ACL
  # policies, and identity objects. Onboarding workspaces get the auth/jwt*
  # and db/* data planes (backend config, roles, connections) but can NOT
  # read workload kv data — no module needs it, and the workspace token
  # should not be able to exfiltrate tenant secrets.
  tenant_policy = <<-EOT
    # self management
    path "auth/token/lookup-self" { capabilities = ["read"] }
    path "auth/token/renew-self"  { capabilities = ["update"] }
    path "auth/token/revoke-self" { capabilities = ["update"] }

    # secret-mount lifecycle (kv/ and db/ mounts created by L3 modules)
    path "sys/mounts"         { capabilities = ["read"] }
    path "sys/mounts/*"       { capabilities = ["create", "read", "update", "delete", "list"] }

    # JWT trust mounts (L1). Enabling an auth method requires sudo on sys/auth.
    path "sys/auth"           { capabilities = ["read"] }
    path "sys/auth/*"         { capabilities = ["create", "read", "update", "delete", "sudo"] }

    # ACL policies written by workload/use-case modules
    path "sys/policies/acl/*" { capabilities = ["create", "read", "update", "delete", "list"] }

    # identity management (entities, aliases, groups)
    path "identity/entity"          { capabilities = ["create", "update"] }
    path "identity/entity/*"        { capabilities = ["create", "read", "update", "delete", "list"] }
    path "identity/entity-alias"    { capabilities = ["create", "update"] }
    path "identity/entity-alias/*"  { capabilities = ["create", "read", "update", "delete", "list"] }
    path "identity/group"           { capabilities = ["create", "update"] }
    path "identity/group/*"         { capabilities = ["create", "read", "update", "delete", "list"] }
    path "identity/lookup/entity"   { capabilities = ["update"] }

    # module data planes, scoped to the platform's mount conventions:
    # JWT backend config + roles, and database-engine connections/roles.
    path "auth/jwt/*"        { capabilities = ["create", "read", "update", "delete", "list"] }
    path "auth/jwt-gitlab/*" { capabilities = ["create", "read", "update", "delete", "list"] }
    path "db/*"              { capabilities = ["create", "read", "update", "delete", "list"] }
  EOT
}
