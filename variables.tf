# ==============================================================================
# Input Variables for EKS Infrastructure
# ==============================================================================

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "infracode-eks"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

# EKS Cluster Configuration
variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

# Node Group Configuration
variable "node_instance_types" {
  description = "List of instance types for the EKS managed node group"
  type        = list(string)
  default     = ["m5.large"]
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the managed node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the managed node group"
  type        = number
  default     = 3
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the managed node group"
  type        = number
  default     = 2
}

variable "node_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
  type        = string
  default     = "AL2_x86_64"

  validation {
    condition = can(regex("^(AL2_x86_64|AL2_x86_64_GPU|AL2_ARM_64|CUSTOM|BOTTLEROCKET_ARM_64|BOTTLEROCKET_x86_64|BOTTLEROCKET_ARM_64_NVIDIA|BOTTLEROCKET_x86_64_NVIDIA|WINDOWS_CORE_2019_x86_64|WINDOWS_FULL_2019_x86_64|WINDOWS_CORE_2022_x86_64|WINDOWS_FULL_2022_x86_64)$", var.node_ami_type))
    error_message = "AMI type must be a valid EKS node group AMI type."
  }
}

variable "node_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition = can(regex("^(ON_DEMAND|SPOT)$", var.node_capacity_type))
    error_message = "Capacity type must be either ON_DEMAND or SPOT."
  }
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 20
}

# SSH Access Configuration
variable "enable_node_ssh_access" {
  description = "Enable SSH access to the worker nodes"
  type        = bool
  default     = false
}

variable "node_ssh_key_name" {
  description = "EC2 Key Pair name to allow SSH access to the worker nodes"
  type        = string
  default     = ""
}

# Network Configuration
variable "single_nat_gateway" {
  description = "Use a single shared NAT Gateway across all private subnets"
  type        = bool
  default     = true
}

variable "enable_workstation_access" {
  description = "Enable access from workstation to the cluster"
  type        = bool
  default     = false
}

variable "workstation_cidr_blocks" {
  description = "CIDR blocks from which to allow access to the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Fargate Configuration
variable "enable_fargate" {
  description = "Enable AWS Fargate profiles"
  type        = bool
  default     = false
}

# Add-ons Configuration
variable "enable_external_dns" {
  description = "Enable External DNS addon"
  type        = bool
  default     = false
}

variable "external_dns_hosted_zone_arns" {
  description = "Route53 hosted zone ARNs for External DNS"
  type        = list(string)
  default     = []
}

variable "enable_cert_manager" {
  description = "Enable Cert Manager addon"
  type        = bool
  default     = false
}

variable "cert_manager_hosted_zone_arns" {
  description = "Route53 hosted zone ARNs for Cert Manager"
  type        = list(string)
  default     = []
}

variable "enable_additional_policy" {
  description = "Enable additional IAM policy for custom use cases"
  type        = bool
  default     = false
}