# ─────────────────────────────────────────────────────────────────────────────
# modules/sql/main.tf
# Azure SQL Server + Database provisioned with serverless SKU and firewall rules.
# ─────────────────────────────────────────────────────────────────────────────

resource "azurerm_mssql_server" "this" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"

  tags = var.tags
}

resource "azurerm_mssql_database" "this" {
  name         = var.sql_database_name
  server_id    = azurerm_mssql_server.this.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "BasePrice"
  max_size_gb  = 5
  sku_name     = "GP_S_Gen5_1" # Serverless General Purpose

  tags = var.tags
}

# Allow Azure Services / internal connections
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# VNet Rule for AKS Subnet Service Endpoint
resource "azurerm_mssql_virtual_network_rule" "aks_subnet" {
  name      = "aks-vnet-rule"
  server_id = azurerm_mssql_server.this.id
  subnet_id = var.aks_subnet_id
}
