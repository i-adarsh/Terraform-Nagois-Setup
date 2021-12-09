# Region suitable for low latency
variable "region" {
    type = string
    default = "us-east-1" # Current Region
    description = "Region suitable for low latency"
}

variable "profile" {
  type        = string
  default     = "default"
  description = "description"
}