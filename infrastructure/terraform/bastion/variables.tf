variable "project_name" {
  type = string
}

variable "region" {
  type    = string
}

variable "env" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ami" {
  type = string
}

variable "public_key_name" {
  type        = string
  description = "SSH public key name to login into EC2 instance"
}

variable "admin_ip" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "subnet_ids_for_web" {
  type = list(string)
}

variable "rds_security_group_id" {
  type = string
}


variable "path_to_terragrunt" {
  type = string
}

variable "dns_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "db_host" {
  type = string
}

variable "mysql_user" {
  type = string
}

variable "mysql_password" {
  type = string
  sensitive = true
}