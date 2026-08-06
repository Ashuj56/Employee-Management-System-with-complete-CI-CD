variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "key_vault_name" { type = string }
variable "tenant_id" { type = string }
variable "object_id" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "tags" { type = map(string) }
