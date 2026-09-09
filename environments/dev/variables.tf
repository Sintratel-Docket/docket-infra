variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
}

variable "eks_instance_types" {
  description = "Instance types for the EKS nodes"
  type        = list(string)
}