terraform {
  source = "../../../terraform/s3-static/"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  env = "dev"
}