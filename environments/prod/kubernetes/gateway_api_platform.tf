data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

locals {
  eks_oidc_provider = replace(
    data.aws_eks_cluster.this.identity[0].oidc[0].issuer,
    "https://",
    ""
  )

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role" {
  statement {
    sid     = "AllowEksIrsa"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_provider}:sub"
      values = [
        "system:serviceaccount:${var.aws_load_balancer_controller_namespace}:${var.aws_load_balancer_controller_service_account_name}"
      ]
    }
  }
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = var.aws_load_balancer_controller_policy_name
  description = "Official AWS Load Balancer Controller ${var.aws_load_balancer_controller_version} IAM policy"
  policy = file(
    "${path.module}/policies/aws-load-balancer-controller-${var.aws_load_balancer_controller_version}.json"
  )

  tags = local.common_tags
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = var.aws_load_balancer_controller_role_name
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

resource "kubernetes_service_account_v1" "aws_load_balancer_controller" {
  metadata {
    name      = var.aws_load_balancer_controller_service_account_name
    namespace = var.aws_load_balancer_controller_namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
    }

    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }

  automount_service_account_token = true
}

resource "helm_release" "gateway_api_crds" {
  name      = var.gateway_api_helm_release_name
  namespace = var.aws_load_balancer_controller_namespace
  chart     = "${path.module}/charts/gateway-api-crds"
  version   = var.gateway_api_version

  atomic          = true
  cleanup_on_fail = true
  timeout         = 300
  wait            = true
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = var.aws_load_balancer_controller_namespace
  repository = var.aws_load_balancer_controller_chart_repository
  chart      = "aws-load-balancer-controller"
  version    = var.aws_load_balancer_controller_chart_version

  atomic          = true
  cleanup_on_fail = true
  timeout         = 600
  wait            = true

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.aws_region
      vpcId       = data.aws_eks_cluster.this.vpc_config[0].vpc_id

      image = {
        tag = var.aws_load_balancer_controller_version
      }

      serviceAccount = {
        create = false
        name   = var.aws_load_balancer_controller_service_account_name
      }

      controllerConfig = {
        featureGates = {
          ALBGatewayAPI = true
        }
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.aws_load_balancer_controller,
    helm_release.gateway_api_crds,
    kubernetes_service_account_v1.aws_load_balancer_controller
  ]
}
