terraform {
  source = "../../../terraform/app/"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../vpc", "../rds", "../bastion"]
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

dependency "bastion" {
  config_path = "../bastion"

  mock_outputs = {
    bastion_sg_id = "mock"
    efs_sg_id = "mock"
    efs_id = "mock"
    efs_ap_id = "mock"
  }
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  subnet_ids_for_web = dependency.vpc.outputs.subnet_ids_for_web
  
  rds_security_group_id = dependency.rds.outputs.rds_security_group_id
  db_host = dependency.rds.outputs.db_endpoint

  bastion_sg_id = dependency.bastion.outputs.bastion_sg_id
  efs_sg_id = dependency.bastion.outputs.efs_sg_id
  efs_id = dependency.bastion.outputs.efs_id
  efs_ap_id = dependency.bastion.outputs.efs_ap_id
}