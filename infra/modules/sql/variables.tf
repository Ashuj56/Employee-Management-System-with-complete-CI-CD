variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "sql_server_name" { type = string }
variable "sql_database_name" { type = string }
variable "sql_admin_login" { type = string }
variable "sql_admin_password" {
  type      = string
  sensitive = true
}
variable "aks_subnet_id" { type = string }
variable "vnet_id" { type = string }
variable "tags" { type = map(string) }
