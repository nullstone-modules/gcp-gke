locals {
  cluster_id             = google_container_cluster.primary.id
  cluster_name           = google_container_cluster.primary.name
  cluster_endpoint       = google_container_cluster.primary.endpoint
  cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

data "google_client_config" "provider" {}

provider "helm" {
  kubernetes {
    host                   = "https://${local.cluster_endpoint}"
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
  }
}

resource "helm_release" "gsm-external-secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "external-secrets"
}
