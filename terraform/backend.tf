terraform {
  backend "s3" {
    bucket = "sparrow-lms-deployment"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}