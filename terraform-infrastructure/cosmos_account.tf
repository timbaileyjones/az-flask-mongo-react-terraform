resource azurerm_cosmosdb_account db_account {
  name                = "${var.app-resource-group}-cosmos-db-${random_integer.ri.result}"
  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = false // true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  // geo_location {
  //   location          = var.failover_location
  //   failover_priority = 1
  // }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
  lifecycle {
    ignore_changes = [capabilities]
  }
}

output "connectstring" {
  value = azurerm_cosmosdb_account.db_account.connection_strings[0]
  sensitive = true
}