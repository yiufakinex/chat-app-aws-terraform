# S3 bucket for media storage (chat attachments, user avatars, etc.)
resource "aws_s3_bucket" "chat_media" {
  bucket = "${var.environment}-chat-media"

  tags = {
    Name        = "${var.environment}-chat-media"
    Environment = var.environment
  }
}

# S3 bucket ACL for media storage
resource "aws_s3_bucket_ownership_controls" "chat_media" {
  bucket = aws_s3_bucket.chat_media.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "chat_media" {
  depends_on = [aws_s3_bucket_ownership_controls.chat_media]

  bucket = aws_s3_bucket.chat_media.id
  acl    = "private"
}

# Enable versioning for media files
resource "aws_s3_bucket_versioning" "chat_media" {
  bucket = aws_s3_bucket.chat_media.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "chat_media" {
  bucket = aws_s3_bucket.chat_media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Configure CORS for media bucket
resource "aws_s3_bucket_cors_configuration" "chat_media" {
  bucket = aws_s3_bucket.chat_media.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"] # In production, restrict to your domain
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Lifecycle policy for media bucket
resource "aws_s3_bucket_lifecycle_configuration" "chat_media" {
  bucket = aws_s3_bucket.chat_media.id

  rule {
    id     = "archive-old-temp-files"
    status = "Enabled"

    filter {
      prefix = "temp/"
    }

    expiration {
      days = 1
    }
  }
}

# S3 bucket for static assets (if not using CloudFront)
resource "aws_s3_bucket" "chat_static" {
  bucket = "${var.environment}-chat-static"

  tags = {
    Name        = "${var.environment}-chat-static"
    Environment = var.environment
  }
}

# S3 bucket ACL for static assets
resource "aws_s3_bucket_ownership_controls" "chat_static" {
  bucket = aws_s3_bucket.chat_static.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "chat_static" {
  depends_on = [aws_s3_bucket_ownership_controls.chat_static]

  bucket = aws_s3_bucket.chat_static.id
  acl    = "private"
}

# Enable versioning for static assets
resource "aws_s3_bucket_versioning" "chat_static" {
  bucket = aws_s3_bucket.chat_static.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Configure CORS for static bucket
resource "aws_s3_bucket_cors_configuration" "chat_static" {
  bucket = aws_s3_bucket.chat_static.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"] # In production, restrict to your domain
    max_age_seconds = 3000
  }
}
