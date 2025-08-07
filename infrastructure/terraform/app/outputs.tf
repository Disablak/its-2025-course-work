output "alb_endpoint" {
  value = aws_lb.main.dns_name
}

output "efs_id" {
  value = aws_efs_file_system.wordpress.id
}