provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "git::https://github.com/Sintratel-Docket/terraform-modules.git//network?ref=v0.1.1"

  name        = "docket-dev-vpc"
  environment = "dev"

  vpc_cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "eks" {
  source = "git::https://github.com/Sintratel-Docket/terraform-modules.git//eks?ref=v0.3.0"

  cluster_name       = "docket-dev"
  kubernetes_version = var.kubernetes_version

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  environment = "dev"

  instance_types = var.eks_instance_types

  min_size     = 1
  max_size     = 2
  desired_size = 1

  github_actions_role_arn = var.github_actions_role_arn
}