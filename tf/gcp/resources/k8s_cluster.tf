resource "google_container_cluster" "primary" {
  name = local.cluster_name
  location = var.gcp_zone
  initial_node_count = 1
  remove_default_node_pool = true
  
  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }
}

resource "google_container_node_pool" "generic_node_pool" {
  name       = "generic-node-pool"
  location   = var.gcp_zone
  cluster    = local.cluster_name

  node_config {
    preemptible  = false
    machine_type = "n1-standard-4"
    image_type = var.gcp_node_image_type
    disk_size_gb = var.gcp_disk_size_gb

    labels = {
      "generic" = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 6
  }
}

resource "google_container_node_pool" "highmem_node_pool" {
  name       = "highmem-node-pool"
  location   = var.gcp_zone
  cluster    = local.cluster_name

  node_config {
    preemptible  = false
    machine_type = "n1-highmem-8"
    image_type = var.gcp_node_image_type
    disk_size_gb = 100

    labels = {
      "ingest" = "true"
      "highmem" = "true"
    }

    taint {
      key = "only-highmem-jobs"
      value = "true"
      effect = "NO_SCHEDULE"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 1
  }
}
