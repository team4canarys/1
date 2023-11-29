output "resource_group_name" {
  value = azurerm_resource_group.devopsathon.name
}

output "service_plan"{
  value = azurerm_service_plan.service_plan.name
}

output "webapp"{
  value = azurerm_linux_web_app.webapp.name
}

output "mysql_server"{
  value = azurerm_mysql_flexible_server.mysqlserver.name
}