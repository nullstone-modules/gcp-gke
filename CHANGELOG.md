# 0.6.3 (Jul 06, 2026)
* Added `roles/container.defaultNodeServiceAccount` to the node service account.

# 0.6.2 (Jul 06, 2026)
* Added `var.min_master_version` to set a minimum control plane version (required for G4 GPU node pools, which need GKE 1.34+).
* Added `node_service_account_email` output so external node pool blocks (e.g. `gcp-gke-gpu-node-pool`) can reuse the cluster's node service account.

# 0.6.1 (Jul 02, 2026)
* Switched to use `ns_workspace.gcp_labels` for GCP labels.

# 0.6.0 (Jul 02, 2026)
* `var.enable_managed_otel` now enables the Google-managed OpenTelemetry collector directly through Terraform via `managed_opentelemetry_config` (scope `COLLECTION_AND_INSTRUMENTATION_COMPONENTS`); the manual `gcloud container clusters update --enable-managed-otel` step is no longer needed.
* Switched only the `google_container_cluster.primary` resource to the `google-beta` provider (required for `managed_opentelemetry_config`). Requires GKE 1.34.1-gke.2178000+.

# 0.5.6 (May 12, 2026)
* Changed format of generated node pool names to fix name limits.

# 0.5.5 (May 12, 2026)
* Fixed cpu monitoring alert filter syntax: use `= monitoring.regex.full_match("...")` instead of `=~`, which GCP's filter language does not support on `metadata.user_labels`.

# 0.5.4 (May 12, 2026)
* Fixed cpu monitoring alert.

# 0.5.3 (May 12, 2026)
* Fixed variable validation syntax.

# 0.5.2 (May 12, 2026)
* Fixed variable check when the blue and green names are null.
* Added blue and green node pool names to outputs.

# 0.5.1 (May 12, 2026)
* Node pool names now default to `<block_ref>-<color>-...` so the block ref is visible in GCP. Each pool exposes an optional `name` field to pin the pool's exact name (≤40 chars per GKE's limit).
* The existing pool is migrated into `blue[0]` via a `moved` block. **Existing workspaces should set `blue_node_pool.name` to the legacy pool's exact name** to prevent the pool from being rebuilt. Also pass the workspace's current machine_type/disk_size values into `blue_node_pool`. See README for the lookup procedure and the caveat about clearing `name` before future swaps.

# 0.5.0 (May 12, 2026)
* Split the node pool into two node pools (`blue`, `green`) that can be used to make changes to node pools without downtime.
* **Breaking:** Removed `var.node_machine_type` and `var.node_disk_size`. Use `var.blue_node_pool = { machine_type = ..., disk_size = ... }` and `var.green_node_pool = { ... }` instead.
* The existing node pool is migrated into `blue[0]` via a `moved` block. Pass the workspace's current `node_machine_type` and `node_disk_size` values into `blue_node_pool` to keep the apply diff at zero (state move only, no node pool rebuild).
* See README for the blue/green swap procedure used to roll node pool config changes without downtime.

# 0.4.26 (May 01, 2026)
* Added `project_id` to outputs.

# 0.4.25 (May 01, 2026) 
* Added `region` to outputs.

# 0.4.24 (Apr 22, 2026)
* Added nullstone resource labels to GKE cluster and nodes.

# 0.4.23 (Mar 20, 2026)
* Fixed managed OpenTelemetry endpoint.

# 0.4.22 (Mar 20, 2026)
* Added `var.enable_managed_otel` to enable Google-managed OpenTelemetry collector. (needs manual enable as well)

# 0.4.21 (Mar 04, 2026)
* Disabled network policy config addon when using Dataplane v2.

# 0.4.20 (Mar 04, 2026)
* Removed `network_policy` when Dataplane v2 is enabled to prevent google error.

# 0.4.19 (Mar 03, 2026)
* Enabled network policy config addon.

# 0.4.18 (Mar 03, 2026)
* Fixed `datapath_provider` from causing recreation when not dataplane v2 is not enabled.
* Fixed network policy provider by specifying `CALICO`.

# 0.4.15 (Mar 03, 2026)
* Enabled network policy on the cluster.
* Added `var.enable_dataplane_v2` to enable Dataplane V2.

