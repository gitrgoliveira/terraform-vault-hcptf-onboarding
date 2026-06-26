# `terraform-vault-hcptf-onboarding/` — per-tenant environment onboarding

A no-code ready module that onboards one tenant onto HCP Vault from HCP Terraform. One invocation onboards one tenant across all of its environments, looping over `var.environments`. For each environment it creates a `<tenant>-Vault-<env>` HCP Terraform project, a `<tenant>` child namespace under the matching environment namespace in HCP Vault, the JWT trust inside that namespace, and a variable set that wires future workspaces in the project to authenticate automatically.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `environments` | `list(string)` | `["dev", "test", "prod"]` | Environments to onboard for the tenant |
| `tenant` | `string` | none | Tenant name; used in project names and the tenant namespace path |
| `vault_auth_path` | `string` | `"tf_jwt"` | JWT auth mount path inside each tenant namespace |
| `vault_role_name` | `string` | `"hcp-tf"` | JWT role name created in each tenant namespace |

The HCP Terraform organization is derived from `TFC_WORKSPACE_SLUG`, and `tfc_vault_dynamic_credentials` carries the Vault address used for the downstream tenant variable sets. Both are supplied automatically by HCP Terraform; do not set them manually.

## Outputs

| Name | Description |
|---|---|
| `project_ids` | Map env to `<tenant>-Vault-<env>` project ID |
| `role_names` | Map env to JWT role name |
| `tenant_namespace_paths` | Map env to tenant namespace `path_fq` |
| `variable_set_ids` | Map env to variable set ID |

## No-code provisioning

This is a [no-code ready module](https://developer.hashicorp.com/terraform/cloud-docs/no-code-provisioning/module-design): it configures its own `vault` and `tfe` providers, so HCP Terraform can provision it without a hand-written caller.

Grant the no-code workspaces their credentials with a **project-scoped variable set** applied to the project where the module lands. The module's `vault` provider authenticates to the `admin` namespace via Vault dynamic provider credentials, and its `tfe` provider manages org-level projects and variable sets:

| Variable | Category | Value |
|---|---|---|
| `TFC_VAULT_PROVIDER_AUTH` | env | `true` |
| `TFC_VAULT_ADDR` | env | HCP Vault address |
| `TFC_VAULT_NAMESPACE` | env | `admin` (the namespace the module manages) |
| `TFC_VAULT_RUN_ROLE` | env | the admin JWT role |
| `TFC_VAULT_AUTH_PATH` | env | JWT auth mount path (for example `tf_jwt`) |
| `TFE_TOKEN` | env (sensitive) | team token able to manage projects and variable sets |

HCP Terraform reads the `TFC_VAULT_*` variables, injects `VAULT_ADDR` / `VAULT_NAMESPACE` and a Vault token into the run environment (which the `vault` provider authenticates from directly), and also populates the `tfc_vault_dynamic_credentials` input. The module reads only the Vault address from that input, to wire the downstream tenant variable sets, so the address is not a module input.

## Isolation

Each `vault_jwt_auth_backend_role` pins authentication with `bound_claims` on
`terraform_project_id` and `terraform_organization_name`, so only workspaces in
the matching `<tenant>-Vault-<env>` project can authenticate. Each role also lives
in a distinct `admin/<env>/<tenant>` namespace, a second boundary.
