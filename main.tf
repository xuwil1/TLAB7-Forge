provider "aws" {  
  region = "us-east-1"  
}  

# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "vulnerable_vault" {
  bucket = "tkh-exposed-vault-${random_id.id.hex}"
}  

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.vulnerable_vault.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}  
# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.vulnerable_vault.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_security_group" "sabotaged_sg" {
  name        = "tlab7-exposed-sg"
  description = "A dangerously exposed security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["100.12.79.25/32"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr #tfsec:ignore:AWS006
  }
}