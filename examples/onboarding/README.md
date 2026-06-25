# Onboarding example

The root configuration the **onboarding workspace** runs. It defines the Vault
dynamic provider credentials `vault` provider and calls `terraform-vault-hcptf-onboarding`.

## Use

Point the onboarding workspace (created by the admin bootstrap configuration) at
this directory, then set its Terraform variables:

| Variable | Example |
|---|---|
| `tenant` | `acme` |
| `environments` | `["dev", "test", "prod"]` |
| `tfe_organization` | `my-org` |
| `vault_address` | `https://<id>.hashicorp.cloud:8200` |

The workspace also needs, as **env** variables:

* `TFC_VAULT_*` — set by the `admin/` bootstrap (Vault dynamic credentials).
* `TFE_TOKEN` — a sensitive team token so the `tfe` provider can manage projects
  and variable sets.

`tfc_vault_dynamic_credentials` is populated automatically by HCP Terraform; do
not set it manually.
