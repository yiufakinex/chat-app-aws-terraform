# Get the hosted zone for the domain
data "aws_route53_zone" "main" {
  name = var.domain_name
}

# Route53 record for the main application
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.environment == "prod" ? "" : "${var.environment}."}${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Route53 record for the static assets
resource "aws_route53_record" "static" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "static.${var.environment == "prod" ? "" : "${var.environment}."}${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.static_cdn_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront hosted zone ID (constant)
    evaluate_target_health = false
  }
}

# Route53 record for the media files
resource "aws_route53_record" "media" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "media.${var.environment == "prod" ? "" : "${var.environment}."}${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.media_cdn_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront hosted zone ID (constant)
    evaluate_target_health = false
  }
}

# Health check for the application
resource "aws_route53_health_check" "app" {
  fqdn              = var.alb_dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name        = "${var.environment}-chat-app-health-check"
    Environment = var.environment
  }
}
