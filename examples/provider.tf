terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.76.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.aks_cluster.host
  username               = module.aks_cluster.username
  password               = module.aks_cluster.password
  client_certificate     = "${base64decode(module.aks_cluster.client_certificate)}"
  client_key             = "${base64decode(module.aks_cluster.client_key)}"
  cluster_ca_certificate = "${base64decode(module.aks_cluster.cluster_ca_certificate)}"
}