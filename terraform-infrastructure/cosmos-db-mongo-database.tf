resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  name                = "${var.app-resource-group}-cosmos-mongodb"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.db_account.name
  throughput          = 400
}