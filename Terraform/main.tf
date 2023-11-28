# Set the Azure Provider source and version being used
terraform {
  required_version = ">= 0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.1.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id ="0cf272aa-ba8f-49f7-aaa9-854db3536e69"
  client_id       = "552b471f-3e95-46a4-b5cd-4581e4f221f6"
  client_secret   = "sU_8Q~Ir.pdxJJiCQz5cz~UwpKhZEFw5tqBSVaXG"
  tenant_id       ="0c88fa98-b222-4fd8-9414-559fa424ce64"
 
}
resource "azurerm_resource_group" "devopsathon" {
  name     = "database-rg"
  location = "eastus"
}

resource "azurerm_service_plan" "service_plan" {
  name                = "linux_service_plan"
  resource_group_name = azurerm_resource_group.devopsathon.name
  location            = azurerm_resource_group.devopsathon.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "myshuttle-team4"
  resource_group_name = azurerm_resource_group.devopsathon.name
  location            = azurerm_service_plan.service_plan.location
  service_plan_id     = azurerm_service_plan.service_plan.id

  site_config {}
}

resource "azurerm_mysql_flexible_server" "mysqlserver" {
  name                   = "mysql-flexible-server"
  resource_group_name    = azurerm_resource_group.devopsathon.name
  location               = azurerm_resource_group.devopsathon.location
  administrator_login    = "mysqladmin"
  administrator_password = "Canarys@123"
  sku_name               = "B_Standard_B1s"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  zone                         = 1
}
