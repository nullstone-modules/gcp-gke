# gcp-gke
Nullstone module to launch a standard Kubernetes cluster using GKE on GCP. GKE cluster gets created with managed node pool.

## Inputs

- `min_node_count: number`
  - Minimum number of nodes in the GKE NodePool.
  - Default: `1`

- `max_node_count: number`
  - Maximum number of nodes in the GKE NodePool.
  - Default: `5`

- `node_machine_type: string`
  - Node instance machine type.
  - Default: `n1-standard-1`
  
## Outputs

- `cluster_id: string` 
  - Identifier for GKE cluster (format projects/{{project}}/locations/{{zone}}/clusters/{{name}})"
  
- `cluster_endpoint: string` 
  - The IP address of this cluster's Kubernetes master.

- `cluster_ca_certificate: string` 
  - Base64 encoded public certificate used by clients to authenticate to the cluster endpoint.