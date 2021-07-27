# GKE cluster
resource "google_container_cluster" "primary" {
  name     = local.resource_name
  location = data.google_compute_zones.available.region

  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = data.ns_connection.network.outputs.vpc_name
  subnetwork               = data.ns_connection.network.outputs.public_subnet_names[0]
}

# Service account to manage permission via IAM
resource "google_service_account" "default" {
  account_id   = local.resource_name
  display_name = "${local.resource_name} Service Account"
}

# Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name     = "${google_container_cluster.primary.name}-node-pool"
  location = data.google_compute_zones.available.region
  cluster  = google_container_cluster.primary.name

  node_count = var.node_count

  node_config {
    machine_type    = var.node_machine_type
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = data.google_compute_zones.available.project
    }

    tags = ["gke-node", "${data.google_compute_zones.available.project}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
