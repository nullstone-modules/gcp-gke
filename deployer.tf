resource "google_service_account" "deployer" {
  account_id   = "deployer-${local.resource_name}"
  display_name = "Deployer for ${local.block_name}"
}

resource "google_service_account_key" "deployer" {
  service_account_id = google_service_account.deployer.account_id
}

resource "google_project_iam_binding" "deployer_developer_access" {
  project = data.google_compute_zones.available.project
  members = ["serviceAccount:${google_service_account.deployer.email}"]
  role    = "roles/container.developer"
}
