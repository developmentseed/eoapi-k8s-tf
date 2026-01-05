variable "gcp_region" {
  default = "us-central1"
  description = "Google Cloud region"
}

variable "gcp_zone" {
  default = "us-central1-f"
  description = "Google Cloud zone"
}


variable "gcp_project_id" {
  type = string
  description = "Google Cloud project ID"
}

# GKE cluster

variable "gcp_default_machine_type" {
  description = "The machine type to use for the default node pool"
  type = string
  default = "n1-standard-1"
}

variable "gcp_node_image_type" {
  description = "The image type to use for the cluster nodes"
  type = string
  default = "ubuntu_containerd"
}

variable "gcp_disk_size_gb" {
  description = "The disk size to use for the cluster nodes"
  type = number
  default = 30
}

# -----------------
# Local variables

locals {
  stack_id              = "k8seed"
  prefix                = "${local.stack_id}-labs"
  cluster_name          = "${local.prefix}-cluster"
}
