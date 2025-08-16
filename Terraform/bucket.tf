resource "aws_s3_bucket" "guardian_api_bucket" {
  bucket = "api-guardian-project"

  tags = {
    Name        = "guardian_api_bucket"
    Environment = "Production"
  }
}
resource "aws_s3_bucket_versioning" "guardian_api_bucket_versioning" {
  bucket = aws_s3_bucket.guardian_api_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "guardian_api_bucket_lifecycle" {
  bucket = aws_s3_bucket.guardian_api_bucket.id

  rule {
    id     = "api-bucket-versioning"
    status = "Enabled"

    expiration {
      days = 90
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}