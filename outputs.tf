output "cluster_id" {
  value       = google_container_cluster.primary.id
  description = "string ||| Identifier for GKE cluster (format projects/{{project}}/locations/{{zone}}/clusters/{{name}})"
}

output "cluster_endpoint" {
  value       = google_container_cluster.primary.endpoint
  description = "string ||| The IP address of this cluster's Kubernetes master."
}

output "cluster_ca_certificate" {
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  description = "string ||| Base64 encoded public certificate used by clients to authenticate to the cluster endpoint."
  sensitive   = true
}

output "deployer" {
  value = {
    email       = try(google_service_account.deployer.email, "")
    private_key = try(google_service_account_key.deployer.private_key, "")
  }

  description = "object({ email: string, private_key: string }) ||| A GCP service account with explicit privilege to deploy this GKE services to this cluster."
  sensitive = true
}
