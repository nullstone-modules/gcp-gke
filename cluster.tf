locals {
  // Select the zones to place the node pool
  // We choose from the list available zones in this region
  // We limit the zones chosen by var.num_node_zones (but this cannot be larger than the total available zones)
  zones = slice(local.available_zones, 0, min(var.num_node_zones, length(local.available_zones)))

  // Default node pool name_prefix uses the workspace's random suffix (e.g., "abcde-blue-"). Used when
  // the caller does not pin an exact `name` via var.{blue,green}_node_pool.name. The `name` override
  // is the migration escape hatch — existing workspaces set it to the legacy pool's exact name to
  // keep the pool intact across the state move.
  default_blue_name_prefix  = "${random_string.resource_suffix.result}-blue-"
  default_green_name_prefix = "${random_string.resource_suffix.result}-green-"
}

resource "google_container_cluster" "primary" {
  name                     = local.resource_name
  resource_labels          = local.resource_labels
  location                 = data.google_compute_zones.available.region
  initial_node_count       = 1
  remove_default_node_pool = true
  networking_mode          = "VPC_NATIVE"
  network                  = local.vpc_name
  subnetwork               = local.private_subnet_names[0]

  deletion_protection = false

  datapath_provider = var.enable_dataplane_v2 ? "ADVANCED_DATAPATH" : null

  lifecycle {
    precondition {
      condition     = var.blue_node_pool.enabled || var.green_node_pool.enabled
      error_message = "At least one of blue_node_pool.enabled or green_node_pool.enabled must be true."
    }
  }

  ip_allocation_policy {}

  workload_identity_config {
    workload_pool = "${local.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_nodes = true
  }

  dynamic "network_policy" {
    // network_policy stanza cannot be specified when using Dataplane v2
    // It's implied to be enabled and Google will error
    for_each = var.enable_dataplane_v2 ? [] : [1]

    content {
      enabled  = true
      provider = "CALICO"
    }
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
    network_policy_config {
      disabled = var.enable_dataplane_v2 ? true : false
    }
  }

  # NOTE: This doesn't exist in the Terraform provider yet
  # observability_config {
  #   managed_otel = true
  # }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  depends_on = [google_project_service.container]
}

# Managed Node Pools
#
# The cluster runs two parallel node pools, `blue` and `green`, each independently toggleable
# via `var.blue_node_pool.enabled` and `var.green_node_pool.enabled`. This enables no-downtime
# rollouts of machine type / disk size changes via the blue/green swap pattern documented in the
# README. The `moved` block at the bottom of this file migrates the legacy `primary_nodes` state
# into `blue[0]`; existing workspaces should set `var.blue_node_pool.name` to the legacy pool's
# exact name to keep that pool intact (otherwise it gets replaced via create_before_destroy).

resource "google_container_node_pool" "blue" {
  count = var.blue_node_pool.enabled ? 1 : 0

  # When var.blue_node_pool.name is set, use that exact name (pinned). Otherwise, fall back to the
  # default name_prefix and let the provider append a unique suffix.
  name               = var.blue_node_pool.name
  name_prefix        = var.blue_node_pool.name == null ? local.default_blue_name_prefix : null
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
    create_before_destroy = true

    ignore_changes = [initial_node_count]

    precondition {
      condition     = var.blue_node_pool.name != null || length(local.default_blue_name_prefix) <= 14
      error_message = "Default blue node pool name_prefix '${local.default_blue_name_prefix}' is ${length(local.default_blue_name_prefix)} chars but GKE caps node pool names at 40 chars after the provider's 26-char unique suffix (max 14 for the prefix). Either rename your nullstone block or set var.blue_node_pool.name explicitly."
    }
  }

  node_config {
    machine_type    = var.blue_node_pool.machine_type
    service_account = google_service_account.cluster.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    labels          = local.tags
    resource_labels = local.resource_labels
    tags            = ["gke-node", "${local.resource_name}-gke"]

    disk_size_gb = var.blue_node_pool.disk_size
    disk_type    = "pd-standard"

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  network_config {
    enable_private_nodes = true
  }
}

resource "google_container_node_pool" "green" {
  count = var.green_node_pool.enabled ? 1 : 0

  name               = var.green_node_pool.name
  name_prefix        = var.green_node_pool.name == null ? local.default_green_name_prefix : null
  location           = data.google_compute_zones.available.region
  cluster            = google_container_cluster.primary.name
  initial_node_count = 1

  node_locations = local.zones

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  lifecycle {
    create_before_destroy = true

    ignore_changes = [initial_node_count]

    precondition {
      condition     = var.green_node_pool.name != null || length(local.default_green_name_prefix) <= 14
      error_message = "Default green node pool name_prefix '${local.default_green_name_prefix}' is ${length(local.default_green_name_prefix)} chars but GKE caps node pool names at 40 chars after the provider's 26-char unique suffix (max 14 for the prefix). Either rename your nullstone block or set var.green_node_pool.name explicitly."
    }
  }

  node_config {
    machine_type    = var.green_node_pool.machine_type
    service_account = google_service_account.cluster.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    labels          = local.tags
    resource_labels = local.resource_labels
    tags            = ["gke-node", "${local.resource_name}-gke"]

    disk_size_gb = var.green_node_pool.disk_size
    disk_type    = "pd-standard"

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  network_config {
    enable_private_nodes = true
  }
}

moved {
  from = google_container_node_pool.primary_nodes
  to   = google_container_node_pool.blue[0]
}
