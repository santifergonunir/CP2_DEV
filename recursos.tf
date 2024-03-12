resource "azurerm_resource_group" "cp2" {
  name     = var.resource_group_name
  location = var.location_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.cp2.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "ippublica" {
  name = "ipPublica"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "nic" {
  name                = "vnic"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ippublica.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm1ubuntucp2"
  resource_group_name = azurerm_resource_group.cp2.name
  location            = azurerm_resource_group.cp2.location
  size                = "Standard_B1s"
  computer_name       = "vmubuntucp2"
  admin_username      = "administrador"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "administrador"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "cp2sfgacr"
  resource_group_name = azurerm_resource_group.cp2.name
  location            = azurerm_resource_group.cp2.location
  sku                 = "Standard"
  admin_enabled       = false
  anonymous_pull_enabled  = true
}

resource "azurerm_kubernetes_cluster" "akscp2sfg" {
  name                = "cp2akssfg"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name
  dns_prefix          = "dnsaks"

  default_node_pool {
    name       = "aksnodecp2"
    node_count = 1
    vm_size    = "Standard_A2_v2"
  }
  
  linux_profile {
    admin_username      = "administrador"
    ssh_key {
       key_data = file("~/.ssh/id_rsa.pub")
    }
  }
  identity {
    type = "SystemAssigned"
  }
}

