variable "name" {
  type        = string
  default     = "zqms-stack"
  description = "Name  (e.g. `app` or `cluster`)."
}


variable "vpc_name" {
  default = "vpc-production"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnets_cidr" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets_cidr" {
  type    = list(any)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

