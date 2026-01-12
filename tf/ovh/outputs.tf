output "cluster_id" {
  description = "Kubernetes cluster ID"
  value       = ovh_cloud_project_kube.cluster.id
}

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = ovh_cloud_project_kube.cluster.name
}

output "cluster_url" {
  description = "Kubernetes API URL"
  value       = ovh_cloud_project_kube.cluster.url
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = ovh_cloud_project_kube.cluster.version
}

output "kubeconfig" {
  description = "Kubeconfig for cluster access"
  value       = ovh_cloud_project_kube.cluster.kubeconfig
  sensitive   = true
}

output "node_pool_id" {
  description = "Worker node pool ID"
  value       = ovh_cloud_project_kube_nodepool.workers.id
}

output "current_nodes" {
  description = "Current number of nodes"
  value       = ovh_cloud_project_kube_nodepool.workers.current_nodes
}

output "ingress_ip" {
  description = "Load balancer IP for ingress"
  value       = try(data.kubernetes_service.ingress.status[0].load_balancer[0].ingress[0].ip, "pending")
}

data "kubernetes_service" "ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [helm_release.ingress]
}

# S3 Object Storage Outputs
output "bucket_name" {
  description = "S3 bucket name"
  value       = var.enable_object_storage ? var.bucket_name : null
}

output "bucket_endpoint" {
  description = "S3 bucket endpoint"
  value       = var.enable_object_storage ? "https://s3.${var.bucket_region}.io.cloud.ovh.net" : null
}

output "bucket_access_key" {
  description = "S3 access key"
  value       = var.enable_object_storage ? ovh_cloud_project_user_s3_credential.bucket_credentials[0].access_key_id : null
}

output "bucket_secret_key" {
  description = "S3 secret key"
  value       = var.enable_object_storage ? ovh_cloud_project_user_s3_credential.bucket_credentials[0].secret_access_key : null
  sensitive   = true
}
