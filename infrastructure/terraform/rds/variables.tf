variable "vpc_id" {
  type = string
}

variable "subnet_ids_for_rds" {
  type = list(string)
}