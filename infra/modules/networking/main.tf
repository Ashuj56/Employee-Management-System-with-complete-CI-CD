# ─────────────────────────────────────────────────────────────────────────────
# modules/networking/main.tf
# Creates the VNet with an AKS subnet and enables the Microsoft.Sql
# service endpoint on that subnet (used by SQL Server firewall rule).
# ─────────────────────────────────────────────────────────────────────────────

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.aks_subnet_cidr]

  # Service endpoint so AKS pods can reach Azure SQL over the private backbone
  service_endpoints = ["Microsoft.Sql"]
}
