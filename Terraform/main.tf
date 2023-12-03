# Set the Azure Provider source and version being used
terraform {
  required_version = ">= 0.14"
 # backend "remote" {
   # organization = "Canarysteam4"
   # workspaces {
     # name = "myshuttleworkspace"
  #  }
   # hostname     = "app.terraform.io"
   # token        = "PwPJHmoV5u8TgQ.atlasv1.9buqmCb9AoUe98XPt6tngQeO3yiZzpMMfpMDqgxTnoGoxdpvNNmifCiQ9s41x7ma7nw"
 # }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.1.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id ="b6f408e9-b240-412d-b83d-1ec4fc938ee8"
  client_id       = "c7f59d11-4e5e-4c7b-b25d-9093238144bc"
  client_secret   = "e1Z8Q~KX~KcwRolI8vdiumoVJ8U4YNfqYo-XRbUi"
  tenant_id       ="0c88fa98-b222-4fd8-9414-559fa424ce64"
 
}

resource "azurerm_resource_group" "devopsathon" {
  name     = "devopsathon4-rg"
  location = "eastus"
}

resource "azurerm_service_plan" "service_plan" {
  name                = "linux_service_plan"
  resource_group_name = azurerm_resource_group.devopsathon.name
  location            = azurerm_resource_group.devopsathon.location
  os_type             = "Linux"
  sku_name            = "B1"
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
  storage {
    iops    = 360
    size_gb = 20
  }
  depends_on = [ azurerm_resource_group.devopsathon ]
}

resource "azurerm_mysql_flexible_database" "mydatabase" {
  name                = "MyShuttleDb"
  resource_group_name = azurerm_resource_group.devopsathon.name
  server_name         = azurerm_mysql_flexible_server.mysqlserver.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
resource "azurerm_mysql_flexible_server_firewall_rule" "example" {
  name                = "Alllowall"
  resource_group_name = azurerm_resource_group.devopsathon.name
  server_name         = azurerm_mysql_flexible_server.mysqlserver.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
  depends_on = [azurerm_mysql_flexible_server.mysqlserver]
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  resource_group_name = azurerm_resource_group.devopsathon.name
  server_name         = azurerm_mysql_flexible_server.mysqlserver.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
  depends_on = [azurerm_mysql_flexible_server.mysqlserver]
}
resource "azurerm_linux_web_app" "webapp" {
  name                = "myshuttle-team4"
  resource_group_name = azurerm_resource_group.devopsathon.name
  location            = azurerm_service_plan.service_plan.location
  service_plan_id     = azurerm_service_plan.service_plan.id

  site_config {
    always_on = false
    
  }
   app_settings = {
    "WEBSITE_JAVA_VERSION"     = "1.8"
    "TOMCAT_VERSION"           = "8.5"
  }
  connection_string {
    name  = azurerm_mysql_flexible_database.mydatabase.name
    type  = "MySql"
    value = "jdbc:mysql://${azurerm_mysql_flexible_server.mysqlserver.name}.mysql.database.azure.com/MyShuttleDb?useSSL=true&requireSSL=false&autoReconnect=true&user=${azurerm_mysql_flexible_server.mysqlserver.administrator_login}&password=${azurerm_mysql_flexible_server.mysqlserver.administrator_password}"
  }
  depends_on = [ azurerm_service_plan.service_plan, azurerm_resource_group.devopsathon ]
}
