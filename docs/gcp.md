# Google Cloud Platform (GCP) Managed Kubernetes

OpenTofu/Terraform configuration for Google Kubernetes Engine (GKE) with autoscaling node pools.

## Prerequisites

1. **GCP Project**: Active Google Cloud Platform project
2. **gcloud CLI**: Install from [cloud.google.com/sdk/install](https://cloud.google.com/sdk/install)
3. **Authentication**: Set up credentials:
   ```bash
   gcloud auth application-default login
   gcloud config set project YOUR_PROJECT_ID
   ```

Useful information:
- [GKE documentation](https://cloud.google.com/kubernetes-engine/docs)
- [GCP authentication guide](https://cloud.google.com/docs/authentication/gcloud)

## Deployment

### 1. Configure Variables

```bash
cd tf/gcp
# Edit variables.tf or create terraform.tfvars
```

Required variables:
```hcl
gcp_project_id = "your-project-id"
gcp_region     = "us-central1"      # Optional, has default
gcp_zone       = "us-central1-f"    # Optional, has default
```

### 2. Deploy Infrastructure

```bash
tofu init
tofu apply
```

### 3. Access Cluster

```bash
gcloud container clusters get-credentials k8seed-labs-cluster \
  --zone=us-central1-f \
  --project=YOUR_PROJECT_ID

kubectl get nodes
```

### 4. Install eoAPI

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

### 5. Access Services

Get the ingress IP:

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

Configure DNS to point to the `EXTERNAL-IP`.

## Configuration

### Essential Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `gcp_project_id` | GCP Project ID | *required* |
| `gcp_region` | GCP region | `us-central1` |
| `gcp_zone` | GCP zone | `us-central1-f` |
| `gcp_node_image_type` | Node OS image | `ubuntu_containerd` |
| `gcp_disk_size_gb` | Node disk size | `30` |

### Node Pools

**Generic Pool** (1-6 nodes):
- Machine: `n1-standard-4` (4 vCPU, 15GB RAM)
- Purpose: General workloads, API services

**High-Memory Pool** (0-1 nodes):
- Machine: `n1-highmem-8` (8 vCPU, 52GB RAM)
- Purpose: Memory-intensive ingest jobs
- Taint: `only-highmem-jobs=true:NO_SCHEDULE`

### Machine Types

| Type | vCPU | RAM | Use Case |
|------|------|-----|----------|
| `n1-standard-2` | 2 | 7.5GB | Development |
| `n1-standard-4` | 4 | 15GB | Production |
| `n1-highmem-8` | 8 | 52GB | Data processing |

See [GCP machine types](https://cloud.google.com/compute/docs/machine-types) for more.

## Installed Components

- **cert-manager v1.19.2**: Automatic TLS certificates
- **ingress-nginx v4.14.1**: Load balancer and routing
- **Static IP**: For stable ingress access

## Remote State Backend (Optional)

Store state in Google Cloud Storage for team collaboration.

### 1. Create State Bucket

```bash
gcloud storage buckets create gs://your-tf-state-bucket \
  --location=US \
  --uniform-bucket-level-access
```

### 2. Configure Backend

Uncomment the backend block in `backend.tf`:

```hcl
terraform {
    backend "gcs" {
        bucket = "your-tf-state-bucket"
        prefix = "terraform/state/production"
    }
}
```

### 3. Migrate State

```bash
tofu init -migrate-state
```

## Troubleshooting

**Check cluster status:**
```bash
kubectl get nodes
kubectl top nodes
```

**Ingress not ready:**
```bash
kubectl get svc -n ingress-nginx
# Wait 2-3 minutes for EXTERNAL-IP to appear
```

**Authentication issues:**
```bash
gcloud auth application-default login
gcloud container clusters get-credentials k8seed-labs-cluster --zone=us-central1-f
```

## Cleanup

```bash
tofu destroy
```

Manual cleanup if needed:
```bash
gcloud container clusters delete k8seed-labs-cluster --zone=us-central1-f --quiet
```

## Cost Optimization

- **Development**: Use `n1-standard-2`, set `min_node_count = 0`, delete when idle
- **Production**: Use `n1-standard-4` or higher, enable autoscaling
- **Estimated costs** (us-central1):
  - n1-standard-4: ~$140/month per node
  - n1-highmem-8: ~$350/month per node

Use [GCP Pricing Calculator](https://cloud.google.com/products/calculator) for estimates.