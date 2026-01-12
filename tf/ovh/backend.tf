# Remote State Backend (S3-compatible)
# Comment out to use local state instead
# Run: tofu init -backend-config=backend-configs/backend.tfbackend

terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://s3.${region}.io.cloud.ovh.net/"
    }
    key                         = "terraform.tfstate"
    bucket                      = ""
    region                      = ""
    access_key                  = ""
    secret_key                  = ""
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
  }
}