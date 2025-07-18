module "resource_group" {
  source                  = "../../modules/azurerm_resource_group"
  resource_group_name     = "todoinfra-rg"
  resource_group_location = "westindia"
}

module "azurerm_network_security_group" {
  depends_on          = [module.resource_group]
  source              = "../../modules/azurerm_network_security_group"
  nsg_name            = "todoinfra-nsg"
  location            = "westindia"
  resource_group_name = "todoinfra-rg"
}

module "azurerm_virtual_network" {
  depends_on          = [module.resource_group, module.azurerm_network_security_group]
  source              = "../../modules/azurerm_virtual_network"
  vnet_name           = "todoinfra-vnet"
  resource_group_name = "todoinfra-rg"
  location            = "westindia"
  address_space       = ["10.0.0.0/16"]
}

module "frontend_subnet" {
  depends_on           = [module.azurerm_virtual_network]
  source               = "../../modules/azurerm_subnet"
  subnet_name          = "todoinfra-frontend-subnet"
  resource_group_name  = "todoinfra-rg"
  virtual_network_name = "todoinfra-vnet"
  address_prefixes     = ["10.0.1.0/24"]
}

module "backend_subnet" {
  depends_on           = [module.azurerm_virtual_network]
  source               = "../../modules/azurerm_subnet"
  subnet_name          = "todoinfra-backend-subnet"
  resource_group_name  = "todoinfra-rg"
  virtual_network_name = "todoinfra-vnet"
  address_prefixes     = ["10.0.2.0/24"]
}

module "frontend_public_ip" {
  depends_on          = [module.azurerm_virtual_network, module.frontend_subnet]
  source              = "../../modules/azurerm_public_ip"
  public_ip_name      = "todoinfra-frontend-pip"
  location            = "westindia"
  resource_group_name = "todoinfra-rg"
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "backend_public_ip" {
  depends_on          = [module.azurerm_virtual_network, module.backend_subnet]
  source              = "../../modules/azurerm_public_ip"
  public_ip_name      = "todoinfra-backend-pip"
  location            = "westindia"
  resource_group_name = "todoinfra-rg"
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "azurerm_key_vault" {
  depends_on          = [module.resource_group]
  source              = "../../modules/azurerm_key_vault"
  key_vault_name      = "todoinfra-kv"
  resource_group_name = "todoinfra-rg"
  location            = "westindia"

}
module "azurerm_key_vault_secret_username" {
  depends_on          = [module.azurerm_key_vault]
  source              = "../../modules/azurerm_key_vault_secret"
  key_vault_name      = "todoinfra-kv"
  resource_group_name = "todoinfra-rg"
  secret_name         = "username"
  secret_value        = "todoinfraadmin"
}

module "azurerm_key_vault_secret_password" {
  depends_on          = [module.azurerm_key_vault, module.azurerm_key_vault_secret_username]
  source              = "../../modules/azurerm_key_vault_secret"
  key_vault_name      = "todoinfra-kv"
  resource_group_name = "todoinfra-rg"
  secret_name         = "password"
  secret_value        = "todoinfrapassword"
}

module "azurerm_sql_server" {
  depends_on          = [module.azurerm_key_vault_secret_username, module.azurerm_key_vault_secret_password]
  source              = "../../modules/azurerm_sql_server"
  sql_server_name     = "todoinfra-sql-server"
  resource_group_name = "todoinfra-rg"
  location            = "westindia"
  key_vault_name      = "todoinfra-kv"
  secret_username     = "username"
  secret_password     = "password"
}

module "azurerm_sql_database" {
  depends_on          = [module.azurerm_sql_server]
  source              = "../../modules/azurerm_sql_database"
  database_name       = "todoinfra-sql-database"
  resource_group_name = "todoinfra-rg"
  sql_server_name     = "todoinfra-sql-server"
}

module "azurerm_linux_virtual_machine_frontend" {
  depends_on            = [module.resource_group, module.azurerm_virtual_network, module.frontend_public_ip, module.azurerm_key_vault_secret_username, module.azurerm_key_vault_secret_password]
  source                = "../../modules/azurerm_virtual_machine"
  nic_name              = "todoinfra-frontend-nic"
  resource_group_name   = "todoinfra-rg"
  location              = "westindia"
  ip_configuration_name = "todoinfra-frontend-ip-config"
  vm_name               = "todoinfra-frontend-vm"
  vm_size               = "Standard_B1s"
  public_ip_name        = "todoinfra-frontend-pip"
  subnet_name           = "todoinfra-frontend-subnet"
  virtual_network_name  = "todoinfra-vnet"
  key_vault_name        = "todoinfra-kv"
  secret_username       = "username"
  secret_password       = "password"
  imagepublisher        = "Canonical"
  imageoffer            = "0001-com-ubuntu-server-focal"
  imagesku              = "20_04-lts"
  imageversion          = "latest"
}

module "azurerm_linux_virtual_machine_backend" {
  depends_on            = [module.resource_group, module.azurerm_virtual_network, module.backend_public_ip, module.azurerm_key_vault_secret_username, module.azurerm_key_vault_secret_password]
  source                = "../../modules/azurerm_virtual_machine"
  nic_name              = "todoinfra-backend-nic"
  resource_group_name   = "todoinfra-rg"
  location              = "westindia"
  ip_configuration_name = "todoinfra-backend-ip-config"
  vm_name               = "todoinfra-backend-vm"
  vm_size               = "Standard_B1s"
  public_ip_name        = "todoinfra-backend-pip"
  subnet_name           = "todoinfra-backend-subnet"
  virtual_network_name  = "todoinfra-vnet"
  key_vault_name        = "todoinfra-kv"
  secret_username       = "username"
  secret_password       = "password"
  imagepublisher        = "Canonical"
  imageoffer            = "0001-com-ubuntu-server-focal"
  imagesku              = "20_04-lts"
  imageversion          = "latest"
}
