#create a s3 bucket

resource "aws_s3_bucket" "guardian_api_bucket" {
  bucket = "api-guardian-project"

  tags = {
    Name        = "guardian_api_bucket"
    Environment = "Production"
  }
}