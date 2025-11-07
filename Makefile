# ==============================================================================
# Monitoring Stack Infrastructure Makefile
# ==============================================================================

.PHONY: help keys init-s3 deploy-s3 migrate-s3-backend deploy-monitoring-stack deploy-all
.PHONY: destroy-all destroy-monitoring-stack plan-s3 plan-monitoring-stack plan-all

# Variables
TFVARS := terraform.tfvars
STATE_CONFIG := state.config
S3_DIR := global/s3-state
MONITORING_DIR := staging/k8s-cluster
TFVARS_PATH := $(abspath $(TFVARS))
STATE_CONFIG_PATH := $(abspath $(STATE_CONFIG))

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# ==============================================================================
# Help Target
# ==============================================================================
.DEFAULT_GOAL := help

help:
	@echo "$(GREEN)Monitoring Stack Infrastructure Deployment$(NC)"
	@echo ""
	@echo "$(YELLOW)Infrastructure Targets:$(NC)"
	@echo "  make init-s3              - Initialize S3 backend (first time only)"
	@echo "  make deploy-s3            - Deploy S3 backend"
	@echo "  make migrate-s3-backend   - Migrate S3 backend state to S3"
	@echo "  make deploy-monitoring-stack - Deploy monitoring stack (4 Ubuntu VMs)"
	@echo "  make deploy-all           - Deploy everything at once (S3 + Monitoring Stack)"
	@echo ""
	@echo "$(YELLOW)Planning Targets:$(NC)"
	@echo "  make plan-s3              - Plan S3 backend changes"
	@echo "  make plan-monitoring-stack - Plan monitoring stack changes"
	@echo "  make plan-all             - Plan all infrastructure changes"
	@echo ""
	@echo "$(YELLOW)Destruction Targets:$(NC)"
	@echo "  make destroy-monitoring-stack - Destroy monitoring stack infrastructure"
	@echo "  make destroy-all              - Destroy all infrastructure"
	@echo ""
	@echo "$(YELLOW)Ansible Playbooks:$(NC)"
	@echo "  make setup-prometheus     - Setup Prometheus on prometheus node"
	@echo "  make setup-grafana        - Setup Grafana on grafana node"
	@echo "  make setup-loki           - Setup Loki on loki node"
	@echo "  make setup-all-services   - Setup all monitoring services"
	@echo ""
	@echo "$(YELLOW)Utility Targets:$(NC)"
	@echo "  make keys                 - Generate SSH key pair"
	@echo "  make inventory            - Generate Ansible inventory from Terraform outputs"
	@echo "  make clean                - Clean Terraform plan files and generated files"
	@echo ""
	@echo "$(YELLOW)Quick start (Complete Deployment):$(NC)"
	@echo "  1. make keys              - Generate SSH keys"
	@echo "  2. make deploy-all        - Deploy infrastructure (S3 + 4 VMs)"
	@echo "  3. make inventory         - Generate inventory from Terraform outputs"
	@echo "  4. make setup-all-services - Setup all monitoring services"

# ==============================================================================
# S3 Backend Setup
# ==============================================================================
init-s3:
	@echo "$(GREEN)Initializing S3 backend...$(NC)"
	@cd $(S3_DIR) && terraform init -input=false -backend-config=$(STATE_CONFIG_PATH)

deploy-s3:
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)Deploying S3 backend...$(NC)"
	@cd $(S3_DIR) && \
		terraform init -input=false -backend-config=$(STATE_CONFIG_PATH) && \
		terraform plan -input=false -compact-warnings -var-file=$(TFVARS_PATH) -out=tfplan && \
		terraform apply -input=false -auto-approve tfplan && \
		rm -f tfplan
	@echo "$(GREEN)✓ S3 backend deployed$(NC)"

migrate-s3-backend:
	@echo "$(GREEN)Migrating S3 backend state...$(NC)"
	@cd $(S3_DIR) && echo "yes" | terraform init -migrate-state -backend-config=$(STATE_CONFIG_PATH)
	@echo "$(GREEN)✓ S3 backend state migrated$(NC)"

plan-s3:
	@echo "$(YELLOW)Planning S3 backend changes...$(NC)"
	@cd $(S3_DIR) && \
		terraform init -input=false -backend-config=$(STATE_CONFIG_PATH) && \
		terraform plan -input=false -compact-warnings -var-file=$(TFVARS_PATH)

