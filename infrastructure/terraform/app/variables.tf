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
  default = "ami-08a6efd148b1f7504"
}

variable "public_key" {
  type        = string
  description = "SSH public key to login into EC2 instance"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQyBc2y0+lf5P5r+TqOqihPoJsp0she5qcSXoGJ+XAov59LGfSeTabaDKXC9R2Jw04xNNy3B6vQvKVXpqZWyz7kRumKDhu2rJiS3zjWBP1wcGyNIFdi2frzqdLeQG4EN8WjPuQOh86N1QhAbhnVD4WnHgNRVwH62ll101JHpcYdNoHRnBAzAlsUXx1/l3QajywR29MxW03fgaiLyJRgngzWGdnsdkmrcYde2ZceUEXEgXHITXogUqVgy2E3nr/TcrMehwlHk1XN1b29QzHA5p+rOINMyWFBdNeVfpA1VL5NAKgaiABRZeMUsPkaLlEt09TfCWuw9TlXNOJRc44FcRZ key-us-east-1"
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