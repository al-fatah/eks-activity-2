terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # EKS + VPC modules you’re using are tested on 5.x
      version = ">= 5.40.0, < 6.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}
