# Google Kubernetes Engine (GKE)

Terraform configuration for GKE with autoscaling for load testing.

## Prerequisites

1. **Google Cloud Project** - With billing enabled
2. **gcloud CLI** - Configured with credentials ([install](https://cloud.google.com/sdk/docs/install))
3. **Terraform** - Version 1.7.4+ ([install with tfenv](https://github.com/tfutils/tfenv))

## Quick Start

### 1. Install Terraform

```bash
# Install tfenv
tfenv install 1.7.4
tfenv use 1.7.4
```

### 2. Authenticate with GCP

```bash
# Authenticate with your Google account
gcloud auth application-default login

# Set your project
gcloud config set project your-project-id
```

### 3. Configure Backend

```bash
cd terraform/gcp

# Choose a workspace name (e.g., example-dev)
cp backend-configs/example.tfbackend backend-configs/example-dev.tfbackend

# Edit backend-configs/example-dev.tfbackend:
# - Set unique bucket name
# - Leave prefix = terraform
```

### 4. Create GCS Backend

```bash
# Create the GCS bucket for terraform state
gsutil mb -l us-central1 gs://your-unique-bucket-name
```

### 5. Initialize Terraform

```bash
terraform init -reconfigure -backend-config backend-configs/example-dev.tfbackend
terraform workspace new example-dev
```

### 6. Configure Variables

```bash
cp vars/example.tfvars vars/example-dev.tfvars
# Edit vars/example-dev.tfvars with your configuration
```

### 7. Deploy

```bash
terraform plan --var-file=vars/example-dev.tfvars
terraform apply --var-file=vars/example-dev.tfvars
```

### 8. Get kubeconfig

```bash
gcloud container clusters get-credentials your-cluster-name --region your-region
kubectl get nodes
```

## Configuration

### Essential Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP project ID | *required* |
| `cluster_name` | GKE cluster name | `eoapi` |
| `region` | GCP region | `us-central1` |
| `machine_type` | Machine type | `e2-medium` |
| `min_nodes` | Minimum nodes | `1` |
| `max_nodes` | Maximum nodes (autoscaling) | `10` |
| `initial_nodes` | Initial node count | `2` |

### Machine Types for Load Testing

| Type | vCPU | RAM | Best For |
|------|------|-----|----------|
| `e2-medium` | 2 | 4GB | Small workloads, dev/test |
| `e2-standard-2` | 2 | 8GB | Medium workloads |
| `e2-standard-4` | 4 | 16GB | Large workloads |
| `n2-standard-2` | 2 | 8GB | Balanced compute |

## Features

- **GKE Autopilot/Standard** - Managed Kubernetes control plane
- **Autoscaling** - Nodes scale from `min_nodes` to `max_nodes`
- **VPC-native** - IP aliasing for efficient networking
- **Workload Identity** - Secure GCP service access from pods
- **Cloud Monitoring** - Integrated observability

## Outputs

```bash
terraform output cluster_name      # GKE cluster name
terraform output cluster_endpoint  # Kubernetes API URL
terraform output cluster_region    # GCP region
```

## Troubleshooting

**Check cluster status:**
```bash
gcloud container clusters describe your-cluster-name --region your-region
kubectl get nodes
```

**View autoscaling:**
```bash
kubectl top nodes
kubectl get nodes -o wide
```

**Authentication issues:**
```bash
gcloud container clusters get-credentials your-cluster-name --region your-region
```

## Cleanup

```bash
terraform destroy --var-file=vars/example-dev.tfvars
```

## Cost Optimization

- Start with `e2-medium` nodes (cost-effective)
- Set `min_nodes = 1` to minimize idle costs
- Autoscaling ensures you only pay for active nodes
- Delete cluster when not testing: `terraform destroy`
