# gcp-gke
Nullstone module to launch a standard Kubernetes cluster using GKE on GCP. GKE cluster gets created with managed node pool.

## Inputs

- `node_count: number`
  - The number of nodes per instance group.
  - Default: `1`
  - 
- `node_machine_type: string`
  - Node instance machine type.
  - Default: `n1-standard-1`
  
## Outputs

- `cluster_id: string` 
  - Identifier for GKE cluster (format projects/{{project}}/locations/{{zone}}/clusters/{{name}})"