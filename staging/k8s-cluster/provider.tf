terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    region       = ""
    bucket       = ""
    key          = "staging/monitoring-stack/terraform.tfstate"
    encrypt      = true
    dynamodb_table = ""
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "Monitoring-Stack"
      Environment = var.env
      ManagedBy   = "Terraform"
    }
  }
}
