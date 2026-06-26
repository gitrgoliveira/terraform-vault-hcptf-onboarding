module "tenant" {
  source = "../../"

  tenant                        = var.tenant
  environments                  = var.environments
  tfc_vault_dynamic_credentials = var.tfc_vault_dynamic_credentials
}
