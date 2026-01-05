provider google {
  region = var.gcp_region
  project = var.gcp_project_id
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "=4.63.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "=2.5.1"
    }
    random = {
      source = "hashicorp/random"
      version = "=3.5.1"
    }
  }
}