# ==============================================================================
# Infrastructure Deployment
# ==============================================================================
deploy-monitoring-stack:
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)Deploying Monitoring Stack (4 Ubuntu VMs)...$(NC)"
	@cd $(MONITORING_DIR) && \
		terraform init -input=false -backend-config=$(STATE_CONFIG_PATH)" && \
		terraform plan -input=false -compact-warnings -var-file=$(TFVARS_PATH) -out=tfplan && \
		terraform apply -input=false -auto-approve tfplan && \
		rm -f tfplan
	@echo "$(GREEN)✓ Monitoring stack deployed successfully$(NC)"
	@echo ""
	@echo "$(YELLOW)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(YELLOW)Monitoring Stack Information:$(NC)"
	@echo "$(YELLOW)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@cd $(MONITORING_DIR) && terraform output
	@echo ""
	@echo "$(BLUE)Next steps:$(NC)"
	@echo "  1. SSH to instances using the commands above"
	@echo "  2. Run setup scripts from vprofile-project directory:"
	@echo "     - prometheus-setup.sh on node 1"
	@echo "     - grafana-setup.sh on node 2"
	@echo "     - lokisetup.sh on node 3"
	@echo "  3. Access Grafana at: http://<grafana-ip>:3000"

deploy-all: deploy-s3 deploy-monitoring-stack
	@echo ""
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)🎉 Complete deployment finished!$(NC)"
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo ""
	@echo "$(BLUE)Next steps:$(NC)"
	@echo "  1. Run: make inventory (generates inventory from Terraform outputs)"
	@echo "  2. Run: make setup-all-services (installs Prometheus, Grafana, Loki)"
	@echo ""
	@echo "$(BLUE)To view instance details:$(NC)"
	@echo "  cd $(MONITORING_DIR) && terraform output"

plan-monitoring-stack:
	@echo "$(YELLOW)Planning monitoring stack changes...$(NC)"
	@cd $(MONITORING_DIR) && \
		terraform init -input=false -backend-config=$(STATE_CONFIG_PATH)" && \
		terraform plan -input=false -compact-warnings -var-file=$(TFVARS_PATH)

plan-all: plan-s3 plan-monitoring-stack
	@echo "$(GREEN)All infrastructure planning completed$(NC)"

# ==============================================================================
# Destruction Targets
# ==============================================================================
destroy-monitoring-stack:
	@echo "$(RED)Destroying monitoring stack infrastructure...$(NC)"
	@cd $(MONITORING_DIR) && \
		terraform init -input=false -backend-config=$(STATE_CONFIG_PATH)" && \
		terraform destroy -input=false -compact-warnings -var-file=$(TFVARS_PATH) -auto-approve
	@echo "$(GREEN)✓ Monitoring stack infrastructure destroyed$(NC)"

destroy-all: destroy-monitoring-stack
	@echo "$(GREEN)All infrastructure destroyed$(NC)"

# ==============================================================================
# SSH Keys and Inventory
# ==============================================================================
keys:
	@echo "$(GREEN)Generating SSH key pair...$(NC)"
	@./scripts/generate-keys.sh
	@echo "$(GREEN)✓ SSH keys generated$(NC)"

inventory:
	@echo "$(GREEN)Generating Ansible inventory from Terraform outputs...$(NC)"
	@./scripts/generate-inventory.sh
	@echo "$(GREEN)✓ Inventory generated$(NC)"

# ==============================================================================
# Ansible Playbooks
# ==============================================================================
setup-prometheus:
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)Setting up Prometheus...$(NC)"
	@ansible-playbook ansible/playbooks/prometheus.yml
	@echo "$(GREEN)✓ Prometheus setup completed$(NC)"

setup-grafana:
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)Setting up Grafana...$(NC)"
	@ansible-playbook ansible/playbooks/grafana.yml
	@echo "$(GREEN)✓ Grafana setup completed$(NC)"

setup-loki:
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)Setting up Loki...$(NC)"
	@ansible-playbook ansible/playbooks/loki.yml
	@echo "$(GREEN)✓ Loki setup completed$(NC)"

setup-all-services: setup-prometheus setup-grafana setup-loki
	@echo ""
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)🎉 All monitoring services setup completed!$(NC)"
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"

# ==============================================================================
# Cleanup
# ==============================================================================
clean:
	@echo "$(YELLOW)Cleaning Terraform plan files and generated files...$(NC)"
	@find . -name "tfplan" -type f -delete 2>/dev/null || true
	@find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".terraform.lock.hcl" -type f -delete 2>/dev/null || true
	@rm -f monitoring-key monitoring-key.pub
	@echo "$(GREEN)✓ Cleaned$(NC)"
