# Creamos red 
resource "azurerm_virtual_network" "redreg" {
	name = "proyecto-red-registry"
	address_space = ["10.0.0.0/16"]
	location = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name
}

# Creamos subred
resource "azurerm_subnet" "subredreg" {
	name = "proyecto-subred-registry"
	resource_group_name = azurerm_resource_group.rg.name
	virtual_network_name = azurerm_virtual_network.redreg.name
	address_prefixes = ["10.0.2.0/24"]
}

# Creamos una IP Pública
resource "azurerm_public_ip" "ip-publicareg" {
  name                = "proyecto-ip-registry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

# Creamos interfaz de red
resource "azurerm_network_interface" "interfazreg" {
	name = "proyecto-interfaz-registry"
	resource_group_name = azurerm_resource_group.rg.name
	location = azurerm_resource_group.rg.location

	ip_configuration {
		name = "internal"
		subnet_id = azurerm_subnet.subredreg.id
		private_ip_address_allocation = "Dynamic"
		public_ip_address_id = azurerm_public_ip.ip-publicareg.id
	}
}

# Creamos máquina virtual
resource "azurerm_linux_virtual_machine" "vmreg" {
	name = "proyecto-vm-registry"
	resource_group_name = azurerm_resource_group.rg.name
	location = azurerm_resource_group.rg.location
	size = "Standard_F2"
	admin_username = var.vm-user
	admin_password = var.vm-pass
	disable_password_authentication = false
	network_interface_ids = [
		azurerm_network_interface.interfazreg.id
	]

	source_image_reference {
		publisher = "Canonical"
		offer = "UbuntuServer"
		sku = "18.04-LTS"
		version = "latest"
	}

	os_disk {
		storage_account_type = "Standard_LRS"
		caching = "ReadWrite"
	}

	# Provisioner que levanta el agent
	provisioner "remote-exec" {
		inline = [
			"echo 'Coremain1234!' | sudo -S apt update",
			"sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
			"curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
			"echo 'Coremain1234!' | sudo -S add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
			"sudo apt update",
			"sudo apt install -y docker-ce",
			"sudo usermod -aG docker xac0",
			"sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
			"sudo chmod +x /usr/local/bin/docker-compose",
			"git clone https://github.com/xacobecm/ProyectoFinal.git",
			"cd ProyectoFinal",
			"cd vm",
			"sudo docker-compose up -d",
		]

		connection {
			host = self.public_ip_address
			user = self.admin_username
			password = self.admin_password
		}
	}

}
