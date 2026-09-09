variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the DEV VPC"
  type        = string
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
}

variable "eks_instance_types" {
  description = "EC2 instance types used by EKS nodes"
  type        = list(string)
}

variable "github_actions_role_arn" {
  description = "IAM role used by GitHub Actions"
  type        = string
}