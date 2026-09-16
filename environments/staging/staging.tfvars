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

eks_coredns_addon_version    = "v1.14.3-eksbuild.16"
eks_kube_proxy_addon_version = "v1.35.3-eksbuild.25"
eks_vpc_cni_addon_version    = "v1.23.1-eksbuild.1"
eks_node_ami_release_version = "1.35.7-20260903"

cluster_admin_user_arn = "arn:aws:iam::429418377318:user/JuanP"

additional_cluster_admin_principals = {
  karen = "arn:aws:iam::429418377318:user/Karen"
}

github_actions_role_arn = "arn:aws:iam::429418377318:role/GitHubActionsDocketInfra"
