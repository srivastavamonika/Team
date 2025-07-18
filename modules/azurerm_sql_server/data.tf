data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}
data "azurerm_key_vault_secret" "kv-secret-username" {
  name         = var.secret_username 
  key_vault_id = data.azurerm_key_vault.kv.id
}
data "azurerm_key_vault_secret" "kv-secret-password" {
  name         = var.secret_password
  key_vault_id = data.azurerm_key_vault.kv.id
  
}
