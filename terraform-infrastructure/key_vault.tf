resource "azurerm_key_vault" "event-keyvault" {
  name                        = "event-keyvault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "premium"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "list",
      "get",
    ]

    secret_permissions = [
      "list",
      "set",
      "get",
      "delete",
      "purge",
      "recover"
    ]
  }
}

resource "azurerm_key_vault_secret" "connect_string" {
  name         = "connectstring"
  value        = azurerm_cosmosdb_account.db_account.connection_strings[0]
  key_vault_id = azurerm_key_vault.event-keyvault.id
}

resource azurerm_key_vault_secret storage_primary_blob_endpoint {
    name = "storageprimaryblobendpoint"
    value = azurerm_storage_account.storage_account.primary_blob_endpoint
    key_vault_id = azurerm_key_vault.event-keyvault.id
}
resource azurerm_key_vault_secret storage_primary_blob_host {
    name = "storageprimaryblobhost"
    value = azurerm_storage_account.storage_account.primary_blob_host
    key_vault_id = azurerm_key_vault.event-keyvault.id
}