variable "environment" {
  description = "Environment name"
  default     = "dev"
}

variable "domain_name" {
  description = "Domain name for the application"
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
}

variable "alb_zone_id" {
  description = "Hosted zone ID of the ALB"
}

variable "static_cdn_domain_name" {
  description = "Domain name of the static assets CloudFront distribution"
}

variable "media_cdn_domain_name" {
  description = "Domain name of the media files CloudFront distribution"
}
