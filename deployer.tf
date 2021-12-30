resource "google_service_account" "deployer" {
  account_id   = "deployer-${local.resource_name}"
  display_name = "Deployer for ${local.block_name}"
}

resource "google_service_account_key" "deployer" {
  service_account_id = google_service_account.deployer.account_id
}

// TODO: Add permissions to deploy services