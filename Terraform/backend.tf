terraform {
  backend "s3" {
    bucket       = "api-project-state-file"
    key          = "/production/api-project-file.tfstate"
    use_lockfile = true
    region       = "us-east-1"
  }
}