# 0.4.14 (Feb 20, 2026)
* Fixed the resource alert filter to use `metadata.user_labels."goog-k8s-node-pool-name"`.

# 0.4.13 (Feb 20, 2026)
* Fixed the resource alert filter to use the node pool name.

# 0.4.12 (Feb 20, 2026)
* Fixed the resource alert filter for GKE nodes.

# 0.4.11 (Feb 20, 2026)
* Added resource alerts for GKE nodes.

# 0.4.10 (Feb 19, 2026)
* Shortened node pool name

# 0.4.9 (Feb 19, 2026)
* Reconfigured cluster node pool to enable private nodes.

# 0.4.8 (Feb 19, 2026)
* Removed public IP address for cluster nodes.

# 0.4.7 (Dec 30, 2025)
* Added logging and metrics access to node service account.

# 0.4.6 (Dec 30, 2025)
* Do not make changes to the default node pool since we remove it.

# 0.4.5 (Dec 12, 2025)
* Applied `node_disk_size` to container cluster node config.

# 0.4.4 (Dec 12, 2025)
* Added `var.node_disk_size` to allow configuration of each node's disk.

# 0.4.3 (Dec 12, 2025)
* Reduced node disk size to 50GB. (Previous default was 100GB)

# 0.4.2 (Dec 12, 2025)
* Reverted to `terraform`.

# 0.4.1 (Dec 11, 2025)
* Fixed change to `helm` provider definition from provider upgrade.

# 0.4.0 (Dec 11, 2025)
* Migrated from `terraform` to `tofu`.

# 0.3.19 (Feb 09, 2025)
* Added `default_namespace` output.

# 0.3.18 (Jan 30, 2025)
* Fixed destruction of `external-secrets` namespace from stalling.
* Added full set of labels to `external-secrets` namespace.

# 0.3.17 (Jan 30, 2025)
* Increase wait timeout for destruction of `external-secrets` namespace.

# 0.3.16 (Jan 29, 2025)
* Moved `external-secrets` helm chart into this TF module. 

# 0.3.15 (Dec 13, 2024)
* Revert unknown Service Account Config on k8s cluster.

# 0.3.14 (Dec 12, 2024)
* Enable Gateway API on k8s cluster.
* Enable Service Account on k8s cluster.

# 0.3.13 (Dec 11, 2024)
* Cluster CA certificate is no longer marked as a sensitive output because it's used to verify server identity.

# 0.3.12 (Dec 09, 2024)
* Added permissions so that we can read images from the artifact registry.

# 0.3.11 (Dec 02, 2024)
* Remove deletion protection since Nullstone has approvals for destruction.

# 0.3.10 (Nov 27, 2024)
* Upgrade TF providers.

# 0.3.9 (Mar 22, 2024)
* Upgrade TF providers.

# 0.3.8 (Mar 22, 2024)
* Enable several storage csi driver addons by default. (filestore, persistent disk, fuse)
* Enable config connector addon by default.

# 0.3.7 (May 10, 2023)
* Enable container Google API.

# 0.3.6 (May 10, 2023)
* Enable iam Google API.

# 0.3.5 (Apr 20, 2023)
* Fixed missing `num_node_zones` functionality.

# 0.3.4 (Apr 20, 2023)
* Added `num_node_zones` to provide limits around how many nodes in the cluster.

# 0.3.3 (Apr 20, 2023)
* Add missing `ip_allocation_policy` for VPC-Native Traffic routing.

# 0.3.2 (Apr 20, 2023)
* Enabled VPC-Native Traffic Routing.

# 0.3.1 (Mar 30, 2023)
* Drop `cluster_name` from outputs.

# 0.3.0 (Mar 29, 2023)
* Moved `deployer` service account into app module.
* Increased default machine type to `n2-standard-2` for node pool.

# 0.2.3 (Mar 28, 2023)
* Enabled Workload Identity on GKE cluster.

# 0.2.2 (Mar 24, 2023)
* Added `roles/container.nodeServiceAccount` to cluster service account to ensure minimum set of permissions.

# 0.2.1 (Mar 22, 2023)
* Truncated deployer account_id so it does not exceed 28 character limit.

# 0.2.0 (Mar 22, 2023)
* Added `.terraform.lock.hcl`.
* Changed platform to `k8s:gke`.
