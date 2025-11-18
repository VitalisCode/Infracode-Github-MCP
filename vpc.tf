# ==============================================================================
# VPC and Networking Configuration for EKS
# ==============================================================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = var.single_nat_gateway

  # Enable DNS resolution and hostnames
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Public subnet configuration
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  # Private subnet configuration
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = merge(local.tags, {
    "kubernetes.io/cluster/${local.name}" = "shared"
  })
}

# ==============================================================================
# Security Groups
# ==============================================================================

# Additional security group for EKS worker nodes
resource "aws_security_group" "additional_worker_sg" {
  name_prefix = "${local.name}-worker-additional"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow pods to communicate with the cluster API Server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name}-worker-additional-sg"
  })
}