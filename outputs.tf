output "project_ids" {
  description = "Map of environment name to <tenant>-Vault-<env> HCP Terraform project ID."
  value       = { for k, v in tfe_project.env : k => v.id }
}

output "role_names" {
  description = "Map of environment name to the JWT role name in the tenant namespace."
  value       = { for k, v in vault_jwt_auth_backend_role.env : k => v.role_name }
}

output "tenant_namespace_paths" {
  description = "Map of environment name to the fully qualified tenant namespace path."
  value       = { for k, v in vault_namespace.tenant : k => v.path_fq }
}

output "variable_set_ids" {
  description = "Map of environment name to the per-project variable set ID."
  value       = { for k, v in tfe_variable_set.env : k => v.id }
}
