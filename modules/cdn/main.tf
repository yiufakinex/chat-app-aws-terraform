# CloudFront Origin Access Identity for S3 buckets
resource "aws_cloudfront_origin_access_identity" "chat_oai" {
  comment = "OAI for ${var.environment} chat application"
}

# CloudFront distribution for static assets
resource "aws_cloudfront_distribution" "static" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.environment} chat static assets"
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # Use only North America and Europe

  origin {
    domain_name = var.static_bucket_domain_name
    origin_id   = "S3-${var.environment}-chat-static"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.chat_oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.environment}-chat-static"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Cache behavior for CSS/JS files with longer TTL
  ordered_cache_behavior {
    path_pattern     = "*.js"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.environment}-chat-static"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400    # 1 day
    max_ttl                = 31536000 # 1 year
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "*.css"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.environment}-chat-static"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400    # 1 day
    max_ttl                = 31536000 # 1 year
    compress               = true
  }

  # Add custom domain if provided
  dynamic "aliases" {
    for_each = var.domain_name != "" ? [1] : []
    content {
      items = ["static.${var.domain_name}"]
    }
  }

  # Add HTTPS if certificate provided
  dynamic "viewer_certificate" {
    for_each = var.certificate_arn != "" ? [1] : []
    content {
      acm_certificate_arn      = var.certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  # Use CloudFront certificate if no custom certificate
  dynamic "viewer_certificate" {
    for_each = var.certificate_arn == "" ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${var.environment}-chat-static-cdn"
    Environment = var.environment
  }
}

# CloudFront distribution for media files
resource "aws_cloudfront_distribution" "media" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.environment} chat media files"
  price_class     = "PriceClass_100" # Use only North America and Europe

  origin {
    domain_name = var.media_bucket_domain_name
    origin_id   = "S3-${var.environment}-chat-media"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.chat_oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.environment}-chat-media"

    forwarded_values {
      query_string = true # Pass query string for signed URLs
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400  # 1 day
    max_ttl                = 604800 # 1 week
    compress               = true
  }

  # Add custom domain if provided
  dynamic "aliases" {
    for_each = var.domain_name != "" ? [1] : []
    content {
      items = ["media.${var.domain_name}"]
    }
  }

  # Add HTTPS if certificate provided
  dynamic "viewer_certificate" {
    for_each = var.certificate_arn != "" ? [1] : []
    content {
      acm_certificate_arn      = var.certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  # Use CloudFront certificate if no custom certificate
  dynamic "viewer_certificate" {
    for_each = var.certificate_arn == "" ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${var.environment}-chat-media-cdn"
    Environment = var.environment
  }
}
