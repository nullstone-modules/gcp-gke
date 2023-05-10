data "google_compute_zones" "available" {}

locals {
  project_id      = data.google_compute_zones.available.project
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