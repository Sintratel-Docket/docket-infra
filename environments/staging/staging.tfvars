aws_region  = "us-east-1"
environment = "staging"

network_name = "docket-staging-vpc"

vpc_cidr = "10.20.0.0/16"

azs = [
  "us-east-1a",
  "us-east-1b"
]

private_subnets = [
  "10.20.1.0/24",
  "10.20.2.0/24"
]

public_subnets = [
  "10.20.101.0/24",
  "10.20.102.0/24"
]

cluster_name       = "docket-staging"
kubernetes_version = "1.35"

eks_instance_types = [
  "t3.small"
]

eks_min_size     = 2
eks_max_size     = 2
eks_desired_size = 2

cluster_admin_user_arn = "arn:aws:iam::429418377318:user/JuanP"

github_actions_role_arn = "arn:aws:iam::429418377318:role/GitHubActionsDocketInfra"
