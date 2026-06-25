module "tenant" {
  source = "../../"

  tenant                        = var.tenant
  environments                  = var.environments
  tfe_organization              = var.tfe_organization
  tfc_vault_dynamic_credentials = var.tfc_vault_dynamic_credentials
}
