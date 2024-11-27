data "google_client_config" "this" {}
data "google_compute_zones" "available" {}
data "google_project" "this" {}

locals {
  project_id      = data.google_project.this.project_id
  region          = data.google_client_config.this.region
  available_zones = data.google_compute_zones.available.names
}

resource "google_project_service" "iam" {
  service                    = "iam.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "container" {
  service                    = "container.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}