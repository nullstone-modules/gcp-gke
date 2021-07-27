output "cluster_id" {
  value       = google_container_cluster.primary.id
  description = "string ||| Identifier for GKE cluster (format projects/{{project}}/locations/{{zone}}/clusters/{{name}})"
}