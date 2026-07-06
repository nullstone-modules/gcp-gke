output "project_id" {
  value       = local.project_id
  description = "string ||| The GCP Project ID where the GKE cluster is hosted."
}

output "region" {
  value       = local.region
  description = "string ||| The region where the GKE cluster is hosted."
}

output "cluster_id" {
  value       = google_container_cluster.primary.id
  description = "string ||| Identifier for GKE cluster (format: projects/{{project}}/locations/{{zone}}/clusters/{{name}})"
}

output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "string ||| The name of the GKE cluster"
}

output "blue_node_pool_name" {
  value       = try(google_container_node_pool.blue[0].name, "")
  description = "string ||| The name of the blue node pool, or empty string when blue is disabled."
}

output "green_node_pool_name" {
  value       = try(google_container_node_pool.green[0].name, "")
  description = "string ||| The name of the green node pool, or empty string when green is disabled."
}

output "node_service_account_email" {
  value       = google_service_account.cluster.email
  description = "string ||| The email of the service account assigned to cluster nodes. External node pool blocks (e.g. gcp-gke-gpu-node-pool) reuse this service account."
}

output "cluster_endpoint" {
  value       = google_container_cluster.primary.endpoint
  description = "string ||| The IP address of this cluster's Kubernetes master."
}

output "cluster_ca_certificate" {
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  description = "string ||| base64-encoded public certificate used by clients to authenticate to the cluster endpoint."
}

output "default_namespace" {
  value       = "default"
  description = "string ||| The default namespace created in the Kubernetes cluster"
}

output "otel_collector_protocol" {
  value       = var.enable_managed_otel ? "grpc" : ""
  description = "string ||| If Google-managed OpenTelemetry collector is enabled, this contains the protocol for the collector"
}

output "otel_collector_endpoint" {
  value       = var.enable_managed_otel ? local.managed_otel_endpoint : ""
  description = "string ||| If Google-managed OpenTelemetry collector is enabled, this contains the endpoint for the collector"
}
