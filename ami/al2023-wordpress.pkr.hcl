packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "al2023" {
  region        = "us-east-1"
  instance_type = "t2.micro"
  ssh_username  = "ec2-user"
  ami_name      = "custom-al2023-ami-wordpress-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      architecture        = "x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
}

build {
  name    = "amazon-linux-2023-lamp"
  sources = ["source.amazon-ebs.al2023"]

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y httpd php php-mysqli mariadb105 amazon-efs-utils python3 python3-pip amazon-cloudwatch-agent",
      "sudo pip install PyMySQL"
    ]
  }
}
