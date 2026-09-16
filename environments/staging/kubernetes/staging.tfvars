aws_region   = "us-east-1"
cluster_name = "docket-staging"
environment  = "staging"
project_name = "Sintratel-Docket"

gateway_api_version           = "1.2.0"
gateway_api_helm_release_name = "gateway-api-crds"

aws_load_balancer_controller_version          = "v2.14.1"
aws_load_balancer_controller_chart_version    = "1.14.1"
aws_load_balancer_controller_chart_repository = "https://aws.github.io/eks-charts"

aws_load_balancer_controller_namespace            = "kube-system"
aws_load_balancer_controller_service_account_name = "aws-load-balancer-controller"
aws_load_balancer_controller_policy_name          = "AWSLoadBalancerControllerIAMPolicy-staging"
aws_load_balancer_controller_role_name            = "AmazonEKSLoadBalancerControllerRole-staging"
