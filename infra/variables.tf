# ─────────────────────────────────────────────────────────────────────────────
# infra/variables.tf
# ─────────────────────────────────────────────────────────────────────────────

# ── General ───────────────────────────────────────────────────────────────────
variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "centralus"
}

variable "environment" {
  description = "Deployment environment label (dev / staging / prod)."
  type        = string
  default     = "dev"
}

# ── Resource Group ─────────────────────────────────────────────────────────────
variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
  default     = "rg-ems-dev"
}

# ── Networking ─────────────────────────────────────────────────────────────────
variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
  default     = "vnet-ems"
}

variable "vnet_address_space" {
  description = "Address space for the VNet (CIDR list)."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_cidr" {
  description = "CIDR for the AKS node subnet."
  type        = string
  default     = "10.0.1.0/24"
}

# ── AKS ───────────────────────────────────────────────────────────────────────
variable "aks_cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "aks-ems-dev"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.29"
}

variable "aks_node_vm_size" {
  description = "VM size for the default AKS node pool."
  type        = string
  default     = "Standard_B2s"
}

variable "aks_node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
  default     = 2
}

# ── ACR ───────────────────────────────────────────────────────────────────────
variable "acr_name" {
  description = "Globally-unique name for Azure Container Registry (alphanumeric only)."
  type        = string
  default     = "acremsdev"
}

variable "acr_sku" {
  description = "ACR SKU (Basic | Standard | Premium)."
  type        = string
  default     = "Standard"
}

# ── Azure SQL ──────────────────────────────────────────────────────────────────
variable "sql_server_name" {
  description = "Name of the Azure SQL logical server (must be globally unique)."
  type        = string
  default     = "emserver"
}

variable "sql_database_name" {
  description = "Name of the Azure SQL database."
  type        = string
  default     = "Emdb"
}

variable "sql_admin_login" {
  description = "SQL Server administrator login."
  type        = string
  default     = "ashuj71"
}

variable "sql_admin_password" {
  description = "SQL Server administrator password. Stored in Key Vault."
  type        = string
  sensitive   = true
  # Do NOT set a default — pass via TF_VAR_sql_admin_password or a .tfvars file
  # that is git-ignored.
}

# ── Key Vault ──────────────────────────────────────────────────────────────────
variable "key_vault_name" {
  description = "Name of the Azure Key Vault (must be globally unique, 3-24 chars)."
  type        = string
  default     = "kv-ems-dev"
}

# ── Monitoring ─────────────────────────────────────────────────────────────────
variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  type        = string
  default     = "law-ems-dev"
}

variable "log_analytics_retention_days" {
  description = "Number of days to retain logs in the Log Analytics workspace."
  type        = number
  default     = 30
}
