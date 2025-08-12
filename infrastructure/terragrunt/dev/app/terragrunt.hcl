terraform {
  source = "../../../terraform/app/"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../s3-static", "../vpc", "../rds"]
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "mock_vpc_id"
    public_subnet_ids = ["mock_subnet_a", "mock_subnet_b"]
    subnet_ids_for_web = ["mock_subnet_a", "mock_subnet_b"]
  }
}

dependency "rds" {
  config_path = "../rds"

  mock_outputs = {
    rds_security_group_id = "sec_group"
    db_host = "host"
  }
}

inputs = {
  env = "dev"

  path_to_terragrunt = get_parent_terragrunt_dir()

  vpc_id = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  subnet_ids_for_web = dependency.vpc.outputs.subnet_ids_for_web
  
  rds_security_group_id = dependency.rds.outputs.rds_security_group_id
  db_host = dependency.rds.outputs.db_endpoint
}