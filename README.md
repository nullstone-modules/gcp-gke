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
    - `name` (string, optional) — pins the exact node pool name. When unset, the name is generated from `<block_ref>-blue-` plus a provider-appended unique suffix. See [Migrating from a single-pool setup](#migrating-from-a-single-pool-setup).
    - `machine_type` (string, default `n2-standard-2`)
    - `disk_size` (number, default `50`)
  - Default: `{}`

- `green_node_pool: object`
  - Configuration for the green node pool.
  - Fields:
    - `enabled` (bool, default `false`)
    - `name` (string, optional) — pins the exact node pool name. When unset, the name is generated from `<block_ref>-green-` plus a provider-appended unique suffix.
    - `machine_type` (string, default `n2-standard-2`)
    - `disk_size` (number, default `50`)
  - Default: `{}`

At least one of `blue_node_pool.enabled` or `green_node_pool.enabled` must be true.

GKE caps node pool names at 40 characters. When `name` is unset, the provider appends a 26-char unique suffix to the default `<block_ref>-<color>-` prefix, so `block_ref` should be ≤8 chars for the default naming to fit. When `name` is set, the full value must be ≤40 chars.

## Migrating from a single-pool setup

Pre-0.5.0 versions of this module had a single `primary_nodes` node pool. The 0.5.0 upgrade splits that into `blue` + `green`. A `moved` block migrates state from `primary_nodes` to `blue[0]`. To prevent the existing pool from being replaced on first apply, pin blue's `name` to the legacy pool's exact name:

1. Read the existing pool name:
   ```sh
   gcloud container node-pools list --cluster <cluster-name> --region <region>
   ```
   Or from terraform state:
   ```sh
   terraform state show google_container_node_pool.primary_nodes | grep '^\s*name '
   ```
   You'll see something like `name = "abcde-12345678901234567890"`.
2. Set blue's overrides in your workspace tfvars to match today's deployment:
   ```hcl
   blue_node_pool = {
     name         = "abcde-12345678901234567890"   # from step 1, exact match
     machine_type = "<current node_machine_type>"
     disk_size    = <current node_disk_size>
   }
   ```
3. `terraform plan` should show: 1 state move, 0 resource changes.

**Future swaps:** with an explicit `name` set, blue cannot be rebuilt in place via `create_before_destroy` (two pools cannot share a name). When you next want to roll a config change, clear the `name` override before triggering a rebuild — the pool will then be recreated with the generated `<block_ref>-blue-...` naming and `create_before_destroy` will work as designed.

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