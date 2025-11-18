# ==============================================================================
# EKS Cluster Configuration
# ==============================================================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name    = local.name
  cluster_version = var.kubernetes_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    main = {
      name = "${local.name}-main"

      instance_types = var.node_instance_types

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      ami_type                   = var.node_ami_type
      capacity_type              = var.node_capacity_type
      disk_size                  = var.node_disk_size
      force_update_version       = false
      use_custom_launch_template = false

      # Remote access cannot be specified with a launch template
      remote_access = var.enable_node_ssh_access ? {
        ec2_ssh_key               = var.node_ssh_key_name
        source_security_group_ids = [aws_security_group.additional_worker_sg.id]
      } : {}

      labels = {
        Environment = var.environment
        Project     = var.project_name
      }

      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      description = "EKS managed node group for ${local.name}"

      tags = local.tags
    }
  }

  # Fargate Profile (optional)
  fargate_profiles = var.enable_fargate ? {
    default = {
      name = "${local.name}-fargate"
      selectors = [
        {
          namespace = "fargate"
        }
      ]

      tags = merge(local.tags, {
        Name = "${local.name}-fargate-profile"
      })
    }
  } : {}

  tags = local.tags
}

# ==============================================================================
# EKS Cluster Security Group Rules
# ==============================================================================

# Allow communication between the cluster and worker nodes
resource "aws_security_group_rule" "cluster_ingress_workstation_https" {
  count = var.enable_workstation_access ? 1 : 0

  description       = "Allow workstation to communicate with the cluster API Server"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.workstation_cidr_blocks
  security_group_id = module.eks.cluster_security_group_id
}

# ==============================================================================
# AWS Load Balancer Controller IAM Role
# ==============================================================================

module "aws_load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.name}-aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = local.tags
}