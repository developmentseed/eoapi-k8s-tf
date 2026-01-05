# AWS Elastic Kubernetes Service (EKS)

OpenTofu/Terraform configuration for AWS EKS with autoscaling.

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **AWS Profile** set up with permissions for EKS, VPC, IAM, and S3
3. **OpenTofu** 1.11.0 or later installed via [tofuenv](https://github.com/tofuutils/tofuenv)

### Install OpenTofu

```bash
# Install tofuenv
# Follow: https://github.com/tofuutils/tofuenv

# Install OpenTofu 1.11.2+
tofuenv install 1.11.2
tofuenv use 1.11.2
```

## Deployment

### 1. Prepare Workspace

Choose a workspace name (e.g., `example-dev`) for your deployment:

```bash
cd tf/aws
```

### 2. Configure Remote State

Create backend configuration for storing Terraform state in S3:

```bash
cp backend-configs/example.tfbackend backend-configs/example-dev.tfbackend
# Edit backend-configs/example-dev.tfbackend with your S3 bucket details
```

In `backend-configs/example-dev.tfbackend`, set:
- `bucket` - Unique S3 bucket name for state storage
- `region` - AWS region for the bucket
- `key` - Leave as `terraform`

Create the S3 bucket:

```bash
aws s3 mb s3://your-bucket-name --region us-west-2
```

### 3. Initialize OpenTofu

```bash
AWS_PROFILE=your-profile tofu init -reconfigure -backend-config backend-configs/example-dev.tfbackend
AWS_PROFILE=your-profile tofu workspace new example-dev
```

### 4. Configure Variables

```bash
cp vars/example.tfvars vars/example-dev.tfvars
# Edit vars/example-dev.tfvars with your configuration
```

### 5. Deploy Infrastructure

```bash
AWS_PROFILE=your-profile tofu plan --var-file=vars/example-dev.tfvars
AWS_PROFILE=your-profile tofu apply --var-file=vars/example-dev.tfvars
```

### 6. Access Cluster

```bash
aws eks update-kubeconfig --name eoapi-v2 --region us-west-2 --profile your-profile
kubectl get nodes
```

### 7. Install eoAPI

Install the PostgreSQL operator:

```bash
helm upgrade --install \
  --set disable_check_for_upgrades=true pgo \
  oci://registry.developers.crunchydata.com/crunchydata/pgo \
  --version 5.7.4
```

Add the eoAPI helm repository:

```bash
helm repo add eoapi https://devseed.com/eoapi-k8s/
```

Get your current git SHA:

```bash
export GITSHA=$(git rev-parse HEAD | cut -c1-10)
```

Install eoAPI:

```bash
helm upgrade --install \
  --namespace eoapi \
  --create-namespace \
  --set gitSha=$GITSHA \
  eoapi eoapi/eoapi
```

## Configuration

### Essential Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `region` | AWS region | `us-west-2` |
| `cluster_name` | Cluster name (suffixed with cluster_version) | `eoapi` |
| `cluster_version` | Version suffix for cluster name | `v2` |
| `instance_type` | EC2 instance type | `t3.xlarge` |
| `enable_efs` | Enable EFS storage | `false` |
| `bucket_names` | S3 bucket names for data storage | `[]` |
| `prometheus_hostname` | Prometheus endpoint (optional) | `""` |

### Instance Types for Load Testing

| Instance Type | vCPU | RAM | Best For |
|---------------|------|-----|----------|
| `t3.large` | 2 | 8GB | Small workloads, dev/test |
| `t3.xlarge` | 4 | 16GB | Medium workloads |
| `t3.2xlarge` | 8 | 32GB | Large workloads |

## Troubleshooting

**Check cluster status:**
```bash
AWS_PROFILE=your-profile aws eks describe-cluster --name eoapi-v2 --region us-west-2
kubectl get nodes
```

**View autoscaling:**
```bash
kubectl top nodes
kubectl get nodes -o wide
```

**Update kubeconfig:**
```bash
aws eks update-kubeconfig --name eoapi-v2 --region us-west-2 --profile your-profile
```

## Cleanup

```bash
AWS_PROFILE=your-profile tofu destroy --var-file=vars/example-dev.tfvars
```

> **Warning:** This will permanently delete all resources. Ensure you have backups of any important data.

## Cost Optimization

- Start with `t3.xlarge` nodes for balanced performance
- Use spot instances for non-production workloads
- Enable cluster autoscaling to minimize idle costs
- Delete cluster when not in use: `tofu destroy`
- Review AWS Cost Explorer regularly