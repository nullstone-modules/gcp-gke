data "ns_connection" "network" {
  name     = "network"
  type     = "network/gcp"
  contract = "network/gcp/vpc"
}

locals {
  vpc_name             = data.ns_connection.network.outputs.vpc_name
  private_subnet_names = data.ns_connection.network.outputs.private_subnet_names
}
