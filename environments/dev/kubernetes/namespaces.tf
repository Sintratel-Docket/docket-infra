resource "kubernetes_namespace_v1" "frontend" {
  metadata {
    name = "dev-frontend"

    labels = {
      environment = "dev"
      service     = "frontend"
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_namespace_v1" "auth_api" {
  metadata {
    name = "dev-auth-api"

    labels = {
      environment = "dev"
      service     = "auth-api"
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_namespace_v1" "users_api" {
  metadata {
    name = "dev-users-api"

    labels = {
      environment = "dev"
      service     = "users-api"
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_namespace_v1" "todos_api" {
  metadata {
    name = "dev-todos-api"

    labels = {
      environment = "dev"
      service     = "todos-api"
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_namespace_v1" "log_message_processor" {
  metadata {
    name = "dev-log-message-processor"

    labels = {
      environment = "dev"
      service     = "log-message-processor"
      managed-by  = "terraform"
    }
  }
}