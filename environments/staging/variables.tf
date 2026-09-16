variable "aws_region" {
  description = "AWS region where the staging infrastructure is deployed"
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

variable "additional_cluster_admin_principals" {
  description = "Additional IAM principals granted EKS cluster administrator access"
  type        = map(string)
  default     = {}
}

variable "github_actions_role_arn" {
  description = "IAM role used by GitHub Actions"
  type        = string
}

variable "eks_coredns_addon_version" {
  description = "Pinned CoreDNS EKS add-on version"
  type        = string
}

variable "eks_kube_proxy_addon_version" {
  description = "Pinned kube-proxy EKS add-on version"
  type        = string
}

variable "eks_vpc_cni_addon_version" {
  description = "Pinned VPC CNI EKS add-on version"
  type        = string
}

variable "eks_node_ami_release_version" {
  description = "Pinned EKS managed node AMI release"
  type        = string
}
