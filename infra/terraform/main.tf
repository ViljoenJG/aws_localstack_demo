terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  # No LocalStack-specific config here!
  # tflocal automatically generates a provider override that
  # redirects all endpoints to localhost:4566.
  # These same .tf files work with `terraform apply` against real AWS.
}
