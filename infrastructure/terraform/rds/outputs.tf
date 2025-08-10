output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "db_endpoint" {
  value = split(":", module.rds.db_instance_endpoint)[0] # Take only endpoint without port
}