terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"  # Specify the version of random provider required
    }

    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"      
    }
  }

  required_version = ">= 1.1"
}