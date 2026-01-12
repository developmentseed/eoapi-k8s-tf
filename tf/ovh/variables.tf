variable "service_name" {
  description = "OVH Cloud Project ID (service name)"
  type        = string
}

variable "ovh_endpoint" {
  description = "OVH API endpoint (ovh-eu, ovh-ca, ovh-us)"
  type        = string
  default     = "ovh-eu"
}

variable "region" {
  description = "OVH region (GRA, SBG, BHS, WAW, etc.)"
  type        = string
  default     = "GRA"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "eoapi"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_flavor" {
  description = "OVH instance flavor for nodes (b2-7, b2-15, etc.)"
  type        = string
  default     = "b2-7"
}

variable "min_nodes" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 5
}

variable "nginx_ingress_version" {
  description = "Version of nginx ingress controller"
  type        = string
  default     = "4.8.3"
}

# Object Storage
variable "enable_object_storage" {
  description = "Enable S3-compatible object storage"
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "eoapi-data"
}

variable "bucket_region" {
  description = "Region for S3 bucket (e.g., 'DE', 'GRA')"
  type        = string
  default     = "DE"
}
