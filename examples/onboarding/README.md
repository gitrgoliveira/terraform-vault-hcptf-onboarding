# Onboarding example

A minimal caller that runs the module from written configuration. The module
`terraform-vault-hcptf-onboarding` configures its own providers, so this example
only passes the tenant inputs and the Vault address.

## Use

Run this directory in an HCP Terraform workspace in a project that carries the
onboarding variable set (the one `admin/` creates), then set its Terraform
variables:

| Variable | Example |
|---|---|
| `tenant` | `acme` |
| `environments` | `["dev", "test", "prod"]` |

The workspace also inherits these **env** variables from the project variable set:

* `TFC_VAULT_*` — Vault dynamic credentials that authenticate the `vault` provider.
* `TF_VAR_vault_address` — the HCP Vault address, read here as `var.vault_address`.
* `TFE_TOKEN` — a sensitive team token so the `tfe` provider can manage projects
  and variable sets.

`TFC_WORKSPACE_SLUG` and `TF_VAR_vault_address` are provided through HCP Terraform;
do not set them manually.
