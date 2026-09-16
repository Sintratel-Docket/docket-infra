output "gateway_api_version" {
  description = "Installed Kubernetes Gateway API Standard channel version"
  value       = var.gateway_api_version
}

output "aws_load_balancer_controller_version" {
  description = "Installed AWS Load Balancer Controller application version"
  value       = var.aws_load_balancer_controller_version
}

output "aws_load_balancer_controller_chart_version" {
  description = "Installed AWS Load Balancer Controller Helm chart version"
  value       = var.aws_load_balancer_controller_chart_version
}

output "aws_load_balancer_controller_policy_arn" {
  description = "IAM policy ARN for the AWS Load Balancer Controller"
  value       = aws_iam_policy.aws_load_balancer_controller.arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role ARN for the AWS Load Balancer Controller"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}
