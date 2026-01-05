# AWS Elastic Kubernetes Service (EKS)

Terraform configuration for AWS EKS with autoscaling for load testing.

## Prerequisites

1. **AWS Account** - With appropriate permissions for EKS, VPC, and IAM
2. **AWS CLI** - Configured with credentials ([install](https://aws.amazon.com/cli/))
3. **Terraform** - Version 1.7.4+ ([install with tfenv](https://github.com/tfutils/tfenv))

## Quick Start

### 1. Install Terraform

```bash
# Install tfenv
tfenv install 1.7.4
tfenv use 1.7.4
```

### 2. Configure Backend

```bash
cd terraform/aws

# Choose a workspace name (e.g., example-dev)
cp backend-configs/example.tfbackend backend-configs/example-dev.tfbackend

# Edit backend-configs/example-dev.tfbackend:
# - Set unique bucket name
# - Choose AWS region
# - Leave key = terraform
```

### 3. Create S3 Backend

```bash
# Create the S3 bucket for terraform state
aws s3 mb s3://your-unique-bucket-name --region us-east-1
```

### 4. Initialize Terraform

```bash
AWS_PROFILE=your-profile terraform init -reconfigure -backend-config backend-configs/example-dev.tfbackend
AWS_PROFILE=your-profile terraform workspace new example-dev
```

### 5. Configure Variables

```bash
cp vars/example.tfvars vars/example-dev.tfvars
# Edit vars/example-dev.tfvars with your configuration
```

### 6. Deploy

```bash
AWS_PROFILE=your-profile terraform plan --var-file=vars/example-dev.tfvars
AWS_PROFILE=your-profile terraform apply --var-file=vars/example-dev.tfvars
```

### 7. Get kubeconfig

```bash
aws eks update-kubeconfig --name your-cluster-name --region your-region --profile your-profile
kubectl get nodes
```

## Configuration

### Essential Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `cluster_name` | EKS cluster name | `eoapi` |
| `region` | AWS region | `us-east-1` |
| `instance_type` | EC2 instance type | `t3.medium` |
| `min_nodes` | Minimum nodes | `1` |
| `max_nodes` | Maximum nodes (autoscaling) | `10` |
| `desired_nodes` | Initial node count | `2` |

### Instance Types for Load Testing

| Type | vCPU | RAM | Best For |
|------|------|-----|----------|
| `t3.medium` | 2 | 4GB | Small workloads, dev/test |
| `t3.large` | 2 | 8GB | Medium workloads |
| `t3.xlarge` | 4 | 16GB | Large workloads |
| `m5.large` | 2 | 8GB | Balanced compute |

## Features

- **AWS EKS** - Managed Kubernetes control plane
- **Autoscaling** - Nodes scale from `min_nodes` to `max_nodes`
- **VPC** - Isolated network with public/private subnets
- **IAM Integration** - IRSA for pod-level permissions
- **Container Insights** - CloudWatch monitoring (optional)

## Outputs

```bash
terraform output cluster_name      # EKS cluster name
terraform output cluster_endpoint  # Kubernetes API URL
terraform output cluster_region    # AWS region
```

## Troubleshooting

**Check cluster status:**
```bash
AWS_PROFILE=your-profile aws eks describe-cluster --name your-cluster-name --region your-region
kubectl get nodes
```

**View autoscaling:**
```bash
kubectl top nodes
kubectl get nodes -o wide
```

**Authentication issues:**
```bash
aws eks update-kubeconfig --name your-cluster-name --region your-region --profile your-profile
```

## Cleanup

```bash
AWS_PROFILE=your-profile terraform destroy --var-file=vars/example-dev.tfvars
```

## Cost Optimization

- Start with `t3.medium` nodes (cost-effective)
- Set `min_nodes = 1` to minimize idle costs
- Autoscaling ensures you only pay for active nodes
- Delete cluster when not testing: `terraform destroy`
