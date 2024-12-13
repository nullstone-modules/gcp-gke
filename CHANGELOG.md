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
