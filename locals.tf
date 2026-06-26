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

  # Placeholder tenant policy. Review and tighten before production use.
  tenant_policy = <<-EOT
    # self management
    path "auth/token/lookup-self" { capabilities = ["read"] }
    path "auth/token/renew-self"  { capabilities = ["update"] }
    path "auth/token/revoke-self" { capabilities = ["update"] }

    # full management within this tenant namespace (placeholder).
    path "sys/mounts"         { capabilities = ["read"] }
    path "sys/mounts/*"       { capabilities = ["create", "read", "update", "delete", "list"] }
    path "sys/auth"           { capabilities = ["read"] }
    path "sys/auth/*"         { capabilities = ["create", "read", "update", "delete", "sudo"] }
    path "sys/policies/acl/*" { capabilities = ["create", "read", "update", "delete", "list"] }
    path "*"                  { capabilities = ["create", "read", "update", "delete", "list"] }
  EOT
}
