provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "git::https://github.com/Sintratel-Docket/terraform-modules.git//network?ref=v0.1.1"

  name        = var.network_name
  environment = var.environment

  vpc_cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "eks" {
  source = "git::https://github.com/Sintratel-Docket/terraform-modules.git//eks?ref=v0.3.1"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  environment = var.environment

  instance_types = var.eks_instance_types

  min_size     = var.eks_min_size
  max_size     = var.eks_max_size
  desired_size = var.eks_desired_size

  cluster_admin_user_arn  = var.cluster_admin_user_arn
  github_actions_role_arn = var.github_actions_role_arn
}

module "ecr" {
  source = "git::https://github.com/Sintratel-Docket/terraform-modules.git//ecr?ref=v0.4.0"

  environment  = var.environment
  project_name = var.project_name
  repositories = var.ecr_repositories
}