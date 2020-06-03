resource "kubernetes_deployment" "crud" {
	metadata {
		name = "crud-deployment"
		labels = {
			App = "crud"
		}
	}
	spec {
		replicas = 2
		selector {
			match_labels = {
				App = "crud"
			}
		}
		template {
			metadata {
				labels = {
					App = "crud"
				}
			}
			spec {
				container {
					image = "nginx:latest"
					name = "crud"

					port {
						container_port = 3000	
					}
				}

				image_pull_secrets {
					name = "regcred"
				}
			}
		}
	}
}

resource "kubernetes_service" "crud" {
  metadata {
    name = "crud-loadbalancer"
  }
  spec {
    selector = {
      App = kubernetes_deployment.crud.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment" "mongo" {

}
