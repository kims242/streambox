# 1. IP Publique pour accéder à SonarQube depuis Internet
resource "azurerm_public_ip" "sonar_ip" {
  name                = "ip-sonar-${local.env}"
  resource_group_name = module.rg.name
  location            = module.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 2. Groupe de Sécurité (Pare-feu)
resource "azurerm_network_security_group" "sonar_nsg" {
  name                = "nsg-sonar-${local.env}"
  location            = module.rg.location
  resource_group_name = module.rg.name

  # Autoriser SSH (Port 22)
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Autoriser SonarQube (Port 9000)
  security_rule {
    name                       = "SonarQube"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Création d'un réseau dédié pour la VM
resource "azurerm_virtual_network" "vm_vnet" {
  name                = "vnet-vm-${local.env}"
  address_space       = ["10.0.0.0/16"]
  location            = module.rg.location
  resource_group_name = module.rg.name
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "subnet-vm"
  resource_group_name  = module.rg.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 3. Carte Réseau (NIC) - VERSION CORRIGÉE
resource "azurerm_network_interface" "sonar_nic" {
  name                = "nic-sonar-${local.env}"
  location            = module.rg.location
  resource_group_name = module.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id # On utilise le subnet créé juste au-dessus
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sonar_ip.id
  }
}
# Associer le NSG à la NIC
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.sonar_nic.id
  network_security_group_id = azurerm_network_security_group.sonar_nsg.id
}

# 4. La Machine Virtuelle
resource "azurerm_linux_virtual_machine" "sonar_vm" {
  name                = "vm-sonar-${local.env}"
  resource_group_name = module.rg.name
  location            = module.rg.location
  size                = "Standard_B2s_v2" # 4GB RAM (Requis pour SonarQube)
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.sonar_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    # On lit le fichier de clé publique que tu viens de créer
    public_key = file("~/.ssh/streambox_key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Output pour récupérer l'IP facilement
output "sonar_public_ip" {
  value = azurerm_public_ip.sonar_ip.ip_address
}