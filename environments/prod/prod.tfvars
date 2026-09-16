aws_region  = "us-east-1"
environment = "prod"

network_name = "docket-prod-vpc"

vpc_cidr = "10.30.0.0/16"

azs = [
  "us-east-1a",
  "us-east-1b"
]

private_subnets = [
  "10.30.1.0/24",
  "10.30.2.0/24"
]

public_subnets = [
  "10.30.101.0/24",
  "10.30.102.0/24"
]

cluster_name       = "docket-prod"
kubernetes_version = "1.35"

eks_instance_types = [
  "t3.small"
]

eks_min_size     = 2
eks_max_size     = 2
eks_desired_size = 2

cluster_admin_user_arn = "arn:aws:iam::429418377318:user/JuanP"

github_actions_role_arn = "arn:aws:iam::429418377318:role/GitHubActionsDocketInfra"
