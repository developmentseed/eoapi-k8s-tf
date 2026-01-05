resource "helm_release" "labs-ingress-nginx" {
  name = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version = "4.8.1"
  namespace = "ingress-nginx"
  create_namespace = true

  set {
    name = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name = "controller.replicaCount"
    value = 1
  }

  set {
    name = "controller.service.loadBalancerIP"
    value = google_compute_address.static_ip.address
  }

}
