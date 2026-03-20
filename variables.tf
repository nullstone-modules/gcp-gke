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

variable "node_machine_type" {
  type        = string
  description = "Node instance machine type. See https://cloud.google.com/compute/docs/machine-resource#predefined_machine_types."
  default     = "n2-standard-2"
}

variable "node_disk_size" {
  type        = number
  default     = 50
  description = "The disk size of each node node in GB. This disk is used for OS files, logs, and images"
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
