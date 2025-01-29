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
