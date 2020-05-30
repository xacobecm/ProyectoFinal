# Configuramos azure
provider "azurerm" {
	features {}

	subscription_id = "00bee382-32ba-42b5-bb2a-5077c7ed4323"
	client_id = "08fa3194-3ee0-4b9a-a069-304b1fded178"
	client_secret = "7845e6fb-55d9-4cbb-8d45-de4f22ccafab"
	tenant_id = "a824cf21-a219-42cb-9a48-616853d0a05f"
}

# Grupo de recursos
resource "azurerm_resource_group" "rg" {
	name = "proyecto-ciclo"
	location = "westeurope"

	tags = {
		environment = "Proyecto fin de Ciclo"
	}
}

# Creamos red 
resource "azurerm_virtual_network" "red" {
	name = "proyecto-red-agent"
	address_space = ["10.0.0.0/16"]
	location = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name
}

# Creamos subred
resource "azurerm_subnet" "subred" {
	name = "proyecto-subred-agent"
	resource_group_name = azurerm_resource_group.rg.name
	virtual_network_name = azurerm_virtual_network.red.name
	address_prefixes = ["10.0.2.0/24"]
}

# Creamos una IP Pública
resource "azurerm_public_ip" "ip-publica" {
  name                = "proyecto-ip-agent"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

# Creamos interfaz de red
resource "azurerm_network_interface" "interfaz" {
	name = "proyecto-interfaz-agent"
	resource_group_name = azurerm_resource_group.rg.name
	location = azurerm_resource_group.rg.location

	ip_configuration {
		name = "internal"
		subnet_id = azurerm_subnet.subred.id
		private_ip_address_allocation = "Dynamic"
		public_ip_address_id = azurerm_public_ip.ip-publica.id
	}
}

# Creamos máquina virtual
resource "azurerm_linux_virtual_machine" "vm" {
	name = "proyecto-vm-agent"
	resource_group_name = azurerm_resource_group.rg.name
	location = azurerm_resource_group.rg.location
	size = "Standard_F2"
	admin_username = "xac0"
	admin_password = "Coremain1234!"
	disable_password_authentication = false
	network_interface_ids = [
		azurerm_network_interface.interfaz.id
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
			"sudo docker login --username=xac0 --password=Coremain1234! xac0.xyz:5000",
			"sudo docker run -e AZP_URL=https://dev.azure.com/Cor3M -e AZP_TOKEN=cvynclhyp3jrdolcacx6h2vabrejlo24wcafha3bpcv6qxvhl2wq -e AZP_AGENT_NAME=tf-worker -e AZP_POOL=xac0 xac0.xyz:5000/azure-agent:latest"
		]

		connection {
			host = self.public_ip_address
			user = self.admin_username
			password = self.admin_password
		}
	}
}
