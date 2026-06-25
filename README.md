# `terraform-vault-hcptf-onboarding/` — per-tenant environment onboarding

A reusable module that the onboarding workspace (in the **HCP Vault Admin** project) runs. One invocation onboards one tenant across all of its environments, looping over `var.environments`. For each environment it creates a `<tenant>-Vault-<env>` HCP Terraform project, a `<tenant>` child namespace under the matching environment namespace in HCP Vault, the JWT trust inside that namespace, and a variable set that wires future workspaces in the project to authenticate automatically.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `environments` | `list(string)` | `["dev", "test", "prod"]` | Environments to onboard for the tenant |
| `tenant` | `string` | none | Tenant name; used in project names and the tenant namespace path |
| `tfe_organization` | `string` | none | HCP Terraform organization name |
| `vault_address` | `string` | none | HCP Vault address, written into each variable set |
| `vault_auth_path` | `string` | `"tf_jwt"` | JWT auth mount path inside each tenant namespace |
| `vault_role_name` | `string` | `"hcp-tf"` | JWT role name created in each tenant namespace |

## Outputs

| Name | Description |
|---|---|
| `project_ids` | Map env to `<tenant>-Vault-<env>` project ID |
| `role_names` | Map env to JWT role name |
| `tenant_namespace_paths` | Map env to tenant namespace `path_fq` |
| `variable_set_ids` | Map env to variable set ID |

## Provider expectations

The module does **not** configure providers. The calling configuration must pass a
`vault` provider configured for Vault dynamic provider credentials and a `tfe`
provider with an organization and a token able to manage projects and variable
sets. See [examples/onboarding](examples/onboarding) for a complete caller, and
note the consuming `vault` provider block:

```hcl
provider "vault" {
  skip_child_token = true # HCP Terraform manages the token lifecycle
  address          = var.tfc_vault_dynamic_credentials.default.address
  namespace        = var.tfc_vault_dynamic_credentials.default.namespace

  auth_login_token_file {
    filename = var.tfc_vault_dynamic_credentials.default.token_filename
  }
}
```

## Isolation

Each `vault_jwt_auth_backend_role` pins authentication with `bound_claims` on
`terraform_project_id` and `terraform_organization_name`, so only workspaces in
the matching `<tenant>-Vault-<env>` project can authenticate. Each role also lives
in a distinct `admin/<env>/<tenant>` namespace, a second boundary.
