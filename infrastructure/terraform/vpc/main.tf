data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = local.azs
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = false

  enable_flow_log           = true
  flow_log_destination_type = "cloud-watch-logs"
  flow_log_destination_arn  = aws_cloudwatch_log_group.vpc_flow.arn
  flow_log_traffic_type     = "ALL"

  tags = {
    Name        = var.project_name
    Environment = var.env
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow" {
  name              = "/aws/vpc/flowlogs"
  retention_in_days = 30
}
