# Onboarding example

A minimal caller that runs the no-code module from written configuration. The
module `terraform-vault-hcptf-onboarding` configures its own providers, so this
example only passes inputs and the HCP Terraform dynamic-credentials variable.

## Use

Point the onboarding workspace (created by the admin bootstrap configuration) at
this directory, then set its Terraform variables:

| Variable | Example |
|---|---|
| `tenant` | `acme` |
| `environments` | `["dev", "test", "prod"]` |
| `tfe_organization` | `my-org` |

The workspace also needs, as **env** variables:

* `TFC_VAULT_*` — set by the `admin/` bootstrap (Vault dynamic credentials).
* `TFE_TOKEN` — a sensitive team token so the `tfe` provider can manage projects
  and variable sets.

`tfc_vault_dynamic_credentials` is populated automatically by HCP Terraform; do
not set it manually.
