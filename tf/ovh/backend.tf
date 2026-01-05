# Remote State Backend (S3-compatible)
# Uncomment to enable remote state storage in OVH Object Storage
# Run: tofu init -backend-config=vars/backend.tfvars

# terraform {
#   backend "s3" {
#     endpoints = {
#       s3 = "https://s3.${region}.io.cloud.ovh.net/"
#     }
#     key                         = "terraform.tfstate"
#     bucket                      = ""
#     region                      = ""
#     access_key                  = ""
#     secret_key                  = ""
#     skip_credentials_validation = true
#     skip_region_validation      = true
#     skip_metadata_api_check     = true
#     skip_requesting_account_id  = true
#   }
# }
