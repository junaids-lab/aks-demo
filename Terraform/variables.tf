variable "resource_group_name" {
  description = "The name of the resource group to create."
  type        = string
  default     = "aks-demo-rg"
}

variable "location" {
  description = "The Azure region to deploy resources in."
  type        = string
  default     = "North Europe"
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
  default     = "aks-demo-cluster"
}