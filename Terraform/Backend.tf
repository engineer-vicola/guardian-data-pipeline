terraform {
  backend "s3" {
    bucket = "rds-state-file"
    key    = "rds-state-file/terraform.tfstate"
    region = "us-east-1"
  }
}