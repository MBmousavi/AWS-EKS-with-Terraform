terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.75"
    }
  }

  required_version = ">= 1.9.8"
}
provider "aws" {
  profile = var.profile
  region  = var.region
}