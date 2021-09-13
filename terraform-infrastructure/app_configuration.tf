resource "azurerm_app_configuration" "appconf" {
  count = 0
  name                = "event-config-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.user_id.id
    ]
  }

}