variable "aws_region" {
  description = "AWS region where the DEV infrastructure is deployed"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC/network"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability Zones used by the environment"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version used by EKS"
  type        = string
}

variable "eks_instance_types" {
  description = "EC2 instance types used by the EKS managed node group"
  type        = list(string)
}

variable "eks_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
}

variable "eks_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
}

variable "eks_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
}

variable "cluster_admin_user_arn" {
  description = "IAM user used for local EKS administration"
  type        = string
}

variable "github_actions_role_arn" {
  description = "IAM role used by GitHub Actions"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ecr_repositories" {
  description = "ECR repositories used by the microservices"

  type = map(object({
    image_tag_mutability = string
    scan_on_push         = bool
    encryption_type      = string
  }))
}