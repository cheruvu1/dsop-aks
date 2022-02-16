resource "kubernetes_daemonset" "node-bootstrap" {
  depends_on = [azurerm_kubernetes_cluster.cluster]
  metadata {
    name   = "node-bootstrap"
    labels = {
      name = "node-bootstrap"
    }
  }

  spec {
    selector {
      match_labels = {
        test = "node-bootstrap"
      }
    }

    template {
      metadata {
        labels = {
          test = "node-bootstrap"
        }
      }

      spec {
        container {
          image = "gcr.io/google-containers/startup-script:v1"
          name  = "node-bootstrap"
          image_pull_policy = "IfNotPresent"
          security_context {
            privileged = "true"
          }
          env {
            name = "STARTUP_SCRIPT"
          	value = "sysctl -w vm.max_map_count=262144"
          }
        }
      }
    }
  }
}