resource "google_service_account" "deployer" {
  account_id   = "deployer-${local.resource_name}"
  display_name = "Deployer for ${local.block_name}"
}

resource "google_service_account_key" "deployer" {
  service_account_id = google_service_account.deployer.account_id
}

resource "google_service_account_iam_member" "deployer_developer_access" {
  service_account_id = google_service_account.deployer.id
  member             = "serviceAccount:${google_service_account.deployer.email}"
  role               = "roles/container.developer"
}
