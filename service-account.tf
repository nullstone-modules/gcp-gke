# Service account to manage cluster via IAM
resource "google_service_account" "cluster" {
  account_id   = local.resource_name
  display_name = "${local.resource_name} service account"
}

resource "google_project_iam_member" "cluster_image_pull" {
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.cluster.email}"
  project = data.google_compute_zones.available.project
}
