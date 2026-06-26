module "tenant" {
  source = "../../"

  tenant        = var.tenant
  environments  = var.environments
  vault_address = var.vault_address
}
