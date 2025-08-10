variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids_for_rds" {
  type = list(string)
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