terraform {
    backend "gcs" {
        bucket = "tf-state-k8seed-labs"
        prefix = "terraform/state/production"
    }
}

# terraform {
#   backend "local" {
#     path = "staging.tfstate"
#     workspace_dir = "staging.tfstate.d"
#   }
# }
