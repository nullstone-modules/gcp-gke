// TODO: Migrate to using built-in SecretsManager support from Google

locals {
  cluster_id             = google_container_cluster.primary.id
  cluster_name           = google_container_cluster.primary.name
  cluster_endpoint       = google_container_cluster.primary.endpoint
  cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  host                   = "https://${local.cluster_endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${local.cluster_endpoint}"
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
  }
}

locals {
  es_namespace = "external-secrets"
  es_ns_labels = {
    // k8s-recommended labels
    "app.kubernetes.io/name"       = "external-secrets"
    "app.kubernetes.io/part-of"    = local.stack_name
    "app.kubernetes.io/managed-by" = "nullstone"
    // nullstone labels
    "nullstone.io/stack" = local.stack_name
    "nullstone.io/block" = local.block_name
    "nullstone.io/env"   = local.env_name
  }
}

resource "kubernetes_namespace_v1" "external-secrets" {
  metadata {
    name   = local.es_namespace
    labels = local.es_ns_labels
  }

  depends_on = [google_container_node_pool.primary_nodes]
}

// We are going to configure the kubernetes cluster with a secrets store
// This secrets store will provide storage of secrets in google secrets manager instead of kubernetes storage
// We found two libraries to achieve:
//   - Secrets Store CSI Driver: https://secrets-store-csi-driver.sigs.k8s.io/
//   - External Secrets Operator (ESO): https://external-secrets.io/
// Secrets Store CSI Driver is mentioned by the Google Cloud docs; however, their documentation is poor with limited driver support
// ESO has extensive documentation, broad secret provider support, and generators (not used yet, but could be useful to teams)
resource "helm_release" "gsm-external-secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = local.es_namespace

  depends_on = [kubernetes_namespace_v1.external-secrets]
}
