# OVH Cloud Project ID (required)
# Find this in OVH Manager: Public Cloud > Projects
service_name = "your-ovh-service-name-id-here"

# Cluster configuration
cluster_name       = "eoapi"
region             = "DE1"
kubernetes_version = "1.34"

# Node configuration for load testing
node_flavor = "b2-7"  # 2 vCPU, 7GB RAM
min_nodes   = 1       # Minimum nodes (cost-efficient)
max_nodes   = 5       # Maximum nodes (autoscaling with anti-affinity)

# Ingress controller version
nginx_ingress_version = "4.14.1"

# Object Storage (required for eoapi data storage)
bucket_name           = "eoapi-data"
bucket_region         = "DE"
