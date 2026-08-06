# ─────────────────────────────────────────────────────────────────────────────
# modules/acr/main.tf
# Creates the Azure Container Registry and assigns AcrPull to the AKS
# kubelet managed identity so the cluster can pull images without credentials.
# ─────────────────────────────────────────────────────────────────────────────

resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false   # Use managed identity — no admin username/password

  tags = var.tags
}

# ── Role assignment: AKS kubelet identity → AcrPull ─────────────────────────
# Only create when the kubelet identity is provided (avoids chicken-and-egg
# issue on the very first apply — re-run after AKS is created if needed).
resource "azurerm_role_assignment" "aks_acr_pull" {
  count = var.aks_kubelet_identity != "" ? 1 : 0

  principal_id         = var.aks_kubelet_identity
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.this.id
}
