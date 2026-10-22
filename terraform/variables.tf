variable "aws_region" {
  description = "AWS region for the capstone infrastructure"
  type        = string
  default     = "eu-north-1"
}

variable "expected_account_id" {
  description = "AWS account ID permitted for this deployment"
  type        = string
  default     = "895544788491"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "voting-capstone"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "cluster_admin_cidr" {
  description = "Public IPv4 CIDR permitted to access the Kubernetes API"
  type        = string
  default     = "102.90.99.138/32"
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS worker nodes"
  type        = list(string)
  default     = ["t3.small"]
}
