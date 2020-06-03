resource "azurerm_kubernetes_cluster" "k8s" {
	name = "proyecto-aks"
	location = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name
	dns_prefix = "proyecto"

	default_node_pool {
		name = "default"
		node_count = 1
		vm_size = "Standard_D2_v2"
	}

	identity {
		type = "SystemAssigned"
	}

	tags = {
		Environment = "Production"
	}
}

output "kube_config" {
	value = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
}
