terraform {
  source = "../../../terraform/rds/"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "mock_vpc_id"
    subnet_ids_for_rds = ["mock_subnet_a", "mock_subnet_b"]
  }
}

inputs = {
  env = "dev"

  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_ids_for_rds = dependency.vpc.outputs.subnet_ids_for_rds
}