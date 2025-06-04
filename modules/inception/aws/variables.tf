variable "name_prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "backups_bucket_force_destroy" {
  description = "Allow destroy backups bucket"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "CIDR for the main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Public-subnet AZ ➜ CIDR map"
  type        = map(string)
  default     = {
    "us-east-1a" = "10.0.1.0/24"
  }
}

variable "azs_dmz" {
  description = "DMZ-subnet AZ ➜ CIDR map"
  type        = map(string)
  default     = {
    "us-east-1a" = "10.0.2.0/24"
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
}

variable "bastion_revoke_on_exit" {
  description = "Whether to revoke SSO session on bastion exit"
  type        = bool
  default     = false
}

variable "kubectl_version" {
  description = "Version of kubectl to install"
  type        = string
  default     = "1.28.0"
}

variable "k9s_version" {
  description = "Version of k9s to install"
  type        = string
  default     = "0.27.3"
}

variable "kratos_version" {
  description = "Version of kratos to install"
  type        = string
  default     = "1.0.0"
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t3.micro"
}

variable "users" {
  description = "List of users with access permissions"
  type = list(object({
    id        = string
    bastion   = bool
    inception = bool
    platform  = bool
    logs      = bool
  }))
  default = []
}


