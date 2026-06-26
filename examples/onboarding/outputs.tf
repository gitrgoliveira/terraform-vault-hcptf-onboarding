output "project_ids" {
  description = "Map of environment name to project ID."
  value       = module.tenant.project_ids
}

output "project_names" {
  description = "Map of environment name to project name."
  value       = module.tenant.project_names
}

output "tenant_namespace_paths" {
  description = "Map of environment name to tenant namespace path."
  value       = module.tenant.tenant_namespace_paths
}

output "vault_namespaces" {
  description = "Map of environment name to the fully qualified Vault namespace (admin/<env>/<tenant>)."
  value       = module.tenant.vault_namespaces
}
