module "tenant" {
  source = "../../"

  tenant           = var.tenant
  environments     = var.environments
  tfe_organization = var.tfe_organization
  vault_address    = var.vault_address
}
