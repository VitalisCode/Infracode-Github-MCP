# EKS Infrastructure as Code

This repository contains Terraform configuration for deploying a production-ready Amazon EKS (Elastic Kubernetes Service) cluster on AWS, demonstrating Infrastructure as Code best practices and GitHub MCP integration.

## Architecture Overview

The infrastructure includes:
- **EKS Cluster**: Managed Kubernetes control plane
- **VPC**: Custom Virtual Private Cloud with public and private subnets across multiple AZs
- **Node Groups**: Managed worker nodes with auto-scaling capabilities
- **Security Groups**: Proper network security configuration
- **IAM Roles**: Service accounts and IRSA (IAM Roles for Service Accounts) setup
- **Add-ons**: Essential cluster add-ons like CoreDNS, VPC CNI, EBS CSI driver

## Features

- ✅ **Multi-AZ Deployment**: High availability across multiple availability zones
- ✅ **Managed Node Groups**: Auto-scaling worker nodes with configurable instance types
- ✅ **Security Best Practices**: Least privilege IAM roles and security groups
- ✅ **Add-ons Support**: Pre-configured essential cluster add-ons
- ✅ **Fargate Support**: Optional serverless container compute
- ✅ **Load Balancer Controller**: AWS Load Balancer Controller integration
- ✅ **Cluster Autoscaler**: Automatic node scaling based on workload demands
- ✅ **External DNS**: Optional Route53 DNS management
- ✅ **Cert Manager**: Optional SSL certificate management

## Prerequisites

Before deploying this infrastructure, ensure you have:

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** (>= 1.0) installed
3. **kubectl** installed for cluster management
4. Appropriate **IAM permissions** for EKS, VPC, and EC2 resources

### Required AWS Permissions

Your AWS credentials need permissions for:
- EKS cluster management
- VPC and subnet creation
- EC2 instance management
- IAM role and policy management
- Security group management

## Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/VitalisCode/Infracode-Github-MCP.git
   cd Infracode-Github-MCP
   ```

2. **Configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your desired configuration
   ```

3. **Initialize and deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Configure kubectl**:
   ```bash
   aws eks --region <your-region> update-kubeconfig --name <cluster-name>
   kubectl get nodes
   ```

## Configuration

### Core Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `project_name` | Name of the project | `"infracode-eks"` | No |
| `environment` | Environment (dev/staging/prod) | `"dev"` | No |
| `aws_region` | AWS region for deployment | `"us-west-2"` | No |
| `kubernetes_version` | Kubernetes version | `"1.28"` | No |

### Node Group Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `node_instance_types` | EC2 instance types for nodes | `["m5.large"]` |
| `node_group_min_size` | Minimum number of nodes | `1` |
| `node_group_max_size` | Maximum number of nodes | `3` |
| `node_group_desired_size` | Desired number of nodes | `2` |
| `node_capacity_type` | Capacity type (ON_DEMAND/SPOT) | `"ON_DEMAND"` |

### Network Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `single_nat_gateway` | Use single NAT gateway | `true` |
| `cluster_endpoint_public_access` | Enable public API access | `true` |

## Deployment Examples

### Development Environment
```hcl
project_name = "myapp-eks"
environment  = "dev"
aws_region   = "us-west-2"

node_instance_types     = ["t3.medium"]
node_group_desired_size = 1
single_nat_gateway     = true
```

### Production Environment
```hcl
project_name = "myapp-eks"
environment  = "prod"
aws_region   = "us-east-1"

kubernetes_version              = "1.28"
cluster_endpoint_public_access = false

node_instance_types     = ["m5.xlarge"]
node_group_min_size     = 2
node_group_max_size     = 10
node_group_desired_size = 3
single_nat_gateway     = false

enable_fargate      = true
enable_external_dns = true
enable_cert_manager = true
```

## Outputs

After deployment, the following outputs are available:

- `cluster_name`: EKS cluster name
- `cluster_endpoint`: Kubernetes API server endpoint
- `vpc_id`: VPC ID where cluster resides
- `kubectl_config_command`: Command to configure kubectl access

## Add-ons and Integrations

### AWS Load Balancer Controller
Automatically configured for ingress management with proper IAM roles.

### Cluster Autoscaler
Pre-configured IAM role for automatic node scaling based on pod requirements.

### EBS CSI Driver
Enabled by default for persistent volume support.

### Optional Add-ons
- **External DNS**: For Route53 DNS management
- **Cert Manager**: For SSL certificate automation
- **Fargate**: For serverless container workloads

## Security Considerations

- **Network Isolation**: Private subnets for worker nodes
- **IAM Least Privilege**: Minimal required permissions
- **Security Groups**: Restrictive network access rules
- **Encryption**: EKS secrets encryption at rest
- **Private API Access**: Configurable for production environments

## Monitoring and Logging

Consider enabling:
- **CloudWatch Container Insights** for monitoring
- **AWS CloudTrail** for API logging
- **VPC Flow Logs** for network monitoring
- **EKS Control Plane Logging** for audit trails

## Cost Optimization

- Use **Spot Instances** for non-critical workloads
- Enable **Cluster Autoscaler** for right-sizing
- Consider **Fargate** for variable workloads
- Use **single NAT gateway** for development environments

## Troubleshooting

### Common Issues

1. **Node group fails to join cluster**:
   - Check IAM roles and policies
   - Verify security group rules
   - Ensure subnets have proper routing

2. **Cannot access cluster**:
   - Run the kubectl config command from outputs
   - Check security group rules for API access
   - Verify IAM permissions

3. **Pods cannot reach internet**:
   - Check NAT gateway configuration
   - Verify route table associations
   - Ensure security groups allow egress

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

For issues and questions:
- Create an [Issue](https://github.com/VitalisCode/Infracode-Github-MCP/issues)
- Check the [Documentation](https://docs.aws.amazon.com/eks/)
- Review [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) docs

---

**Created by**: VitalisCode
**Maintained by**: Infrastructure Team
**Last Updated**: November 2025
