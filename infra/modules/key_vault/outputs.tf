output "vault_uri" { value = azurerm_key_vault.this.vault_uri }
output "db_password_secret_id" { value = azurerm_key_vault_secret.db_password.id }
