resource "azurerm_resource_group" "trf" {

  name     = "${var.prefix}-Stbos"

  location = var.location

}

 

resource "azurerm_virtual_network" "vnet" {

  name                = "${var.prefix}-network"

  address_space       = ["13.0.0.0/16"]

  location            = azurerm_resource_group.tfrg.location

  resource_group_name = azurerm_resource_group.tfrg.name

}

 

resource "azurerm_subnet" "tfsubnet" {

  name                 = "StbosSN"

  resource_group_name  = azurerm_resource_group.tfrg.name

  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefix       = "13.0.2.0/24"

}

 

resource "azurerm_public_ip" "pip" {

  name                = "${var.prefix}-pip"

  resource_group_name = azurerm_resource_group.tfrg.name

  location            = azurerm_resource_group.tfrg.location

  allocation_method   = "Static"

}

 

resource "azurerm_network_interface" "tfnic" {

  name                = "${var.prefix}-nic1"

  resource_group_name = azurerm_resource_group.tfrg.name

  location            = azurerm_resource_group.tfrg.location

 

  ip_configuration {

    name                          = "primary"

    subnet_id                     = azurerm_subnet.tfsubnet.id

    private_ip_address_allocation = "Static"

    public_ip_address_id          = azurerm_public_ip.pip.id

  }

}

 

resource "azurerm_network_security_group" "tfnsg" {

  name                = "${var.prefix}-NSG"

  location            = azurerm_resource_group.tfrg.location

  resource_group_name = azurerm_resource_group.tfrg.name

  security_rule {

    access                     = "Allow"

    direction                  = "Inbound"

    name                       = "ssh"

    priority                   = 100

    protocol                   = "Tcp"

    source_port_range          = "*"

    source_address_prefix      = "*"

    destination_port_range     = "22"

    destination_address_prefix = "*"

  }

}

 

resource "azurerm_network_interface_security_group_association" "nsgassociation" {

  network_interface_id      = azurerm_network_interface.tfnic.id

  network_security_group_id = azurerm_network_security_group.tfnsg.id

}

 

resource "azurerm_linux_virtual_machine" "main" {

  name                            = "${var.prefix}-vm"

  resource_group_name             = azurerm_resource_group.tfrg.name

  location                        = azurerm_resource_group.tfrg.location

  size                            = "Standard_DS1_v2"

  admin_username                  = "adminuser"

  admin_password                  = var.password

  disable_password_authentication = false

  network_interface_ids = [

    azurerm_network_interface.tfnic.id,

      ]

 

  source_image_reference {

    publisher = "Canonical"

    offer     = "UbuntuServer"

    sku       = "16.04-LTS"

    version   = "latest"

  }

 

  os_disk {

    storage_account_type = "Standard_LRS"

    caching              = "ReadWrite"

  }

}
