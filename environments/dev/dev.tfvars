aws_region  = "us-east-1"
environment = "dev"

network_name = "docket-dev-vpc"

vpc_cidr = "10.10.0.0/16"

azs = [
  "us-east-1a",
  "us-east-1b"
]

private_subnets = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

public_subnets = [
  "10.10.101.0/24",
  "10.10.102.0/24"
]

cluster_name       = "docket-dev"
kubernetes_version = "1.35"

eks_instance_types = [
  "t3.small"
]

eks_min_size     = 1
eks_max_size     = 2
eks_desired_size = 1

cluster_admin_user_arn = "arn:aws:iam::429418377318:user/JuanP"

github_actions_role_arn = "arn:aws:iam::429418377318:role/GitHubActionsDocketInfra"

project_name = "Sintratel-Docket"

ecr_repositories = {

  "docket/frontend" = {
    image_tag_mutability = "IMMUTABLE"
    scan_on_push         = true
    encryption_type      = "AES256"
  }

  "docket/auth-api" = {
    image_tag_mutability = "IMMUTABLE"
    scan_on_push         = true
    encryption_type      = "AES256"
  }

  "docket/users-api" = {
    image_tag_mutability = "IMMUTABLE"
    scan_on_push         = true
    encryption_type      = "AES256"
  }

  "docket/todos-api" = {
    image_tag_mutability = "IMMUTABLE"
    scan_on_push         = true
    encryption_type      = "AES256"
  }

  "docket/log-message-processor" = {
    image_tag_mutability = "IMMUTABLE"
    scan_on_push         = true
    encryption_type      = "AES256"
  }
}