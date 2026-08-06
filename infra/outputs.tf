# ─────────────────────────────────────────────────────────────────────────────
# infra/outputs.tf
# ─────────────────────────────────────────────────────────────────────────────

# ── Resource Group ─────────────────────────────────────────────────────────────
output "resource_group_name" {
  description = "Name of the provisioned resource group."
  value       = module.resource_group.name
}

# ── AKS ───────────────────────────────────────────────────────────────────────
output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.cluster_name
}

output "aks_kubeconfig_command" {
  description = "Run this command to fetch AKS credentials into ~/.kube/config."
  value       = "az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.cluster_name} --overwrite-existing"
}

output "aks_kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet managed identity (needed for RBAC)."
  value       = module.aks.kubelet_identity_object_id
}

# ── ACR ───────────────────────────────────────────────────────────────────────
output "acr_login_server" {
  description = "ACR login server URL (use as Docker registry in Jenkinsfile)."
  value       = module.acr.login_server
}

output "acr_name" {
  description = "Azure Container Registry name."
  value       = module.acr.name
}

# ── Azure SQL ──────────────────────────────────────────────────────────────────
output "sql_server_fqdn" {
  description = "Fully qualified domain name of the Azure SQL Server."
  value       = module.sql.sql_server_fqdn
}

output "sql_database_name" {
  description = "Azure SQL database name."
  value       = module.sql.database_name
}

output "sql_connection_string" {
  description = "ODBC connection string for the backend (password redacted)."
  value       = "Driver={ODBC Driver 18 for SQL Server};Server=tcp:${module.sql.sql_server_fqdn},1433;Database=${module.sql.database_name};Uid=${var.sql_admin_login};Pwd=<from-key-vault>;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
}

# ── Key Vault ──────────────────────────────────────────────────────────────────
output "key_vault_uri" {
  description = "URI of the Azure Key Vault."
  value       = module.key_vault.vault_uri
}

output "db_password_secret_id" {
  description = "Key Vault secret ID for DB_PASSWORD (use with CSI driver or External Secrets)."
  value       = module.key_vault.db_password_secret_id
}

# ── Monitoring ─────────────────────────────────────────────────────────────────
output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = module.monitoring.workspace_id
}
