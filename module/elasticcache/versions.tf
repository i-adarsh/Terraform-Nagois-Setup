# Terraform version
terraform {
  required_version = ">= 0.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.1.15"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
