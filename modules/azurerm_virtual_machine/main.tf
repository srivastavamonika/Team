resource "azurerm_network_interface" "name" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = data.azurerm_subnet.subnet.id
    public_ip_address_id          = data.azurerm_public_ip.public_ip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "name" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = data.azurerm_key_vault_secret.vm_admin_username.value
  admin_password      = data.azurerm_key_vault_secret.vm_admin_password.value
  disable_password_authentication = "false"
  network_interface_ids = [azurerm_network_interface.name.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher =  var.imagepublisher
    offer     = var.imageoffer
    sku       = var.imagesku
    version   = var.imageversion
  }
    custom_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    EOF
    )

}
