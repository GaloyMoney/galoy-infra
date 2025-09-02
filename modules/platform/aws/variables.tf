variable "name_prefix" {}

variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  default     = "1.30"
}

variable "node_default_type" {
  description = "Default EC2 instance type for worker nodes"
  default     = "m6a.large"
}

variable "min_default_node_count" {
  description = "Minimum number of nodes in the default node pool"
  default     = 1
}

variable "max_default_node_count" {
  description = "Maximum number of nodes in the default node pool"
  default     = 3
}

variable "eks_cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "eks_nodes_role_arn" {
  description = "ARN of the IAM role for the EKS worker nodes"
  type        = string
}

variable "nat_gateway_ids" {
  description = "List of NAT Gateway IDs for private subnets"
  type        = list(string)
}

variable "azs_cluster" {
  description = "Map of availability zones to CIDR blocks for cluster subnets"
  type        = map(string)
  default     = {
    "us-east-1a" = "10.0.20.0/24",
    "us-east-1b" = "10.0.21.0/24",
  }
}

variable "inception_state_backend" {
  description = "Backend configuration for inception state"
  type = object({
    bucket         = string
    key            = string
    region         = string
    dynamodb_table = string
  })
}   
