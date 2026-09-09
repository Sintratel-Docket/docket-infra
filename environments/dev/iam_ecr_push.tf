data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  github_ecr_push_subjects = [
    for repo_name, repo_id in var.github_microservice_repositories :
    "repo:${var.github_organization}@${var.github_organization_id}/${repo_name}@${repo_id}:ref:refs/heads/${var.github_ecr_push_branch}"
  ]

  ecr_repository_arns = [
    for repository_name in keys(var.ecr_repositories) :
    "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${repository_name}"
  ]
}

data "aws_iam_policy_document" "github_ecr_push_assume_role" {
  statement {
    sid     = "GitHubActionsOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        data.aws_iam_openid_connect_provider.github_actions.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_ecr_push_subjects
    }
  }
}

resource "aws_iam_role" "github_ecr_push" {
  name               = var.github_ecr_push_role_name
  assume_role_policy = data.aws_iam_policy_document.github_ecr_push_assume_role.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "github_ecr_push" {
  statement {
    sid    = "ECRAuthorization"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PushImagesToProjectRepositories"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]

    resources = local.ecr_repository_arns
  }
}

resource "aws_iam_role_policy" "github_ecr_push" {
  name   = "${var.github_ecr_push_role_name}-policy"
  role   = aws_iam_role.github_ecr_push.id
  policy = data.aws_iam_policy_document.github_ecr_push.json
}