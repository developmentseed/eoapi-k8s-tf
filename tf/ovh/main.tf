terraform {
  required_version = ">= 1.7.4"

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.48"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "ovh" {
  endpoint = var.ovh_endpoint
}

# OVH Managed Kubernetes cluster
resource "ovh_cloud_project_kube" "cluster" {
  service_name    = var.service_name
  name            = var.cluster_name
  region          = var.region
  version         = var.kubernetes_version
  kube_proxy_mode = "ipvs"
  update_policy   = "ALWAYS_UPDATE"
}

# Node pool with autoscaling
resource "ovh_cloud_project_kube_nodepool" "workers" {
  service_name   = var.service_name
  kube_id        = ovh_cloud_project_kube.cluster.id
  name           = "workers"
  flavor_name    = var.node_flavor
  desired_nodes  = var.min_nodes
  min_nodes      = var.min_nodes
  max_nodes      = var.max_nodes
  autoscale      = true
  anti_affinity  = true
  monthly_billed = false

  lifecycle {
    ignore_changes = [desired_nodes]
  }
}

# Configure Kubernetes provider using kubeconfig_attributes
provider "kubernetes" {
  host                   = ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].host
  client_certificate     = base64decode(ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].client_certificate)
  client_key             = base64decode(ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].client_key)
  cluster_ca_certificate = base64decode(ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].cluster_ca_certificate)
}

# Configure Helm provider using kubeconfig_attributes
provider "helm" {
  kubernetes {
    host                   = ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].host
    client_certificate     = base64decode(ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].client_certificate)
    client_key             = base64decode(ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].client_key)
    cluster_ca_certificate = base64decode(ovh_cloud_project_kube.cluster.kubeconfig_attributes[0].cluster_ca_certificate)
  }
}

# Install nginx ingress controller
resource "helm_release" "ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = var.nginx_ingress_version

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  depends_on = [ovh_cloud_project_kube_nodepool.workers]
}
