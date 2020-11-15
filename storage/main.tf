resource "azurerm_resource_group" "storage" {
       location  = "central us"
       name = "storage-account"

}

resource "azurerm_storage_account" "mystorage"{

    name  =   "mystorageaccountind1234"
    location = azurerm_resource_group.storage.location
    resource_group_name = azurerm_resource_group.storage.name
    account_tier = "standard"
    account_replication_type = "LRS"
}