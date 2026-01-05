# OVH Object Storage Configuration
# Note: OVH Object Storage containers are created automatically when you first upload
# objects using S3 credentials. There is no Terraform resource to pre-create containers.
# The container will be created on first use with the bucket_name specified in variables.

# User for bucket access
resource "ovh_cloud_project_user" "bucket_user" {
  count = var.enable_object_storage ? 1 : 0

  service_name = var.service_name
  description  = "${var.bucket_name}-user"
  role_name    = "objectstore_operator"
}

# S3 credentials for the user
resource "ovh_cloud_project_user_s3_credential" "bucket_credentials" {
  count = var.enable_object_storage ? 1 : 0

  service_name = var.service_name
  user_id      = ovh_cloud_project_user.bucket_user[0].id
}

# S3 access policy
resource "ovh_cloud_project_user_s3_policy" "bucket_policy" {
  count = var.enable_object_storage ? 1 : 0

  service_name = var.service_name
  user_id      = ovh_cloud_project_user.bucket_user[0].id
  policy = jsonencode({
    Statement = [{
      Sid    = "BucketAccess"
      Effect = "Allow"
      Action = ["s3:*"]
      Resource = [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }]
  })
}
