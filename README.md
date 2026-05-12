# gcp-gke

Nullstone module to launch a standard Kubernetes cluster using GKE on GCP.

The cluster is configured with two parallel node pools, `blue` and `green`, each independently
toggleable. By default `blue` is enabled and `green` is disabled. To change machine type or disk
size without downtime, see [Rolling node pool changes](#rolling-node-pool-changes) below.

## Inputs

- `min_node_count: number`
  - Minimum number of nodes in the GKE NodePool.
  - Default: `1`

- `max_node_count: number`
  - Maximum number of nodes in the GKE NodePool.
  - Default: `5`

- `blue_node_pool: object`
  - Configuration for the blue node pool.
  - Fields:
    - `enabled` (bool, default `true`)
    - `name_prefix` (string, optional) — overrides the default `<block_ref>-blue-` prefix. Must be ≤14 chars. See [Migrating from a single-pool setup](#migrating-from-a-single-pool-setup).
    - `machine_type` (string, default `n2-standard-2`)
    - `disk_size` (number, default `50`)
  - Default: `{}`

- `green_node_pool: object`
  - Configuration for the green node pool.
  - Fields:
    - `enabled` (bool, default `false`)
    - `name_prefix` (string, optional) — overrides the default `<block_ref>-green-` prefix. Must be ≤14 chars.
    - `machine_type` (string, default `n2-standard-2`)
    - `disk_size` (number, default `50`)
  - Default: `{}`

At least one of `blue_node_pool.enabled` or `green_node_pool.enabled` must be true.

GKE caps node pool names at 40 characters; the terraform-google provider appends a 26-character unique suffix, so the `name_prefix` budget is 14 characters. The default `<block_ref>-<color>-` naming fits as long as `block_ref` is ≤8 chars.

## Migrating from a single-pool setup

Pre-0.5.0 versions of this module had a single `primary_nodes` node pool. The 0.5.0 upgrade splits that into `blue` + `green`. A `moved` block migrates state from `primary_nodes` to `blue[0]`. To avoid replacing the existing pool on first apply, pin blue's `name_prefix` to the legacy value:

1. Read the legacy prefix from state:
   ```sh
   terraform state show google_container_node_pool.primary_nodes | grep name_prefix
   ```
   You'll see something like `name_prefix = "abcde-"`.
2. Set blue's overrides in your workspace tfvars to match today's deployment:
   ```hcl
   blue_node_pool = {
     name_prefix  = "abcde-"               # from step 1
     machine_type = "<current node_machine_type>"
     disk_size    = <current node_disk_size>
   }
   ```
3. `terraform plan` should show: 1 state move, 0 resource changes.

On a future swap (re-enabling blue with new config), you can drop the `name_prefix` override to adopt the new `<block_ref>-blue-` naming — that swap will rebuild the pool anyway.

## Rolling node pool changes

To change `machine_type` or `disk_size` without downtime, swap traffic from blue to green (or vice versa):

1. **Launch green** alongside blue with the new config:
   ```hcl
   green_node_pool = {
     enabled      = true
     machine_type = "<new machine type>"
     disk_size    = <new disk size>
   }
   ```
   Apply. Green is created; blue keeps serving traffic.

2. **Wait for green to be Ready**:
   ```sh
   kubectl get nodes -l cloud.google.com/gke-nodepool=<green-pool-name>
   ```
   Optionally `kubectl cordon` and `kubectl drain --ignore-daemonsets --delete-emptydir-data` each blue node to migrate workloads under your control. PodDisruptionBudgets are respected.

3. **Retire blue**:
   ```hcl
   blue_node_pool = { enabled = false }
   ```
   Apply. GKE drains blue and destroys the pool. Green is now the sole pool.

4. **Next swap** reverses direction: re-enable `blue_node_pool` with newer config, apply, wait, then disable `green_node_pool`.
  
## Outputs

- `cluster_id: string` 
  - Identifier for GKE cluster (format projects/{{project}}/locations/{{zone}}/clusters/{{name}})"
  
- `cluster_endpoint: string` 
  - The IP address of this cluster's Kubernetes master.

- `cluster_ca_certificate: string` 
  - Base64 encoded public certificate used by clients to authenticate to the cluster endpoint.