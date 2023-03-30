variable "min_node_count" {
  type        = number
  description = "Minimum number of nodes in the GKE NodePool."
  default     = 1
}

variable "max_node_count" {
  type        = number
  description = "Maximum number of nodes in the GKE NodePool."
  default     = 5
}

variable "node_machine_type" {
  type        = string
  description = "Node instance machine type. See https://cloud.google.com/compute/docs/machine-resource#predefined_machine_types."
  default     = "n2-standard-2"
}
