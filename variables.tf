variable "node_count" {
  type        = number
  description = "The number of nodes per instance group."
  default     = 1
}

variable "node_machine_type" {
  type        = string
  description = "Node instance machine type."
  default     = "n1-standard-1"
}