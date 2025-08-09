output "alb_endpoint" {
  value = aws_lb.main.dns_name
}

output "efs_id" {
  value = aws_efs_file_system.wordpress.id
}

output "efs_ap_id" {
  value = aws_efs_access_point.wordpress_ap.id
}

data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:Name"
    values = ["web-asg"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

resource "local_file" "inventory" {
  content = templatefile("./inventory.tftpl", {
    web_ips = data.aws_instances.asg_instances.private_ips,
    bastion_ip = aws_instance.bastion.public_ip,
    efs_id = aws_efs_file_system.wordpress.id,
    efs_ap_id = aws_efs_access_point.wordpress_ap.id,
    db_endpoint = "test", # TODO take from rds
  })
  filename = "${path.root}/../../../ansible/inventory"
}