resource "azurerm_storage_account" "example" {
  name                     = "eventstorage${random_integer.ri.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" // locally,  "GRS" == globally
  tags = {
    environment = "dev"
  }
}