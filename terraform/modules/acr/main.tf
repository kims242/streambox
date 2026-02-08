resource "azurerm_container_registry" "acr" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic" # Suffisant pour du dev
  admin_enabled       = true    # Utile pour les tests rapides (docker login)
}

variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }

output "login_server" { value = azurerm_container_registry.acr.login_server }
output "admin_username" { value = azurerm_container_registry.acr.admin_username }