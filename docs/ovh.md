# OVHcloud Managed Kubernetes

OpenTofu/Terraform configuration for OVH Managed Kubernetes with autoscaling.

## Prerequisites

1. Get your **Service name ID** from [OVH Manager](https://www.ovh.com/manager/) → Public Cloud section
2. Generate **API credentials** at `https://www.ovh.com/auth/api/createToken?GET=/*&POST=/*&PUT=/*&DELETE=/*` with these rights:
   - `GET`, `POST`, `PUT`, `DELETE` for `/cloud/project/<service_name_id>/*`
3. Save credentials to `ovh-creds.sh`:

```bash
export OVH_APPLICATION_KEY=your_app_key
export OVH_APPLICATION_SECRET=your_app_secret
export OVH_CONSUMER_KEY=your_consumer_key
```

Useful information:
- [OVH API documentation](https://help.ovhcloud.com/csm/en-api-getting-started-ovhcloud-api?id=kb_article_view&sysparm_article=KB0042777)
- [OVH Managed Kubernetes documentation](https://help.ovhcloud.com/csm/en-public-cloud-kubernetes-create-cluster?id=kb_article_view&sysparm_article=KB0049685)

## Deployment

### Quick Start

```bash
cd tf/ovh
cp vars/example.tfvars terraform.tfvars
# Edit terraform.tfvars with your configuration
source ../../../ovh-creds.sh
./quickstart.sh apply
```

The quickstart script handles init, plan, and apply. See `./quickstart.sh` for more commands.

### Manual Deployment

#### 1. Configure Variables

```bash
cd tf/ovh
cp vars/example.tfvars vars/testing.tfvars
# Edit vars/testing.tfvars with your configuration
```

#### 2. Deploy Infrastructure

```bash
source ../../../ovh-creds.sh
tofu init
tofu plan --var-file=vars/testing.tfvars
tofu apply --var-file=vars/testing.tfvars
```

#### 3. Access Cluster

```bash
tofu output -raw kubeconfig > kubeconfig.yaml
export KUBECONFIG=$(pwd)/kubeconfig.yaml
kubectl get nodes
```

#### 4. Install eoAPI

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

Install eoAPI with S3 configuration:

```bash
helm upgrade --install \
  --namespace eoapi \
  --create-namespace \
  --set gitSha=$GITSHA \
  --set raster.settings.envVars.AWS_ACCESS_KEY_ID=$(tofu output -raw bucket_access_key) \
  --set raster.settings.envVars.AWS_SECRET_ACCESS_KEY=$(tofu output -raw bucket_secret_key) \
  --set raster.settings.envVars.AWS_S3_ENDPOINT=$(tofu output -raw bucket_endpoint | sed 's|https://||') \
  --set raster.settings.envVars.AWS_VIRTUAL_HOSTING="FALSE" \
  eoapi eoapi/eoapi
```

> **Note:** If you disabled object storage (`enable_object_storage = false`), omit the S3-related `--set` flags.

### 5. Get Outputs

```bash
tofu output cluster_url             # Kubernetes API URL
tofu output ingress_ip              # LoadBalancer IP for DNS/apps
tofu output current_nodes           # Active node count
tofu output bucket_access_key       # S3 access key
tofu output -raw bucket_secret_key  # S3 secret key (use -raw to avoid quotes)
tofu output bucket_endpoint         # S3 endpoint URL
```

## Configuration

### Essential Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `service_name` | OVH Cloud Project ID | *required* |
| `cluster_name` | Cluster name | `eoapi` |
| `region` | OVH region (GRA, SBG, BHS, WAW, etc.) | `GRA` |
| `node_flavor` | Instance type | `b2-7` |
| `min_nodes` | Minimum nodes | `1` |
| `max_nodes` | Maximum nodes (≤5 with anti-affinity) | `5` |
| `bucket_name` | S3 bucket name | `eoapi-data` |
| `bucket_region` | S3 bucket region | `DE` |

### Instance Flavors for Load Testing

| Flavor | vCPU | RAM | Best For |
|--------|------|-----|----------|
| `b2-7` | 2 | 7GB | Small workloads, dev/test |
| `b2-15` | 4 | 15GB | Medium workloads |
| `b2-30` | 8 | 30GB | Large workloads |

## S3 Object Storage

S3-compatible object storage is **enabled by default** for storing eoapi data. See the "Get Outputs" section above for credentials.

### Disable Storage

For minimal test deployments without storage:

```hcl
enable_object_storage = false
```

## Remote State Backend

Store Terraform state in OVH Object Storage for team collaboration.

### 1. Create State Bucket

Create a bucket for state storage (via OVH console or separate run).

### 2. Configure Backend

```bash
cp backend-configs/example.tfbackend backend-configs/backend.tfbackend
# Edit backend-configs/backend.tfbackend with your bucket details
```

### 3. Initialize with Backend

```bash
tofu init -backend-config=backend-configs/backend.tfbackend
```

### Local State (Optional)

To use local state instead, comment out the backend block in `backend.tf` and run:

```bash
tofu init -migrate-state
```

## Troubleshooting

**Check cluster status:**
```bash
tofu output cluster_version
kubectl get nodes
```

**View autoscaling:**
```bash
kubectl top nodes
kubectl get nodes -o wide
```

**Ingress not ready:**
```bash
kubectl get svc -n ingress-nginx
# Wait for EXTERNAL-IP to appear
```

## Cleanup

```bash
tofu destroy --var-file=vars/example-dev.tfvars
```

## Cost Optimization

- Start with `b2-7` nodes (cost-effective)
- Set `min_nodes = 1` to minimize idle costs
- Autoscaling ensures you only pay for active nodes
- Delete cluster when not testing: `tofu destroy`
