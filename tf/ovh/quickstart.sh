#!/usr/bin/env bash
set -euo pipefail

# Quickstart script for OVH Managed Kubernetes deployment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}OVH Managed Kubernetes - Quick Start${NC}\n"

# Check if tofu is installed
if ! command -v tofu &> /dev/null; then
    echo -e "${RED}Error: OpenTofu (tofu) is not installed${NC}"
    echo "Install from: https://opentofu.org/docs/intro/install/"
    exit 1
fi

# Check OVH credentials
if [[ -z "${OVH_APPLICATION_KEY:-}" ]] || [[ -z "${OVH_APPLICATION_SECRET:-}" ]] || [[ -z "${OVH_CONSUMER_KEY:-}" ]]; then
    echo -e "${YELLOW}Warning: OVH credentials not set${NC}"
    echo "Please set the following environment variables:"
    echo "  export OVH_ENDPOINT=ovh-eu"
    echo "  export OVH_APPLICATION_KEY=your_key"
    echo "  export OVH_APPLICATION_SECRET=your_secret"
    echo "  export OVH_CONSUMER_KEY=your_consumer_key"
    echo ""
    echo "Create credentials at: https://api.ovh.com/createToken/"
    exit 1
fi

# Check if terraform.tfvars exists
if [[ ! -f "terraform.tfvars" ]]; then
    echo -e "${YELLOW}Creating terraform.tfvars from example...${NC}"
    cp vars/example.tfvars terraform.tfvars
    echo -e "${RED}Please edit terraform.tfvars and set your OVH Project ID${NC}"
    echo "Then run: $0"
    exit 1
fi

# Parse command
COMMAND="${1:-apply}"

case "$COMMAND" in
    init)
        echo -e "${GREEN}Initializing Terraform...${NC}"
        tofu init
        ;;

    plan)
        echo -e "${GREEN}Planning deployment...${NC}"
        tofu plan
        ;;

    apply)
        echo -e "${GREEN}Deploying cluster...${NC}"
        tofu init -upgrade
        tofu apply
        echo -e "\n${GREEN}Deployment complete!${NC}"
        ;;

    kubeconfig)
        echo -e "${GREEN}Extracting kubeconfig...${NC}"
        tofu output -raw kubeconfig > kubeconfig.yaml
        export KUBECONFIG="$SCRIPT_DIR/kubeconfig.yaml"
        echo -e "${GREEN}Kubeconfig saved to: kubeconfig.yaml${NC}"
        echo -e "${YELLOW}Run: export KUBECONFIG=$SCRIPT_DIR/kubeconfig.yaml${NC}"
        kubectl get nodes 2>/dev/null || echo "Run: kubectl --kubeconfig=kubeconfig.yaml get nodes"
        ;;

    info)
        echo -e "${GREEN}Cluster Information:${NC}"
        echo "Cluster Name: $(tofu output -raw cluster_name)"
        echo "Cluster URL: $(tofu output -raw cluster_url)"
        echo "K8s Version: $(tofu output -raw cluster_version)"
        echo "Current Nodes: $(tofu output -raw current_nodes)"
        echo "Ingress IP: $(tofu output -raw ingress_ip)"
        ;;

    destroy)
        echo -e "${RED}Destroying cluster...${NC}"
        read -p "Are you sure? (yes/no): " confirm
        if [[ "$confirm" == "yes" ]]; then
            tofu destroy
            echo -e "${GREEN}Cluster destroyed${NC}"
        else
            echo "Cancelled"
        fi
        ;;

    *)
        echo "Usage: $0 {init|plan|apply|kubeconfig|info|destroy}"
        echo ""
        echo "Commands:"
        echo "  init        - Initialize Terraform"
        echo "  plan        - Show deployment plan"
        echo "  apply       - Deploy cluster (default)"
        echo "  kubeconfig  - Extract kubeconfig"
        echo "  info        - Show cluster information"
        echo "  destroy     - Destroy cluster"
        exit 1
        ;;
esac
