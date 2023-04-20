# 0.3.1 (Apr 20, 2023)
* Enabled VPC-Native Traffic Routing.

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
