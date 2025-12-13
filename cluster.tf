locals {
  // Select the zones to place the node pool
  // We choose from the list available zones in this region
  // We limit the zones chosen by var.num_node_zones (but this cannot be larger than the total available zones)
  zones = slice(local.available_zones, 0, min(var.num_node_zones, length(local.available_zones)))
}

resource "google_container_cluster" "primary" {
  name                     = local.resource_name
  location                 = data.google_compute_zones.available.region
  initial_node_count       = 1
  remove_default_node_pool = true
  networking_mode          = "VPC_NATIVE"
  network                  = local.vpc_name
  subnetwork               = local.private_subnet_names[0]

  deletion_protection = false

  ip_allocation_policy {}

  workload_identity_config {
    workload_pool = "${local.project_id}.svc.id.goog"
  }

  addons_config {
    gcs_fuse_csi_driver_config {
      enabled = true
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    gcp_filestore_csi_driver_config {
      enabled = true
    }
    config_connector_config {
      enabled = true
    }
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  depends_on = [google_project_service.container]
}

# Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name               = "${google_container_cluster.primary.name}-node-pool"
  location           = data.google_compute_zones.available.region
  cluster            = google_container_cluster.primary.name
  initial_node_count = 1

  node_locations = local.zones

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # To avoid empty node pool while auto-scaling https://github.com/hashicorp/terraform-provider-google/issues/6901#issuecomment-667369691
  lifecycle {
    ignore_changes = [initial_node_count]
  }

  node_config {
    machine_type    = var.node_machine_type
    service_account = google_service_account.cluster.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    labels          = local.tags
    tags            = ["gke-node", "${local.resource_name}-gke"]

    disk_size_gb = 50
    disk_type    = "pd-standard"

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
