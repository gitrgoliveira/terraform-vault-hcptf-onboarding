# ── Unit tests (plan mode, mocked providers) ─────────────────────────────────
# The tfe and vault providers are mocked so this suite runs with `terraform test`
# without HCP Terraform or HCP Vault credentials. These tests validate module
# logic only: project naming, namespace expansion, JWT bound_claims isolation,
# variable-set wiring, and outputs. They never reach a real API.

mock_provider "tfe" {}

mock_provider "vault" {}

variables {
  tenant             = "acme"
  TFC_WORKSPACE_SLUG = "example-org/onboarding"

  tfc_vault_dynamic_credentials = {
    default = {
      token_filename = "/tmp/vault-token"
      address        = "https://vault.example.com:8200"
      namespace      = "admin"
      ca_cert_file   = ""
    }
    aliases = {}
  }
}

run "default_environments_create_three_projects" {
  command = plan

  assert {
    condition     = length(tfe_project.env) == 3
    error_message = "Default environments should create three projects."
  }

  assert {
    condition     = tfe_project.env["dev"].name == "acme-Vault-dev"
    error_message = "Project name should follow the <tenant>-Vault-<env> convention."
  }

  assert {
    condition     = tfe_project.env["prod"].organization == "example-org"
    error_message = "Projects should belong to the configured organization."
  }
}

run "namespaces_nest_tenant_under_env" {
  command = plan

  assert {
    condition     = vault_namespace.tenant["dev"].path == "acme"
    error_message = "Tenant namespace path should be the tenant name."
  }

  assert {
    condition     = vault_namespace.tenant["dev"].namespace == "dev"
    error_message = "Tenant namespace should nest under the matching environment namespace."
  }
}

run "jwt_role_pins_bound_claims" {
  command = plan

  assert {
    condition     = vault_jwt_auth_backend_role.env["dev"].bound_claims["terraform_organization_name"] == "example-org"
    error_message = "JWT role must bind the organization claim for isolation."
  }

  assert {
    condition     = vault_jwt_auth_backend_role.env["dev"].role_name == "hcp-tf"
    error_message = "JWT role name should default to hcp-tf."
  }

  assert {
    condition     = contains(vault_jwt_auth_backend_role.env["dev"].bound_audiences, "vault.workload.identity")
    error_message = "JWT role must bind the vault.workload.identity audience."
  }
}

run "jwt_backend_uses_auth_path" {
  command = plan

  assert {
    condition     = vault_jwt_auth_backend.env["dev"].path == "tf_jwt"
    error_message = "JWT auth backend should mount at the default tf_jwt path."
  }
}

run "outputs_expose_every_environment" {
  command = plan

  assert {
    condition     = length(output.project_ids) == 3
    error_message = "project_ids output should contain one entry per environment."
  }

  assert {
    condition     = length(output.variable_set_ids) == 3
    error_message = "variable_set_ids output should contain one entry per environment."
  }

  assert {
    condition     = length(output.role_names) == 3
    error_message = "role_names output should contain one entry per environment."
  }
}

run "custom_environments_override" {
  command = plan

  variables {
    environments = ["staging"]
  }

  assert {
    condition     = length(tfe_project.env) == 1
    error_message = "Overriding environments should change the project count."
  }

  assert {
    condition     = tfe_project.env["staging"].name == "acme-Vault-staging"
    error_message = "Project name should reflect the overridden environment."
  }
}
