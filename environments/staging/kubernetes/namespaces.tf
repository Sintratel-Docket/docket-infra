locals {
  services = toset([
    "frontend",
    "auth-api",
    "users-api",
    "todos-api",
    "log-message-processor"
  ])
}

resource "kubernetes_namespace_v1" "services" {
  for_each = local.services

  metadata {
    name = "${var.environment}-${each.value}"

    labels = {
      environment = var.environment
      service     = each.value
      managed-by  = "terraform"
    }
  }
}
