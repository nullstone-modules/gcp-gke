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
  description = "Node instance machine type."
  default     = "n1-standard-1"
}