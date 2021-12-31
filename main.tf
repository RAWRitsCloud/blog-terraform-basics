# Using a Random Password Provider so that we know it meets the requirements.
resource "random_password" "password" {
  length           = 16
  special          = true
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  min_upper        = 2
  override_special = "_%!&*"
}

# Create 2 resource groups, one for the VNETS and one for the Virutal Machine components
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg-${var.loc_short}-networking"
  location = var.location
}

resource "azurerm_resource_group" "vms" {
  name     = "${var.prefix}-rg-${var.loc_short}-vms"
  location = var.location
}

# Create the Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet-${var.loc_short}-01"
  address_space       = ["10.0.0.0/23"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "sn-servers"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create the Virtual Machine
resource "azurerm_network_interface" "main" {
  name                = "${local.vmprefix}vm01-nic"
  location            = azurerm_resource_group.vms.location
  resource_group_name = azurerm_resource_group.vms.name

  ip_configuration {
    name                          = "ipv4"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name                = "${local.vmprefix}vm01"
  resource_group_name = azurerm_resource_group.vms.name
  location            = azurerm_resource_group.vms.location
  size                = "Standard_B1"
  admin_username      = "rawritscloud"
  admin_password      = random_password.password.result
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
