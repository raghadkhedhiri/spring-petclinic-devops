resource "azurerm_user_assigned_identity" "github_cd" {
  name                = "${var.project_name}-github-cd"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_federated_identity_credential" "github_cd_main" {
  name                      = "github-cd-main"
  user_assigned_identity_id = azurerm_user_assigned_identity.github_cd.id

  issuer   = "https://token.actions.githubusercontent.com"
  audience = ["api://AzureADTokenExchange"]
  subject  = "repo:raghadkhedhiri@123326129/spring-petclinic-devops@1349820324:ref:refs/heads/main"
}

resource "azurerm_role_definition" "github_cd_run_command" {
  name        = "${var.project_name}-github-cd-run-command"
  scope       = azurerm_resource_group.main.id
  description = "Least-privilege role for GitHub Actions CD to run deployment commands on the PetClinic VM"

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/runCommands/write"
    ]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.main.id
  ]
}

resource "azurerm_role_assignment" "github_cd_run_command" {
  scope              = azurerm_linux_virtual_machine.main.id
  role_definition_id = azurerm_role_definition.github_cd_run_command.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.github_cd.principal_id
  principal_type     = "ServicePrincipal"

  skip_service_principal_aad_check = true
}
