terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    # bucket is resolved dynamically in CI — do NOT hardcode it here.
    # The workflow runs bootstrap and passes:
    #   terraform init -backend-config="bucket=rexony-tfstate-<account_id>"
    key            = "rexony/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "rexony-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}