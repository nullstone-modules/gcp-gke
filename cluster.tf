# GKE cluster
resource "google_container_cluster" "primary" {
  name                     = local.resource_name
  location                 = data.google_compute_zones.available.region
  initial_node_count       = 1
  remove_default_node_pool = true
  network                  = data.ns_connection.network.outputs.vpc_name
  subnetwork               = data.ns_connection.network.outputs.private_subnet_names[0]
}

# Service account to manage permission via IAM
resource "google_service_account" "default" {
  account_id   = local.resource_name
  display_name = "${local.resource_name} Service Account"
}

# Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name               = "${google_container_cluster.primary.name}-node-pool"
  location           = data.google_compute_zones.available.region
  cluster            = google_container_cluster.primary.name
  initial_node_count = 1

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # To avoid empty node pool while auto-scaling https://github.com/hashicorp/terraform-provider-google/issues/6901#issuecomment-667369691
  lifecycle {
    ignore_changes = [
      initial_node_count
    ]
  }
  node_config {
    machine_type    = var.node_machine_type
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = data.ns_workspace.this.tags

    tags = ["gke-node", "${local.resource_name}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
