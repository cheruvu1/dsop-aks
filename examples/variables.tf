variable "enable_auto_scaling" {
  description = "enable node pool autoscaling"
  type        = bool
  default     = true
}

variable "node_count" {
  description = "number of nodes to deploy"
  default     = 2
}

variable "dns_prefix" {
  description = "DNS Suffix"
  default     = "akscluster"
}

variable "private_cluster_enabled" {
  description = "Kubernetes cluster API server only on internal IP addresses"
  default = false
}

variable cluster_name {
  description = "AKS cluster name"
  default     = "aks-cluster"
}

variable resource_group_name {
  description = "name of the resource group to deploy AKS cluster in"
  default     = "aks-cluster-rg"
}

variable location {
  description = "azure location to deploy resources"
  default     = "usgovvirginia"
}

variable subnet_name {
  description = "subnet id where the nodes will be deployed"
  default     = "akscluster-subnet"
}

variable vnet_name {
  description = "vnet id where the nodes will be deployed"
  default     = "akscluster-vnet"
}

variable subnet_cidr {
  description = "the subnet cidr range"
  default     = "10.2.32.0/21"
}

variable kubernetes_version {
  description = "version of the kubernetes cluster"
  default     = "1.16.10"
}

variable "vm_size" {
  description = "size/type of VM to use for nodes"
  default     = "Standard_D2_v2"
}

variable "os_disk_size_gb" {
  description = "size of the OS disk to attach to the nodes"
  default     = 512
}

variable "max_pods" {
  description = "maximum number of pods that can run on a single node"
  default     = "100"
}

variable "address_space" {
  description = "The address space that is used the virtual network"
  default     = "10.2.0.0/16"
}
variable "min_count" {
  default     = 1
  description = "Minimum Node Count"
}
variable "max_count" {
  default     = 2
  description = "Maximum Node Count"
}

variable "managed_identity" {
  description = "AKS cluster name"
  default = "false"
}

variable "aad_group_ids" {
  description = "Name of the Azure AD group for cluster-admin access"
  type        = list(string)
}

variable "use_external_vnet" {
  description = "Use existing Virtual Network"
  type        = bool
  default     = false
}

variable "external_vnet_name" {
  description = "Existing Virtual Network name"
  type        = string
  default     = ""
}

variable "external_vnet_resource_group" {
  description = "Existing Virtual Network name"
  type        = string
  default     = ""
}

variable "external_vnet_subnet_name" {
  description = "Existing VNET subnet name"
  type        = string
  default     = "default"
}