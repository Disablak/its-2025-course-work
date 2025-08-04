variable "region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}