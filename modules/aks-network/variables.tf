variable "subnet_name" {
  description = "name to give the subnet"
  default     = "default-subnet"
}

variable "resource_group_name" {
  description = "resource group that the vnet resides in"
}

variable "vnet_name" {
  description = "name of the vnet that this subnet will belong to"
  default     = "vnet"
}

variable "subnet_cidr" {
  description = "the subnet cidr range"
}

variable "location" {
  description = "the cluster location"
}

variable "address_space" {
  description = "Network address space"
}

variable "use_external_vnet" {
  description = "Use existing Virtual Network"
}