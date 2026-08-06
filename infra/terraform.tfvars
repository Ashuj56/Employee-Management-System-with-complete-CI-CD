# ─────────────────────────────────────────────────────────────────────────────
# infra/terraform.tfvars
# Default values for the EMS dev environment.
# This file is safe to commit — it contains NO secrets.
#
# Sensitive values (sql_admin_password) must be set via:
#   export TF_VAR_sql_admin_password="YourPassword"
# or a git-ignored secrets.tfvars file:
#   terraform apply -var-file="secrets.tfvars"
# ─────────────────────────────────────────────────────────────────────────────

# General
location    = "centralus"
environment = "dev"

# Resource Group
resource_group_name = "rg-ems-dev"

# Networking
vnet_name          = "vnet-ems"
vnet_address_space = ["10.0.0.0/16"]
aks_subnet_cidr    = "10.0.1.0/24"

# AKS
aks_cluster_name   = "aks-ems-dev"
kubernetes_version = "1.29"
aks_node_vm_size   = "Standard_B2s"
aks_node_count     = 2

# ACR
acr_name = "acremsdev"
acr_sku  = "Standard"

# Azure SQL
sql_server_name   = "emserver"
sql_database_name = "Emdb"
sql_admin_login   = "ashuj71"
# sql_admin_password  →  set via TF_VAR_sql_admin_password env var

# Key Vault
key_vault_name = "kv-ems-dev"

# Monitoring
log_analytics_workspace_name = "law-ems-dev"
log_analytics_retention_days = 30
