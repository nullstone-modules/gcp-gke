terraform {
  required_providers {
    ns = {
      source = "nullstone-io/ns"
    }
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}

data "ns_workspace" "this" {}

// Generate a random suffix to ensure uniqueness of resources
resource "random_string" "resource_suffix" {
  length  = 5
  lower   = true
  upper   = false
  numeric = false
  special = false
}

locals {
  labels = data.ns_workspace.this.gcp_labels

  // node_labels are applied to the Kubernetes node objects via node_config.labels. Built explicitly
  // (rather than passing k8s_labels straight through) because GKE rejects node labels under the
  // reserved kubernetes.io / k8s.io namespaces, e.g. the app.kubernetes.io/* recommended labels.
  node_labels = {
    environment        = data.ns_workspace.this.k8s_labels["environment"]
    owner              = data.ns_workspace.this.k8s_labels["owner"]
    project            = data.ns_workspace.this.k8s_labels["project"]
    dataclassification = data.ns_workspace.this.k8s_labels["dataclassification"]
    application        = data.ns_workspace.this.k8s_labels["application"]

    "nullstone.io/env"   = local.env_name
    "nullstone.io/stack" = local.stack_name
    "nullstone.io/block" = local.block_name
  }

  stack_name    = data.ns_workspace.this.stack_name
  block_name    = data.ns_workspace.this.block_name
  env_name      = data.ns_workspace.this.env_name
  block_ref     = data.ns_workspace.this.block_ref
  resource_name = "${local.block_ref}-${random_string.resource_suffix.result}"
}
