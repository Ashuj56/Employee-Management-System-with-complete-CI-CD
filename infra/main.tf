# ─────────────────────────────────────────────────────────────────────────────
# infra/main.tf
# Root module — wires all sub-modules together to provision the full EMS
# infrastructure on Azure.
# ─────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # ── Remote State (uncomment to store state in Azure Blob Storage) ──────────
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate"
  #   storage_account_name = "stterraformstate<suffix>"
  #   container_name       = "tfstate"
  #   key                  = "ems/terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {}

# ─────────────────────────────────────────────────────────────────────────────
# Current client / tenant info (used by Key Vault access policies)
# ─────────────────────────────────────────────────────────────────────────────
data "azurerm_client_config" "current" {}

# ─────────────────────────────────────────────────────────────────────────────
# Module: Resource Group
# ─────────────────────────────────────────────────────────────────────────────
module "resource_group" {
  source = "./modules/resource_group"

  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Module: Networking (VNet + Subnets)
# ─────────────────────────────────────────────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  aks_subnet_cidr     = var.aks_subnet_cidr
  tags                = local.common_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Module: Log Analytics (must come before AKS for the add-on)
# ─────────────────────────────────────────────────────────────────────────────
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  workspace_name      = var.log_analytics_workspace_name
  retention_days      = var.log_analytics_retention_days
  tags                = local.common_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Module: Azure Container Registry
# ─────────────────────────────────────────────────────────────────────────────
module "acr" {
  source = "./modules/acr"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  acr_name            = var.acr_name
  sku                 = var.acr_sku
  tags                = local.common_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Module: AKS Cluster
# ─────────────────────────────────────────────────────────────────────────────
module "aks" {
  source = "./modules/aks"

  resource_group_name       = module.resource_group.name
  location                  = module.resource_group.location
  cluster_name              = var.aks_cluster_name
  kubernetes_version        = var.kubernetes_version
  node_vm_size              = var.aks_node_vm_size
  node_count                = var.aks_node_count
  aks_subnet_id             = module.networking.aks_subnet_id
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags                      = local.common_tags
}

# ── Grant AKS kubelet identity AcrPull on the ACR ─────────────────────────
module "acr_aks_role" {
  source = "./modules/acr"

  # Re-use only the role-assignment sub-resource — main resources skipped
  # by using a dedicated role assignment resource inside the acr module.
  resource_group_name  = module.resource_group.name
  location             = module.resource_group.location
  acr_name             = var.acr_name
  sku                  = var.acr_sku
  aks_kubelet_identity = module.aks.kubelet_identity_object_id
  tags                 = local.common_tags

  # Prevent duplicate resource creation — ACR already created above.
  depends_on = [module.acr, module.aks]
}

# ─────────────────────────────────────────────────────────────────────────────
# Module: Azure SQL Server + Database
# ─────────────────────────────────────────────────────────────────────────────
module "sql" {
  source = "./modules/sql"

  resource_group_name  = module.resource_group.name
  location             = module.resource_group.location
  sql_server_name      = var.sql_server_name
  sql_database_name    = var.sql_database_name
  sql_admin_login      = var.sql_admin_login
  sql_admin_password   = var.sql_admin_password
  aks_subnet_id        = module.networking.aks_subnet_id
  vnet_id              = module.networking.vnet_id
  tags                 = local.common_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Module: Azure Key Vault
# ─────────────────────────────────────────────────────────────────────────────
module "key_vault" {
  source = "./modules/key_vault"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  key_vault_name      = var.key_vault_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  db_password         = var.sql_admin_password
  tags                = local.common_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Locals
# ─────────────────────────────────────────────────────────────────────────────
locals {
  common_tags = {
    project     = "employee-management-system"
    environment = var.environment
    managed_by  = "terraform"
  }
}
