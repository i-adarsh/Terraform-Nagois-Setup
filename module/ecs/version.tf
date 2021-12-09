terraform {
  required_version = ">= 0.12.26"

  required_providers {
    aws = ">= 2.48"
  }
}

provider "aws" {
  region = "us-east-1"
}
