variable "region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "ami" {
  type = string
  default = "ami-0cc3e99c2bf9814be"
}

variable "public_key_name" {
  type        = string
  description = "SSH public key name to login into EC2 instance"
  default     = "key-us-east-1"
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

variable "admin_ip" {
  type = string
  default = "141.138.97.234/32"
}