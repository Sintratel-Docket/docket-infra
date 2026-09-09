output "vpc_id" {
  value = module.network.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  value = module.eks.cluster_version
}

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "github_ecr_push_role_arn" {
  description = "IAM role ARN used by microservice GitHub Actions workflows to push images to ECR"
  value       = aws_iam_role.github_ecr_push.arn
}