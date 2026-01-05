resource "helm_release" "labs-cert-manager" {
  name = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  version = "v1.11.0"
  namespace = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}
