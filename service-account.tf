# Service account to manage cluster via IAM
resource "google_service_account" "cluster" {
  account_id   = local.resource_name
  display_name = "${local.resource_name} service account"

  depends_on = [google_project_service.iam]
}

resource "google_project_iam_member" "cluster_base" {
  project = local.project_id
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

# GKE security posture recommends this predefined role on the node service account
# ("Grant roles/container.defaultNodeServiceAccount ... for non-degraded operations").
# It bundles the minimum node permissions (logging, metrics, metadata, image pull).
resource "google_project_iam_member" "cluster_default_node" {
  project = local.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

resource "google_project_iam_member" "cluster_logging" {
  project = local.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

resource "google_project_iam_member" "cluster_metrics" {
  project = local.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

resource "google_project_iam_member" "cluster_registry_image_pull" {
  project = local.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}