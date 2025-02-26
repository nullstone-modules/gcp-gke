output "cluster_id" {
  value       = google_container_cluster.primary.id
  description = "string ||| Identifier for GKE cluster (format: projects/{{project}}/locations/{{zone}}/clusters/{{name}})"
}

output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "string ||| The name of the GKE cluster"
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
