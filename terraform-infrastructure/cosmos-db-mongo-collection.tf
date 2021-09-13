resource "azurerm_cosmosdb_mongo_collection" "event_collection" {
  name                = "events"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.db_account.name
  database_name       = azurerm_cosmosdb_mongo_database.mongo_db.name

  default_ttl_seconds = "777"
  shard_key           = "uniqueKey"
  throughput          = 400
  
  lifecycle {
      ignore_changes = [index]
  }
}