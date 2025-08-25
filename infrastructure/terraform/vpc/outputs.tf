output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "subnet_ids_for_web" {
  value = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
}

output "subnet_ids_for_rds" {
  value = [module.vpc.private_subnets[2], module.vpc.private_subnets[3]]
}