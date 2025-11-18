# ==============================================================================
# Makefile for EKS Infrastructure Management
# ==============================================================================

.PHONY: help init plan apply destroy validate fmt check clean kubectl-config

# Default target
help: ## Show this help message
	@echo "EKS Infrastructure Management"
	@echo "============================="
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Terraform commands
init: ## Initialize Terraform
	terraform init

validate: ## Validate Terraform configuration
	terraform validate

fmt: ## Format Terraform files
	terraform fmt -recursive

plan: ## Create Terraform execution plan
	terraform plan

apply: ## Apply Terraform configuration
	terraform apply

destroy: ## Destroy Terraform-managed infrastructure
	terraform destroy

# Terraform checks
check: validate fmt ## Run validation and formatting checks

# Utility commands
clean: ## Clean up temporary files
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*

# Kubernetes commands
kubectl-config: ## Configure kubectl for the EKS cluster
	@echo "Configuring kubectl..."
	@aws eks --region $$(terraform output -raw aws_region 2>/dev/null || echo "us-west-2") \
		update-kubeconfig --name $$(terraform output -raw cluster_name)

nodes: kubectl-config ## Show cluster nodes
	kubectl get nodes

pods: kubectl-config ## Show all pods
	kubectl get pods --all-namespaces

# Development workflow
dev-deploy: init plan apply kubectl-config ## Complete development deployment
	@echo "Development deployment complete!"
	@echo "Cluster: $$(terraform output cluster_name)"
	@echo "Region: $$(terraform output aws_region)"

# Production workflow
prod-deploy: init validate plan ## Prepare for production deployment (manual apply required)
	@echo "Production deployment ready. Review the plan and run 'make apply' to proceed."

# Quick setup
setup: ## Setup development environment
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "Created terraform.tfvars from example. Please customize it."; \
	else \
		echo "terraform.tfvars already exists."; \
	fi

# Cost estimation (requires infracost)
cost: ## Estimate infrastructure costs (requires infracost)
	@command -v infracost >/dev/null 2>&1 || { echo "infracost not installed. Install from https://infracost.io/"; exit 1; }
	infracost breakdown --path .

# Security scanning (requires checkov)
security: ## Run security scan (requires checkov)
	@command -v checkov >/dev/null 2>&1 || { echo "checkov not installed. Install with: pip install checkov"; exit 1; }
	checkov -d .

# Documentation
docs: ## Generate Terraform documentation (requires terraform-docs)
	@command -v terraform-docs >/dev/null 2>&1 || { echo "terraform-docs not installed. Install from https://terraform-docs.io/"; exit 1; }
	terraform-docs markdown table --output-file TERRAFORM.md .

# All-in-one commands
full-check: validate fmt security ## Run all checks (validation, formatting, security)

deploy: setup init validate plan apply kubectl-config ## Complete deployment workflow

# Emergency commands
force-destroy: ## Force destroy all resources (use with caution)
	terraform destroy -auto-approve

force-unlock: ## Force unlock Terraform state (provide LOCK_ID)
	@read -p "Enter Lock ID: " lock_id; \
	terraform force-unlock $$lock_id