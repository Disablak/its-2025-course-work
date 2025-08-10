output "alb_endpoint" {
  value = aws_lb.main.dns_name
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
    bastion_ip = aws_instance.bastion.public_ip,
    web_ips = data.aws_instances.asg_instances.private_ips,

    dns_name = var.dns_name

    efs_id = aws_efs_file_system.wordpress.id,
    efs_ap_id = aws_efs_access_point.wordpress_ap.id,

    db_name = var.db_name
    db_user = var.db_user
    db_password = var.db_password
    db_host = var.db_host,

    mysql_user = var.mysql_user
    mysql_password = var.mysql_password
  })
  filename = "${var.path_to_terragrunt}/../../ansible/inventory"
}