terraform {
  source = "../../../terraform/app/"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "mock_vpc_id"
    public_subnet_ids = ["mock_subnet_a", "mock_subnet_b"]
    subnet_ids_for_web = ["mock_subnet_a", "mock_subnet_b"]
  }
}

inputs = {
  env = "dev"

  vpc_id = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  #subnet_ids_for_web = dependency.vpc.outputs.subnet_ids_for_web
  subnet_ids_for_web = [dependency.vpc.outputs.private_subnet_ids[0], dependency.vpc.outputs.private_subnet_ids[1]]
}