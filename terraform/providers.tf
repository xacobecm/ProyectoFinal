provider "azurerm" {
        features {}

        subscription_id = var.sub-id
        client_id = var.cli-id
        client_secret = var.cli-sec
        tenant_id = var.ten-id
}

provider "kubernetes" {
	# Esto carga la config desde ~/.kube/config
}

# Grupo de recursos
resource "azurerm_resource_group" "rg" {
        name = "proyecto-ciclo"
        location = "westeurope"

        tags = {
                environment = "Proyecto fin de Ciclo"
        }
}

