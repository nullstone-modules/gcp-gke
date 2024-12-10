# Service account to manage cluster via IAM
resource "google_service_account" "cluster" {
  account_id   = local.resource_name
  display_name = "${local.resource_name} service account"

  depends_on = [google_project_service.iam]
}

resource "google_project_iam_member" "cluster_base" {
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${google_service_account.cluster.email}"
  project = local.project_id
}

resource "google_project_iam_member" "cluster_registry_image_pull" {
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.cluster.email}"
  project = local.project_id
}