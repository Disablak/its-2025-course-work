variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "bucket_name_static_content" {
  type = string
}

variable "bucket_name_log" {
  type = string
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
  type = string
}

variable "min_autoscale_size" {
  type = number
}

variable "max_autoscale_size" {
  type = number
}

variable "dns_name" {
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

variable "bastion_sg_id" {
  type = string
}

variable "efs_sg_id" {
  type = string
}

variable "efs_id" {
  type = string
}

variable "efs_ap_id" {
  type = string
}