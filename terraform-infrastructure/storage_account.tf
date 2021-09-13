resource "azurerm_storage_account" "storage_account" {
  name                     = "eventstorage${random_integer.ri.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" // locally,  "GRS" == globally
  tags = {
    environment = "dev"
  }
}

output storage_primary_blob_endpoint {
    value = azurerm_storage_account.storage_account.primary_blob_endpoint
}
output storage_primary_blob_host {
    value = azurerm_storage_account.storage_account.primary_blob_host
}
// output storage_secondary_blob_endpoint {
//     value = azurerm_storage_account.storage_account.secondary_blob_endpoint
// }
// output storage_secondary_blob_host {
//     value = azurerm_storage_account.storage_account.storage_secondary_blob_host 
// }