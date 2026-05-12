variable "min_node_count" {
  type        = number
  description = "Minimum number of nodes per zone in the GKE NodePool."
  default     = 1
}

variable "max_node_count" {
  type        = number
  description = "Maximum number of nodes per zone in the GKE NodePool."
  default     = 5
}

variable "num_node_zones" {
  type        = number
  default     = 2
  description = <<EOF
The number of zones to allocate GKE Nodes.
This works in combination with min_node_count, max_node_count to determine how many nodes to create.
With min_node_count=1, max_node_count=5, num_node_zones=2, the GKE NodePool will provision at least 2 nodes and at most 10 nodes.
EOF
}

variable "blue_node_pool" {
  type = object({
    enabled      = optional(bool, true)
    name         = optional(string)
    machine_type = optional(string, "n2-standard-2")
    disk_size    = optional(number, 50)
  })
  default     = {}
  description = <<EOF
Configuration for the "blue" node pool.
- enabled: When true (default), the blue node pool is provisioned.
- name: Optional exact node pool name. When unset, the pool name is generated from "<block_ref>-blue-"
  plus a unique suffix appended by the provider. Workspaces migrating from a single-pool setup should
  set this to the existing pool's exact name (find it via `gcloud container node-pools list --cluster <name>`
  or `terraform state show google_container_node_pool.primary_nodes`) to pin the pool and avoid recreation
  on first apply. GKE caps node pool names at 40 chars.
  NOTE: With an explicit `name`, blue/green swaps that rebuild this pool require you to clear `name` first
  (or supply a new one), since GKE cannot have two pools with the same name during create_before_destroy.
- machine_type: Node instance machine type. See https://cloud.google.com/compute/docs/machine-resource#predefined_machine_types.
- disk_size: The disk size of each node in GB. This disk is used for OS files, logs, and images.

Pair with `green_node_pool` to roll node pool config changes without downtime. See README for the swap procedure.
EOF

  validation {
    condition     = var.blue_node_pool.name == null ? true : length(var.blue_node_pool.name) <= 40
    error_message = "blue_node_pool.name must be 40 characters or fewer (GKE node pool name limit)."
  }
}

variable "green_node_pool" {
  type = object({
    enabled      = optional(bool, false)
    name         = optional(string)
    machine_type = optional(string, "n2-standard-2")
    disk_size    = optional(number, 50)
  })
  default     = {}
  description = <<EOF
Configuration for the "green" node pool.
- enabled: When true, the green node pool is provisioned alongside blue. Defaults to false.
- name: Optional exact node pool name. When unset, the pool name is generated from "<block_ref>-green-"
  plus a unique suffix appended by the provider. GKE caps node pool names at 40 chars.
  NOTE: With an explicit `name`, blue/green swaps that rebuild this pool require you to clear `name`
  first (or supply a new one), since GKE cannot have two pools with the same name during create_before_destroy.
- machine_type: Node instance machine type. See https://cloud.google.com/compute/docs/machine-resource#predefined_machine_types.
- disk_size: The disk size of each node in GB. This disk is used for OS files, logs, and images.

Pair with `blue_node_pool` to roll node pool config changes without downtime. See README for the swap procedure.
EOF

  validation {
    condition     = var.green_node_pool.name == null ? true : length(var.green_node_pool.name) <= 40
    error_message = "green_node_pool.name must be 40 characters or fewer (GKE node pool name limit)."
  }
}

variable "resource_thresholds" {
  type = object({
    cpu = number
  })
  default = {
    cpu = 90
  }
  description = <<EOF
Configure CPU utilization alerting for the VM.
When enabled, a GCP monitoring alert policy is created that notifies the given notification channel when CPU utilization exceeds the configured threshold (0-100).
EOF
}

variable "enable_dataplane_v2" {
  type        = bool
  default     = false
  description = <<EOF
Enabling this improves network performance and adds better network policy enforcement.

WARNING: Changing this will result in a recreation of the cluster without downtime and data migration.
EOF
}

variable "enable_managed_otel" {
  type    = bool
  default = false

  description = <<EOF
Enable to install the Google-managed OpenTelemetry collector on this cluster.
The collector endpoint is emitted as an output `otel_collector_protocol`+`otel_collector_endpoint`.

Warning: The managed collector cannot be enabled through Terraform yet.
You must enable this flag to configure OpenTelemetry in your application though.
After enabling, perform: `gcloud container clusters update <cluster-name> --enable-managed-otel`
EOF
}

locals {
  managed_otel_svc      = "opentelemetry-collector"
  managed_otel_ns       = "gke-managed-otel"
  managed_otel_endpoint = "http://${local.managed_otel_svc}.${local.managed_otel_ns}.svc.cluster.local:4317"
}
