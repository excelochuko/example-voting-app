terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_account_id" {
  description = "AWS account dedicated to the capstone"
  type        = string
  default     = "325774504351"
}

variable "aws_region" {
  description = "AWS region for the capstone"
  type        = string
  default     = "eu-north-1"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "excelochuko"
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID used in the OIDC subject"
  type        = string
  default     = "308782014"
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
  default     = "example-voting-app"
}

variable "github_repository_id" {
  description = "Immutable GitHub repository ID used in the OIDC subject"
  type        = string
  default     = "1421366762"
}

variable "github_branch" {
  description = "Branch allowed to deploy"
  type        = string
  default     = "capstone/security-hardening"
}

variable "cluster_name" {
  description = "EKS cluster the deployment role may describe"
  type        = string
  default     = "voting-capstone"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1b511abead59c6ce207077c0bf0e0043b1382612"
  ]

  tags = {
    Project   = "voting-capstone"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  name = "voting-capstone-github-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repository}@${var.github_repository_id}:ref:refs/heads/${var.github_branch}"
        }
      }
    }]
  })

  tags = {
    Project   = "voting-capstone"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy" "eks_describe" {
  name = "voting-capstone-eks-describe"
  role = aws_iam_role.github_actions_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "eks:DescribeCluster",
        "eks:UpdateClusterConfig",
      ]
      Resource = "arn:aws:eks:${var.aws_region}:${var.aws_account_id}:cluster/${var.cluster_name}"
    }]
  })
}

output "github_actions_role_arn" {
  description = "Role ARN to configure for GitHub Actions"
  value       = aws_iam_role.github_actions_deploy.arn
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}
