output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "efs_sg_id" {
  value = aws_security_group.efs_sg.id
}

output "efs_id" {
  value = aws_efs_file_system.wordpress.id
}

output "efs_ap_id" {
  value = aws_efs_access_point.wordpress_ap.id
}

resource "local_file" "inventory" {
  content = templatefile("./inventory.tftpl", {
    bastion_ip = aws_instance.bastion.public_ip,

    region   = var.region
    dns_name = var.dns_name

    efs_id    = aws_efs_file_system.wordpress.id,
    efs_ap_id = aws_efs_access_point.wordpress_ap.id,

    db_name          = var.db_name
    db_user          = var.db_user
    db_password_name = var.db_password_name
    db_host          = var.db_host,

    mysql_user          = var.mysql_user
    mysql_password_name = var.mysql_password_name
  })
  filename = "${var.path_to_terragrunt}/../../ansible/inventory"
}