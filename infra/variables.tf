variable "resource_group_name" {
  description = "The name of the resource group to create."
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources in."
  type        = string
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "sql_username" {
  type        = string
  description = "The admin login for the SQL server."
}

variable "sql_password" {
  type        = string
  description = "The admin password for the SQL server."
  sensitive   = true
}

variable "aks_node_count" {
  type        = number
  description = "The number of nodes for the AKS cluster."
  default     = 1  # Set a sensible default for development environments
}

variable "aks_vm_size" {
  type        = string
  description = "The type of the vm size."
  default     = "Standard_D2ds_v6"  # Set a sensible default for development environments
}