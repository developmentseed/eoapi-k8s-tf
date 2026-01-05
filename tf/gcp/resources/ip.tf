resource "google_compute_address" "static_ip" {
  name = "ingress-nginx-static-ip"
  region = var.gcp_region
}
