resource "azurerm_container_group" "aci" {
  name                = "tvguide-instance"
  depends_on          = [null_resource.push_image]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_address_type     = "public"
  dns_name_label      = "${var.app-resource-group}"
  os_type             = "Linux"

// data "azurerm_cosmosdb_account" "cosdb" {
//   name                = "${var.cosmosdbname}"
//   resource_group_name = "${var.cosmosdbresourcegroupname}"
// }

// output "cosmosdb_connectionstrings" {
//    value = ${data.azurerm_cosmosdb_account.cosdb.endpoint};AccountKey=${data.azurerm_cosmosdb_account.cosdb.primary_master_key// };"
//    sensitive   = true
// }

  container {
    name   = "app"
    image  = "${var.app-resource-group}.azurecr.io/app:${var.app-version}"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  image_registry_credential {
        server = azurerm_container_registry.acr.login_server
        username = azurerm_container_registry.acr.admin_username
        password = azurerm_container_registry.acr.admin_password
  }

  tags = {
    environment = "dev"
  }
} 

resource null_resource push_image {
  depends_on = [azurerm_container_registry.acr]
  provisioner "local-exec" {
    command = "az acr login --name ${var.app-resource-group} ; docker push ${var.app-resource-group}.azurecr.io/app:${var.app-version}"
  }
}
