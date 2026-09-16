variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "environment" {
  description = "Environment name used for resource tags"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource tags"
  type        = string
}

variable "gateway_api_version" {
  description = "Pinned Kubernetes Gateway API Standard channel release"
  type        = string
}

variable "gateway_api_helm_release_name" {
  description = "Helm release name for the vendored Gateway API Standard CRDs"
  type        = string
}

variable "aws_load_balancer_controller_version" {
  description = "Pinned AWS Load Balancer Controller application and IAM policy version"
  type        = string
}

variable "aws_load_balancer_controller_chart_version" {
  description = "Pinned official AWS Load Balancer Controller Helm chart version"
  type        = string
}

variable "aws_load_balancer_controller_chart_repository" {
  description = "Official AWS EKS Helm chart repository"
  type        = string
}

variable "aws_load_balancer_controller_namespace" {
  description = "Namespace for the AWS Load Balancer Controller"
  type        = string
}

variable "aws_load_balancer_controller_service_account_name" {
  description = "ServiceAccount name used by the AWS Load Balancer Controller"
  type        = string
}

variable "aws_load_balancer_controller_policy_name" {
  description = "Name of the least-privilege IAM policy for the AWS Load Balancer Controller"
  type        = string
}

variable "aws_load_balancer_controller_role_name" {
  description = "Name of the IRSA role for the AWS Load Balancer Controller"
  type        = string
}
