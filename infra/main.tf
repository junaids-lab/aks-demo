terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.aks_cluster_name

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_vm_size
  # zones      = ["1", "2", "3"] # Span across multiple Availability Zones 
  }

  identity {
    type = "SystemAssigned"
  }
}

# --- Changes for Azure SQL Database ---

# 1. Create the logical SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                = "${var.aks_cluster_name}-sql-server"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version             = "12.0"
  administrator_login = var.sql_username
  administrator_login_password = var.sql_password
}

# 2. Create the SQL Database on the server
resource "azurerm_mssql_database" "sql_db" {
  name                = "${var.aks_cluster_name}-sql-db"
  server_id           = azurerm_mssql_server.sql_server.id 
  sku_name            = "S0"
}

# 3. Add a firewall rule
resource "azurerm_mssql_firewall_rule" "aks_firewall_rule" {
  name             = "aks-firewall-rule"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}